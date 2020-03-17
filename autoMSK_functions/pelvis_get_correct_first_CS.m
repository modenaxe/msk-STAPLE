% function [ Z0 ] = pelvis_get_correct_first_CS(Pelvis, debug_plots)
% Function to test putting back together a correct orientation of the femur
% Inputs :
%           Pelvis : A triangulation of a complete femur
%           debug_plots : A boolean to display plots useful for debugging
%
% Output :
%           Z0 : A unit vector giving the distal to proximal direction
% -------------------------------------------------------------------------
%                           General Idea
% The largest cross section along the principal inertia axis is located at
% the tibial plateau. From that information it's easy to determine the
% distal to proximal direction.
% -------------------------------------------------------------------------

%% inputs checks
% if nargin < 2
%     debug_plots = 1;
% end


%% Part Used for developpment
close all
clear all
% load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\VAKHUM_S6_CT\tri\pelvis_no_sacrum.mat')
load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\P0_MRI\tri\pelvis_no_sacrum.mat')
% load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\LHDL_CT\tri\pelvis_no_sacrum.mat')
% load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\TLEM2_MRI\tri\pelvis.mat')
% Femur = triang_geom;
% Tibia = curr_triang;
Pelvis = triang_geom;
debug_plots = 1




[V_all, CenterVol, InertiaMatrix, D ] =  TriInertiaPpties(Pelvis);
Z0 = V_all(:,1);
Y0 = V_all(:,2);
X0 = cross(Y0,Z0);

%% Get convexHull
K = convhull(Pelvis.Points);
Kold2new(sort(unique(K(:)))) = 1:length(sort(unique(K(:))));
Pts = Pelvis.Points(sort(unique(K(:))),:);
PelvisConvHull = triangulation(Kold2new(K), Pts);


%% Get surface from
n = Y0;
d = 120;
Tr = Pelvis;
Pts = Tr.Points;
%Project all on plane
[ Pts_Proj ] = ProjectOnPlan( Pts , n , d );

while 1
    Utmp = normalizeV(randn(3,1));
    if Utmp'*n < 0.5
        break
    end
end
V = normalizeV( cross(n, Utmp) );
U = cross(V, n);

ProjCS = [U, V, n];

% Pts_Proj should be moved to the plan CS to get bounding rectangle and
% then moved back to the current imaging CS
Pts_ProjinCS = Pts_Proj*ProjCS;
altProjCS = mean(Pts_ProjinCS(:,3));

Pt1 = [min(Pts_ProjinCS(:,1))-20 min(Pts_ProjinCS(:,2))-20 altProjCS];
Pt2 = [max(Pts_ProjinCS(:,1))+20 min(Pts_ProjinCS(:,2))-20 altProjCS];
Pt3 = [max(Pts_ProjinCS(:,1))+20 max(Pts_ProjinCS(:,2))+20 altProjCS];
Pt4 = [min(Pts_ProjinCS(:,1))-20 max(Pts_ProjinCS(:,2))+20 altProjCS];

squarePts_inProjCS = [Pt1 ; Pt2 ; Pt3 ; Pt4];
squarePts = squarePts_inProjCS*ProjCS';
faces = [1 2 3; 3 4 1];

Square.faces = faces;
Square.vertices = squarePts;
TrSquare = triangulation(faces, squarePts);

Tr1.faces = Tr.ConnectivityList;
Tr1.vertices = Tr.Points;
[intMatrix, intSurface] = SurfaceIntersection(Tr1, Square);



%% Debug Plots
if debug_plots
    % plot(Alt, Area)
    figure()
%     plotDot(Centroids(i_maxArea,:), 'r', 3);
    hold on
    axis equal
    pl3tVectors(CenterVol, Z0, 250);
    pl3tVectors(CenterVol, X0, 100);
    pl3tVectors(CenterVol, Y0, 175);
    trisurf(Pelvis,'facealpha',0.6,'facecolor','b',...
        'edgecolor','none');
    
    trisurf(PelvisConvHull,'facealpha',0.3,'facecolor','cyan',...
        'edgecolor',[.5 .5 .5], 'edgealpha', 0.5);
    
    trisurf(TrSquare,'facealpha',0.4,'facecolor','r',...
        'edgecolor',[.5 .5 .5], 'edgealpha', 0.8);
    
    % handle lighting of objects
    light('Position',CenterVol + 500*V_all(:,2) + 500*V_all(:,3),'Style','local')
    light('Position',CenterVol + 500*V_all(:,2) -  500*V_all(:,3),'Style','local')
    light('Position',CenterVol - 500*V_all(:,2) + 500*V_all(:,3) - 500*Z0,'Style','local')
    light('Position',CenterVol - 500*V_all(:,2) -  500*V_all(:,3) + 500*Z0,'Style','local')
    lighting gouraud
    
    % Remove grid
    grid off
end


%% Get CSA
Alt = linspace( min(PelvisConvHull.Points*Y0)+50 ,max(PelvisConvHull.Points*Y0)-10, 100);
Area= zeros(size(Alt));
Centroids = zeros(size(Alt,2),3);
it=0;
for d = -Alt
    it = it + 1;
    [ curves , Area(it), ~ ] = TriPlanIntersect(PelvisConvHull, Y0 , d );
    centroid_temp = 0;
    for j = 1:length(curves)
        pl3t(curves(j).Pts,'k-')
        [ centroid_j, area_j ] = PlanPolygonCentroid3D( curves(j).Pts );
        centroid_temp = centroid_temp + centroid_j*area_j;
    end
    Centroids(it, : ) = centroid_temp/Area(it);
end

[~, i_maxArea] = max(Area);

if i_maxArea > 0.66*it
    Y0 = Y0;
elseif i_maxArea < 0.33*it
    Y0 = -Y0;
else
    warning("Identification of the initial distal to proximal axis of "+...
    "the tibia went wrong. Check the tibia geometry")
end

figure
plot(Alt,Area)

%% Debug Plots
if debug_plots
    % plot(Alt, Area)
    figure()
%     plotDot(Centroids(i_maxArea,:), 'r', 3);
    hold on
    axis equal
    pl3tVectors(CenterVol, Z0, 250);
    pl3tVectors(CenterVol, X0, 100);
    pl3tVectors(CenterVol, Y0, 175);
    trisurf(Pelvis,'facealpha',0.6,'facecolor','b',...
        'edgecolor','none');
    
    trisurf(PelvisConvHull,'facealpha',0.3,'facecolor','cyan',...
        'edgecolor',[.5 .5 .5], 'edgealpha', 0.5);
    
    % handle lighting of objects
    light('Position',CenterVol + 500*V_all(:,2) + 500*V_all(:,3),'Style','local')
    light('Position',CenterVol + 500*V_all(:,2) -  500*V_all(:,3),'Style','local')
    light('Position',CenterVol - 500*V_all(:,2) + 500*V_all(:,3) - 500*Z0,'Style','local')
    light('Position',CenterVol - 500*V_all(:,2) -  500*V_all(:,3) + 500*Z0,'Style','local')
    lighting gouraud
    
    % Remove grid
    grid off
end

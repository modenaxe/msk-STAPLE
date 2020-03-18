function [ BL, RotISB2Glob, CenterVol, InertiaMatrix, D] = pelvis_get_correct_first_CS(Pelvis, debug_plots)
% Function to test putting back together a correct orientation of the femur
% Inputs :
%           Pelvis : A triangulation of a complete femur
%           debug_plots : A boolean to display plots useful for debugging
%
% Output :
%   BL              A structure containing the pelvis bone landmarks
%   RotISB2Glob     A rotation matrix containing properly oriented initial
%                   guess of the X, Y and Z axis of the pelvis ISB CS
%   CenterVol       Volumetric center of the pelvis
%
% -------------------------------------------------------------------------
%                           General Idea
% The largest cross section along the principal inertia axis is located at
% the tibial plateau. From that information it's easy to determine the
% distal to proximal direction. Then the largest triangle of the pelvis
% convex hull is the one connecting the LASIS RASIS and SYMP.
% -------------------------------------------------------------------------

%% inputs checks
if nargin < 2
    debug_plots = 0;
end


%% Part Used for developpment
% close all
% clear all
% % load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\VAKHUM_S6_CT\tri\pelvis_no_sacrum.mat')
% % load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\P0_MRI\tri\pelvis_no_sacrum.mat')
% load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\LHDL_CT\tri\pelvis_no_sacrum.mat')
% % load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\TLEM2_MRI\tri\pelvis.mat')
% % Femur = triang_geom;
% % Pelvis = curr_triang;
% Pelvis = triang_geom;
% debug_plots = 1;


%%
[V_all, CenterVol, InertiaMatrix, D ] =  TriInertiaPpties(Pelvis);
Z0 = V_all(:,1);
Y0 = V_all(:,2);
X0 = cross(Y0,Z0);

%% Get convexHull
K = convhull(Pelvis.Points);
Kold2new(sort(unique(K(:)))) = 1:length(sort(unique(K(:))));
Pts = Pelvis.Points(sort(unique(K(:))),:);
PelvisConvHull = triangulation(Kold2new(K), Pts);


%% Get CSA of the convex hull
Alt = linspace( min(PelvisConvHull.Points*Y0)+2 ,max(PelvisConvHull.Points*Y0)-2, 100);
Area= zeros(size(Alt));
Centroids = zeros(size(Alt,2),3);
it=0;
for d = -Alt
    it = it + 1;
    [ curves , Area(it), ~ ] = TriPlanIntersect(PelvisConvHull, Y0 , d);
    centroid_temp = 0;
    for j = 1:length(curves)
        centroid_j = PlanPolygonCentroid3D( curves(j).Pts );
        centroid_temp = centroid_temp + ...
            centroid_j*curves(j).Area*(-curves(j).Hole);
    end
    Centroids(it, : ) = centroid_temp/Area(it);
end

[~, i_maxArea] = max(Area);

if i_maxArea > 0.55*it
    Y0 = Y0;
elseif i_maxArea < 0.45*it
    Y0 = -Y0;
else
    warning("Identification of the initial distal to proximal axis of "+...
    "the tibia went wrong. Check the tibia geometry")
end


%% Get the Post-Ant direction by finding the largest triangle of the pelvis
% convex hull

% Find the largest triangle on the projected Convex Hull
[ PelvisConvHull_Ppties ] = TriMesh2DProperties( PelvisConvHull );
[~,I] = max(PelvisConvHull_Ppties.Area);

% Get the triangle center and normal
ConvHullFaceNormals = PelvisConvHull.faceNormal;
LargestTriangleNormal = ConvHullFaceNormals(I,:);
LargestTrianglePts = PelvisConvHull.Points(...
                                PelvisConvHull.ConnectivityList(I,:) , :);

LargestTriangle = triangulation([1 2 3], LargestTrianglePts);

% Check if the normal vector is at least 60° from Y0:
if acosd(abs(LargestTriangleNormal*Y0)) < 60 
    warning("Orientation of initial X0 vector of pelvis might not be good")
end

% Reorient X0 to be posterior to anterior
X0 = sign(LargestTriangleNormal*X0)*X0;

%% Get the final initial CS
Z0 = cross(X0, Y0);
RotISB2Glob = [X0, Y0, Z0];


%% Get the SYMP  BoneLandmarks (BL)
% Along an axis oriented superiorly and a bit on the right we find
% projected on this axis succesively RASIS, LASIS then SYMP
U_SupSupRight = normalizeV(4*Y0+Z0);
[~,I] = sort(LargestTrianglePts*U_SupSupRight);
BL.SYMP = LargestTrianglePts(I(1), : );
% BL.LASIS = LargestTrianglePts(I(2), : );
% BL.RASIS = LargestTrianglePts(I(3), : );

%% Get the RPSIS and LPSIS raw BoneLandmarks (BL)
[ PelvisPseudoISB, ~ , ~ ] = TriChangeCS( Pelvis, RotISB2Glob, CenterVol);

% Get the Posterior, Superior, Right eigth of the pelvis
Nodes_RPSIS = find( PelvisPseudoISB.Points(:,1) < 0 & ...
    PelvisPseudoISB.Points(:,2) > 0 & ...
    PelvisPseudoISB.Points(:,3) > 0 ) ;
Pelvis_RPSIS = TriReduceMesh(Pelvis, [], Nodes_RPSIS);
% Find the most posterior points in this eigth
[~,Imin] = min(Pelvis_RPSIS.Points*X0);
BL.RPSIS = Pelvis_RPSIS.Points(Imin,:);

% Get the Posterior, Superior, Left eigth of the pelvis
Nodes_LPSIS = find( PelvisPseudoISB.Points(:,1) < 0 & ...
    PelvisPseudoISB.Points(:,2) > 0 & ...
    PelvisPseudoISB.Points(:,3) < 0 ) ;
Pelvis_LPSIS = TriReduceMesh(Pelvis, [], Nodes_LPSIS);
% Find the most posterior points in this eigth
[~,Imin] = min(Pelvis_LPSIS.Points*X0);
BL.LPSIS = Pelvis_LPSIS.Points(Imin,:);

%% Get the RASIS and LASIS raw BoneLandmarks (BL)
% Get the Anterior, Superior, Right eigth of the pelvis
Nodes_RASIS = find( PelvisPseudoISB.Points(:,1) > 0 & ...
    PelvisPseudoISB.Points(:,2) > 0 & ...
    PelvisPseudoISB.Points(:,3) > 0 ) ;
Pelvis_RASIS = TriReduceMesh(Pelvis, [], Nodes_RASIS);
% Find the most posterior points in this eigth
[~,Imax] = max(Pelvis_RASIS.Points*X0);
BL.RASIS = Pelvis_RASIS.Points(Imax,:);

% Get the Anterior, Superior, Left eigth of the pelvis
Nodes_LASIS = find( PelvisPseudoISB.Points(:,1) > 0 & ...
    PelvisPseudoISB.Points(:,2) > 0 & ...
    PelvisPseudoISB.Points(:,3) < 0 ) ;
Pelvis_LASIS = TriReduceMesh(Pelvis, [], Nodes_LASIS);
% Find the most posterior points in this eigth
[~,Imax] = max(Pelvis_LASIS.Points*X0);
BL.LASIS = Pelvis_LASIS.Points(Imax,:);

%% Debug Plots
if debug_plots
%     figure()
%     plot(Alt,Area)
    figure()
    hold on
    axis equal
    pl3tVectors(CenterVol, X0, 125);
    pl3tVectors(CenterVol, Y0, 175);
    pl3tVectors(CenterVol, Z0, 250);
    trisurf(Pelvis,'facealpha',0.5,'facecolor','b',...
        'edgecolor','none');
    trisurf(PelvisConvHull,'facealpha',0.2,'facecolor','c',...
        'edgecolor',[.3 .3 .3], 'edgealpha', 0.2);
    trisurf(LargestTriangle,'facealpha',0.8,'facecolor','r',...
        'edgecolor','k');
    plotDot(BL.RASIS,'m',7)
    plotDot(BL.LASIS,'g',7)
    plotDot(BL.RPSIS,'m',7)
    plotDot(BL.LPSIS,'g',7)
    plotDot(BL.SYMP,'k',7)
    % handle lighting of objects
    light('Position',CenterVol + 500*V_all(:,2) + 500*V_all(:,3),'Style','local')
    light('Position',CenterVol + 500*V_all(:,2) -  500*V_all(:,3),'Style','local')
    light('Position',CenterVol - 500*V_all(:,2) + 500*V_all(:,3) - 500*Z0,'Style','local')
    light('Position',CenterVol - 500*V_all(:,2) -  500*V_all(:,3) + 500*Z0,'Style','local')
    lighting gouraud
    
    % Remove grid
    grid off
end

end
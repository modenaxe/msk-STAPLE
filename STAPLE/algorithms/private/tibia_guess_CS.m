function [ Z0 ] = tibia_guess_CS(Tibia, debug_plots)
% Function to test putting back together a correct orientation of the femur
% Inputs :
%           Tibia : A triangulation of a complete femur
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
if nargin < 2
    debug_plots = 1;
end


%% Part Used for developpment
% close all
% clear all
% load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\VAKHUM_S6_CT\tri\tibia_r.mat')
% % load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\P0_MRI\tri\tibia_r.mat')
% % load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\LHDL_CT\tri\tibia_r.mat')
% % load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\TLEM2_MRI\tri\tibia_r.mat')
% % Femur = triang_geom;
% % Tibia = curr_triang;
% Tibia = triang_geom;
% debug_plots = 1


%% Get principal inertia axis
% Get the principal inertia axis of the tibia (potentially wrongly orientated)
[ V_all, CenterVol ] = TriInertiaPpties( Tibia );
Z0 = V_all(:,1);

%% Get CSA
Alt = linspace( min(Tibia.Points*Z0)+0.5 ,max(Tibia.Points*Z0)-0.5, 100);
Area= zeros(size(Alt));
Centroids = zeros(size(Alt,2),3);
it=0;
for d = -Alt
    it = it + 1;
    [ curves , ~, ~ ] = TriPlanIntersect(Tibia, Z0 , d );
    max_area = 0 ;
    for j = 1:length(curves)
        [ Centroids(it,:), area_j ] = PlanPolygonCentroid3D( curves(j).Pts );
        if area_j > max_area
            max_area = area_j ;
        end
    end
    Area(it) = max_area;
end

[~, i_maxArea] = max(Area);

if i_maxArea > 0.66*it
    Z0 = Z0;
elseif i_maxArea < 0.33*it
    Z0 = -Z0;
else
    warning("Identification of the initial distal to proximal axis of "+...
    "the tibia went wrong. Check the tibia geometry")
end

if debug_plots
    % plot(Alt, Area)
    figure()
    plotDot(Centroids(i_maxArea,:), 'r', 3);
    hold on
    axis equal
    pl3tVectors(CenterVol, Z0, 220);
    trisurf(Tibia,'facealpha',0.6,'facecolor','cyan',...
        'edgecolor','none');
    
    % handle lighting of objects
    light('Position',CenterVol + 500*V_all(:,2) + 500*V_all(:,3),'Style','local')
    light('Position',CenterVol + 500*V_all(:,2) -  500*V_all(:,3),'Style','local')
    light('Position',CenterVol - 500*V_all(:,2) + 500*V_all(:,3) - 500*Z0,'Style','local')
    light('Position',CenterVol - 500*V_all(:,2) -  500*V_all(:,3) + 500*Z0,'Style','local')
    lighting gouraud
    
    % Remove grid
    grid off
end

    
function [CS, JCS] = CS_femur_SpheresOnPatellarGroove(Groove_Lat, Groove_Med, CS, in_mm, debug_plots)

% check units
if nargin<4;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end
% debug plots off by default
if nargin<5; debug_plots = 0; end

% function fit_spheres(Condyle_1_end, Condyle_2_end)
[center_lat,radius_lat] = sphereFit(Groove_Lat.Points); %lat
[center_med,radius_med] = sphereFit(Groove_Med.Points); %med

% centre
PaTGrooveCenter = 0.5*(center_lat+center_med);

% Starting axes: X is orthog to Y and Z, which are not mutually perpend
Z = normalizeV(center_lat-center_med);
Y = normalizeV( CS.CenterFH_Renault - PaTGrooveCenter );
X = cross(Y, Z);

% store axes in structure
CS.patgroove_center_lat = center_lat;
CS.patgroove_center_med = center_med;
CS.patgroove_radius_lat = radius_lat;
CS.patgroove_radius_med = radius_med;
CS.patgroove_origin     = PaTGrooveCenter;

% define patellofemoral axes
Y_ptf = cross(Z, X);
JCS.patellofemoral_r.V = [X Y_ptf Z];
JCS.patellofemoral_r.parent_location    = PaTGrooveCenter * dim_fact;
JCS.patellofemoral_r.parent_orientation = computeZXYAngleSeq(JCS.patellofemoral_r.V);

% debug plots
if debug_plots == 1
    quickPlotTriang(Groove_Lat, 'b')
    quickPlotTriang(Groove_Med, 'r')
    plotSphere( center_lat, radius_lat , 'b')
    plotSphere( center_med, radius_med , 'r')
end
end
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese & Jean-Baptiste Renault. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [CS, JCS] = CS_femur_SpheresOnCondyles(postCondyle_Lat, postCondyle_Med, CS, side, debug_plots, in_mm)

% REFERENCE SYSTEM
% to be described for the two joints

% default behaviour: do not plot
if nargin<5;    debug_plots = 0;         end
if nargin<6;    in_mm = 1;               end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% get sign correspondent to body side
[side_sign, side_low] = bodySide2Sign(side);

% joint names
knee_name = ['knee_', side_low];
hip_name  = ['hip_', side_low];

% fit spheres to the two posterior condyles
[center_lat,radius_lat] = sphereFit(postCondyle_Lat.Points); %lat
[center_med,radius_med] = sphereFit(postCondyle_Med.Points); %med

% knee center in the middle
KneeCenter = 0.5*(center_lat+center_med);

% store axes in structure
CS.sphere_center_lat = center_lat;
CS.sphere_radius_lat = radius_lat;
CS.sphere_center_med = center_med;
CS.sphere_radius_med = radius_med;

% common axes: X is orthog to Y and Z, which are not mutually perpend
Z = normalizeV(center_lat-center_med)*side_sign;
Y = normalizeV(CS.CenterFH_Renault- KneeCenter);
X = normalizeV(cross(Y,Z));

% define hip joint
Zml_hip = normalizeV(cross(X, Y));
JCS.(hip_name).V = [X Y Zml_hip];
JCS.(hip_name).child_location = CS.CenterFH_Renault * dim_fact;
JCS.(hip_name).child_orientation = computeXYZAngleSeq(JCS.(hip_name).V);
JCS.(hip_name).Origin = CS.CenterFH_Renault;

% define knee joint
Y_knee = normalizeV(cross(Z, X));
JCS.(knee_name).V = [X Y_knee Z];
JCS.(knee_name).parent_location    = KneeCenter * dim_fact;
JCS.(knee_name).parent_orientation = computeXYZAngleSeq(JCS.(knee_name).V);
JCS.(knee_name).Origin             = KneeCenter;

if debug_plots == 1
    grid off
    quickPlotTriang(postCondyle_Lat, 'b')
    quickPlotTriang(postCondyle_Med, 'r')
    plotSphere( center_lat, radius_lat , 'b')
    plotSphere( center_med, radius_med , 'r')
end

end
function [CS, JCS] = CS_femur_EllipsoidsOnCondyles(Condyle_Lat, Condyle_Med, CS, side, debug_plots, in_mm)

% default behaviour: do not plot
if nargin<5;    debug_plots = 0;         end
if nargin<6;    in_mm = 1;               end
if in_mm == 1;  dim_fact = 0.001;        else;  dim_fact = 1; end

% get sign correspondent to body side
[side_sign, side_low] = bodySide2Sign(side);

% joint names
knee_name = ['knee_', side_low];
hip_name  = ['hip_', side_low];

% fitting ellipsoids
[center_lat, radii_lat, evecs_lat] = ellipsoid_fit( Condyle_Lat.Points , '' );
[center_med, radii_med, evecs_med] = ellipsoid_fit( Condyle_Med.Points , '' );

% store ellipsoid data
CS.ellips_centre_med = center_med;
CS.ellips_centre_lat = center_lat;
CS.ellips_radii_med = radii_med;
CS.ellips_radii_lat = radii_lat;
CS.ellips_evec_med = evecs_med;
CS.ellips_evec_lat = evecs_lat;

% knee joint centre is midpoint of ellipsoid centres
KneeCenter = 0.5*(center_med+center_lat)';

% Starting axes: X is orthog to Y and Z, which are not mutually perpend
Z = normalizeV(center_lat-center_med) * side_sign; 
Y = normalizeV(CS.CenterFH_Renault - KneeCenter);
X = normalizeV(cross(Y, Z));

% define hip axes
Zml_hip = normalizeV(cross(X, Y));
JCS.(hip_name).V = [X Y Zml_hip];
JCS.(hip_name).child_location = CS.CenterFH_Renault * dim_fact;
JCS.(hip_name).child_orientation = computeXYZAngleSeq(JCS.(hip_name).V);
JCS.(hip_name).Origin = CS.CenterFH_Renault;

% define knee joint
Y_knee = normalizeV(cross(Z, X));
JCS.(knee_name).V = [X Y_knee Z];
JCS.(knee_name).parent_location = KneeCenter * dim_fact;
JCS.(knee_name).parent_orientation = computeXYZAngleSeq(JCS.(knee_name).V);
JCS.(knee_name).Origin = KneeCenter;

% debug plots
if debug_plots == 1
    quickPlotTriang(Condyle_Lat, 'b')
    quickPlotTriang(Condyle_Med, 'r')
    PlotEllipsoid(center_lat, radii_lat, evecs_lat, 'b')
    PlotEllipsoid(center_med, radii_med, evecs_med, 'r')
end

end
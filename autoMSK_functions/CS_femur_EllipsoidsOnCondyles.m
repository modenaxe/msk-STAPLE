function [CS, JCS] = CS_femur_EllipsoidsOnCondyles(Condyle_Lat,Condyle_Med, CS, in_mm)

% check units
if nargin<4;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% fitting ellipsoids
[center_lat, radii_lat, evecs_lat] = ellipsoid_fit( Condyle_Lat.Points , '' );
[center_med, radii_med, evecs_med] = ellipsoid_fit( Condyle_Med.Points , '' );

% knee joint centre is midpoint of ellipsoid centres
KneeCenter = 0.5*(center_med+center_lat)';

% Starting axes: X is orthog to Y and Z, which are not mutually perpend
Z =  normalizeV(center_med-center_lat);
Y =  normalizeV(CS.CenterFH - KneeCenter);
X = cross(Y, Z);

% define hip axes
Zml_hip =  cross(X, Y);
JCS.hip_r.V = [X Y Zml_hip];
JCS.hip_r.child_location = CS.CenterFH * dim_fact;
JCS.hip_r.child_orientation = computeZXYAngleSeq(JCS.hip_r.V);
JCS.hip_r.Origin = CS.CenterFH;

% define knee joint
Y_knee = cross(Z, X);
JCS.knee_r.V = [X Y_knee Z];
JCS.knee_r.parent_location = KneeCenter * dim_fact;
JCS.knee_r.parent_orientation = computeZXYAngleSeq(JCS.knee_r.V);
JCS.knee_r.Origin = KneeCenter;

% debug plots
grid off
quickPlotTriang(Condyle_Lat, 'b')
quickPlotTriang(Condyle_Med, 'r')
PlotEllipsoid(center_lat, radii_lat, evecs_lat, 'b')
PlotEllipsoid(center_med, radii_med, evecs_med, 'r')


end
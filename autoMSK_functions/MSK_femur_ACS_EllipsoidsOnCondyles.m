function CS = MSK_femur_ACS_EllipsoidsOnCondyles(Condyle_lat,Condyle_med, CS, in_mm)
% REFERENCE SYSTEM
% to be described for the two joints

% check units
if nargin<4;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% fitting ellipsoids
center_lat = ellipsoid_fit( Condyle_lat.Points , '' );
center_med = ellipsoid_fit( Condyle_med.Points , '' );

% knee joint centre is midpoint of ellipsoid centres
KneeCenter = 0.5*(center_med+center_lat)';

% Starting axes: X is orthog to Y and Z, which are not mutually perpend
Z =  normalizeV(center_med-center_lat);
Y =  normalizeV(CS.CenterFH - KneeCenter);
X = cross(Y, Z);

% define hip axes
Zml_hip =  cross(X, Y);
CS.V_hip = [X Y Zml_hip];
CS.hip_r.child_location = CS.CenterFH * dim_fact;
CS.hip_r.child_orientation = computeZXYAngleSeq(CS.V_hip);

% define knee joint
Y_knee = cross(Z, X);
CS.V_knee = [X Y_knee Z];
CS.knee_r.parent_location = KneeCenter * dim_fact;
CS.knee_r.parent_orientation = computeZXYAngleSeq(CS.V_knee);

end
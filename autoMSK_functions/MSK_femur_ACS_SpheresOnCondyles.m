function CS = MSK_femur_ACS_SpheresOnCondyles(postCondyle_Lat, postCondyle_Med, CS, in_mm)

% REFERENCE SYSTEM
% to be described for the two joints

% check units
if nargin<4;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% fit spheres to the two posterior condyles
[center_lat,radius_lat] = sphereFit(postCondyle_Lat.Points); %lat
[center_med,radius_med] = sphereFit(postCondyle_Med.Points); %med

% knee center in the middle
KneeCenter = 0.5*(center_lat+center_med);

% store axes in structure
CS.Center_Lat = center_lat;
CS.Radius_Lat = radius_lat;
CS.Center_Med = center_med;
CS.Radius_Med = radius_med;
CS.Origin     = KneeCenter;

% common axes: X is orthog to Y and Z, which are not mutually perpend
Z = normalizeV(center_lat-center_med);
Y = normalizeV(KneeCenter - CS.CenterFH);
X = cross(Y,Z);

% define hip joint
Zml_hip = cross(X, Y);
CS.V_hip = [X Y Zml_hip];
CS.hip_r.child_location = CS.CenterFH * dim_fact;
CS.hip_r.child_orientation = computeZXYAngleSeq(CS.V_hip);

% define knee joint
Y_knee = cross(Z, X);
CS.V_knee = [X Y_knee Z];
CS.knee_r.parent_location = KneeCenter * dim_fact;
CS.knee_r.parent_orientation = computeZXYAngleSeq(CS.V_knee);

% debug plot
% quickPlotRefSystem(CS)

end
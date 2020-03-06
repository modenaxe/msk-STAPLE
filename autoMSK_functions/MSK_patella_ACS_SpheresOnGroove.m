function CS = MSK_patella_ACS_SpheresOnGroove(Groove_Lat, Groove_Med, CS, in_mm)

% check units
if nargin<4;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% function fit_spheres(Condyle_1_end, Condyle_2_end)
[center_lat,radius_lat] = sphereFit(Groove_Lat.Points); %lat
[center_med,radius_med] = sphereFit(Groove_Med.Points); %med

% centre
PaTGrooveCenter = 0.5*(center_lat+center_med);

% Starting axes: X is orthog to Y and Z, which are not mutually perpend
Z = normalizeV(center_lat-center_med);
Y = normalizeV( CS.CenterFH - PaTGrooveCenter );
X = cross(Y, Z);

% store axes in structure
CS.Center_Lat = center_lat;
CS.Radius_Lat = radius_lat;
CS.Center_Med = center_med;
CS.Radius_Med = radius_med;
CS.Origin     = PaTGrooveCenter;

% define patellofemoral axes
Y_ptf = cross(Z, X);
CS.patellofemoral_r.V = [X Y_ptf Z];
CS.patellofemoral_r.parent_location    = PaTGrooveCenter * dim_fact;
CS.patellofemoral_r.parent_orientation = computeZXYAngleSeq(CS.patellofemoral_r.V);

% % debug plots
% grid off
% plotSphere( center1, radius1 , 'c')
% plotSphere( center2, radius2 , 'c')

end
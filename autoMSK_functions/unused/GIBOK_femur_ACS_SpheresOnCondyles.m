function CS = GIBOK_femur_ACS_SpheresOnCondyles(postCondyle_Lat, postCondyle_Med, CS)
% REFERENCE SYSTEM
% centred in the midpoint of the spheres
% Z: upwards (Orig->HJC)
% X: perpendicolar to Z and the plane with sphere centres (Ysph)
% Y: cross of XZ

% function fit_spheres(Condyle_1_end, Condyle_2_end)
[center_lat,radius_lat] = sphereFit(postCondyle_Lat.Points); %lat
[center_med,radius_med] = sphereFit(postCondyle_Med.Points); %med

% normalize and check axis direction
Yml =  normalizeV(center_lat-center_med);
% Yml = sign(Yml'*CS.Y0)*Yml;

% knee center in the middle
KneeCenterSph = 0.5*(center_lat+center_med);

% compute axes
Zdp =  normalizeV( CS.CenterFH - KneeCenterSph );
Xap =  normalizeV( cross(Yml, Zdp) );
Yml = cross(Zdp, Xap);

% store axes in structure
CS.PCS.Center1 = center_lat;
CS.PCS.Center2 = center_med;
CS.PCS.Radius1 = radius_lat;
CS.PCS.Radius2 = radius_med;
CS.PCS.Ysph    = Yml;
CS.PCS.Origin  = KneeCenterSph;
CS.PCS.X       = Xap;
CS.PCS.Y       = Yml;
CS.PCS.Z       = Zdp;
CS.PCS.V       = [Xap Yml Zdp];

% debug plot
quickPlotRefSystem(CS.PCS)

end
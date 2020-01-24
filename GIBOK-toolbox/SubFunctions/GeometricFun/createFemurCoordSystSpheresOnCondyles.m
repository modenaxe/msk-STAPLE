function CSs = createFemurCoordSystSpheresOnCondyles(Condyle_1_end, Condyle_2_end, CSs)
% REFERENCE SYSTEM
% centred in the midpoint of the spheres
% Z: upwards (Orig->HJC)
% X: perpendicolar to Z and the plane with sphere centres (Ysph)
% Y: cross of XZ

% function fit_spheres(Condyle_1_end, Condyle_2_end)
[center1,radius1] = sphereFit(Condyle_1_end.Points); %lat
[center2,radius2] = sphereFit(Condyle_2_end.Points); %med

% normalize and check axis direction
Ysph =  normalizeV(center1-center2);
Ysph = sign(Ysph'*CSs.Y0)*Ysph;

KneeCenterSph = 0.5*(center1+center2);

% compute axes
Zend_sph =  normalizeV( CSs.CenterFH - KneeCenterSph );
Xend_sph =  normalizeV( cross(Ysph, Zend_sph) );
Yend_sph = cross(Zend_sph, Xend_sph);

% store axes in structure
CSs.PCS.Center1 = center1;
CSs.PCS.Center2 = center2;
CSs.PCS.Radius1 = radius1;
CSs.PCS.Radius2 = radius2;
CSs.PCS.Ysph    = Ysph;
CSs.PCS.Origin  = KneeCenterSph;
CSs.PCS.X       = Xend_sph;
CSs.PCS.Y       = Yend_sph;
CSs.PCS.Z       = Zend_sph;
CSs.PCS.V       = [Xend_sph Yend_sph Zend_sph];

end
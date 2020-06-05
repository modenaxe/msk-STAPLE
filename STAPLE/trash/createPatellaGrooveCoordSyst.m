function CSs = createPatellaGrooveCoordSyst(Groove_Lat, Groove_Med, CSs)

% function fit_spheres(Condyle_1_end, Condyle_2_end)
[center1,radius1] = sphereFit(Groove_Lat.Points); %lat
[center2,radius2] = sphereFit(Groove_Med.Points); %med

% centre
PaTGrooveCenter = 0.5*(center1+center2);

% normalize and check axis direction
Y =  normalizeV(center1-center2);
Y = sign(Y'*CSs.Y0)*Y;

% termporary Z
Z = normalizeV( CSs.CenterFH - PaTGrooveCenter );

% compute axes
Yend_sph = Y;
Xend_sph = normalizeV( cross(Y, Z) );
Zend_sph = normalizeV( cross(Xend_sph, Yend_sph) );

% store axes in structure
CSs.patellofemoral_r.Center1 = center1;
CSs.patellofemoral_r.Center2 = center2;
CSs.patellofemoral_r.Radius1 = radius1;
CSs.patellofemoral_r.Radius2 = radius2;
CSs.patellofemoral_r.Origin  = PaTGrooveCenter;
CSs.patellofemoral_r.X       = Xend_sph;
CSs.patellofemoral_r.Y       = Yend_sph;
CSs.patellofemoral_r.Z       = Zend_sph;
CSs.patellofemoral_r.V       = [Xend_sph Yend_sph Zend_sph];

% % debug plots
% grid off
% plotSphere( center1, radius1 , 'c')
% plotSphere( center2, radius2 , 'c')


end
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
CSs.PatGr.Center1 = center1;
CSs.PatGr.Center2 = center2;
CSs.PatGr.Radius1 = radius1;
CSs.PatGr.Radius2 = radius2;
CSs.PatGr.Origin  = PaTGrooveCenter;
CSs.PatGr.X       = Xend_sph;
CSs.PatGr.Y       = Yend_sph;
CSs.PatGr.Z       = Zend_sph;
CSs.PatGr.V       = [Xend_sph Yend_sph Zend_sph];


% figure()
% % Plot the whole tibia, here TrObjects.Femur is a Matlab triangulation object
% trisurf(Groove_Lat,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',1,'edgecolor','none');
% hold on
% axis equal
% 
% % handle lighting of objects
% light('Position',CSs.PatGr.Origin' + 500*CSs.PatGr.Y + 500*CSs.PatGr.X,'Style','local')
% light('Position',CSs.PatGr.Origin' + 500*CSs.PatGr.Y - 500*CSs.PatGr.X,'Style','local')
% light('Position',CSs.PatGr.Origin' - 500*CSs.PatGr.Y + 500*CSs.PatGr.X - 500*CSs.PatGr.Z,'Style','local')
% light('Position',CSs.PatGr.Origin' - 500*CSs.PatGr.Y - 500*CSs.PatGr.X + 500*CSs.PatGr.Z,'Style','local')
% lighting gouraud
% 
% % Plot the whole tibia, here TrObjects.Femur is a Matlab triangulation object
% trisurf(Groove_Med,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',1,'edgecolor','none');
% hold on
% axis equal
% 
% % handle lighting of objects
% light('Position',CSs.PatGr.Origin' + 500*CSs.PatGr.Y + 500*CSs.PatGr.X,'Style','local')
% light('Position',CSs.PatGr.Origin' + 500*CSs.PatGr.Y - 500*CSs.PatGr.X,'Style','local')
% light('Position',CSs.PatGr.Origin' - 500*CSs.PatGr.Y + 500*CSs.PatGr.X - 500*CSs.PatGr.Z,'Style','local')
% light('Position',CSs.PatGr.Origin' - 500*CSs.PatGr.Y - 500*CSs.PatGr.X + 500*CSs.PatGr.Z,'Style','local')
% lighting gouraud
% 
% % Remove grid
% grid off
% plotSphere( center1, radius1 , 'c')
% plotSphere( center2, radius2 , 'c')


end
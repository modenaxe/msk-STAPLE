function PlotPatella( CS, TrObjects )
%PLOTPATELLA Display figures of the patella
%   Detailed explanation goes here

figure()
% Plot the whole tibia, here ProxTib is a Matlab triangulation object
trisurf(TrObjects.Patella,'Facecolor',[209./256    201./256    185./256],'FaceAlpha',1,'edgecolor','none');
hold on
axis equal

% handle lighting of objects
light('Position',CS.Origin' + 500*CS.Y + 500*CS.X,'Style','local')
light('Position',CS.Origin' + 500*CS.Y - 500*CS.X,'Style','local')
light('Position',CS.Origin' - 500*CS.Y + 500*CS.X - 500*CS.Z,'Style','local')
light('Position',CS.Origin' - 500*CS.Y - 500*CS.X + 500*CS.Z,'Style','local')
lighting gouraud

% Remove grid
grid off

%% Figure 2
figure()

% Plot the whole tibia, here ProxTib is a Matlab triangulation object
Patella = TriDifferenceMesh( TrObjects.Patella, TrObjects.PatArtSurf);
Patella = TriDilateMesh(TrObjects.Patella,Patella,1);

trisurf(Patella,'Facecolor',[209./256    201./256    185./256],'FaceAlpha',0.9,'edgecolor','none');
hold on
axis equal


% Plot the identified articular surfaces
trisurf(TrObjects.PatArtSurf,'Facecolor',[128./256    170./256    255./256],'FaceAlpha',0.9,'edgecolor','none');

% handle lighting of objects
light('Position',CS.Origin' + 500*CS.Y + 500*CS.X,'Style','local')
light('Position',CS.Origin' + 500*CS.Y - 500*CS.X,'Style','local')
light('Position',CS.Origin' - 500*CS.Y + 500*CS.X - 500*CS.Z,'Style','local')
light('Position',CS.Origin' - 500*CS.Y - 500*CS.X + 500*CS.Z,'Style','local')
lighting gouraud

% changed colors to standard representations
plotArrow( CS.X, 1, CS.Origin, 20, 1, 'r')
plotArrow( CS.Y, 1, CS.Origin, 25, 1, 'g')
plotArrow( CS.Z, 1, CS.Origin, 25, 1, 'b')


% Remove grid
grid off

end


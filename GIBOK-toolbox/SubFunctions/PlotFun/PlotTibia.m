function PlotTibia( CS, TrObjects )
%PLOTTIBIA Display figures of the tibia
%   Detailed explanation goes here

figure()
% Plot the whole tibia, here ProxTib is a Matlab triangulation object
trisurf(TrObjects.Tibia,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',1,'edgecolor','none');
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
ProxTib = TriDifferenceMesh( TrObjects.ProxTib, TrObjects.EpiTibASLat);
ProxTib = TriDifferenceMesh( ProxTib, TrObjects.EpiTibASMed);
ProxTib = TriDilateMesh(TrObjects.ProxTib,ProxTib,1);

trisurf(ProxTib,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',0.7,'edgecolor','none');
hold on
axis equal


% Plot the identified articular surfaces
trisurf(TrObjects.EpiTibASLat,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
trisurf(TrObjects.EpiTibASMed,'Facecolor','b','FaceAlpha',1,'edgecolor','none');

% handle lighting of objects
light('Position',CS.Origin' + 500*CS.Y + 500*CS.X,'Style','local')
light('Position',CS.Origin' + 500*CS.Y - 500*CS.X,'Style','local')
light('Position',CS.Origin' - 500*CS.Y + 500*CS.X - 500*CS.Z,'Style','local')
light('Position',CS.Origin' - 500*CS.Y - 500*CS.X + 500*CS.Z,'Style','local')
lighting gouraud

% 
plotArrow( CS.X, 1, CS.Origin, 30, 1, 'b')
plotArrow( CS.Y, 1, CS.Origin, 30, 1, 'r')
plotArrow( CS.Z, 1, CS.Origin, 30, 1, 'k')


% Remove grid
grid off

end


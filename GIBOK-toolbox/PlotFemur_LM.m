function PlotFemur_LM( FEM, TrObjects )
%PLOTFEMUR Display figures of the femur
%   Detailed explanation goes here

CS = FEM.PCC;
% the first figure plots the entire femur (divided in two)
figure()
% Plot the whole tibia, here TrObjects.Femur is a Matlab triangulation object
trisurf(TrObjects.Femur,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',1,'edgecolor','none');
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

%% Figure 2 (plot distal part)
figure()

% Here TrObjects.DistFem, TrObjects.EpiFemASMed and TrObjects.EpiFemASLat are Matlab triangulation objects
% The found Articular Surfaces are separated from the rest of the bone triangulation object
DistFem = TriDifferenceMesh( TrObjects.DistFem, TrObjects.EpiFemASLat);
DistFem = TriDifferenceMesh( DistFem, TrObjects.EpiFemASMed);
DistFem = TriDilateMesh(TrObjects.DistFem,DistFem,1);

trisurf(DistFem,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',0.7,'edgecolor','none');
hold on
axis equal


% Plot the identified articular surfaces
trisurf(TrObjects.EpiFemASLat,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
trisurf(TrObjects.EpiFemASMed,'Facecolor','b','FaceAlpha',1,'edgecolor','none');

% handle lighting of objects
light('Position',CS.Origin' + 500*CS.Y + 500*CS.X,'Style','local')
light('Position',CS.Origin' + 500*CS.Y - 500*CS.X,'Style','local')
light('Position',CS.Origin' - 500*CS.Y + 500*CS.X - 500*CS.Z,'Style','local')
light('Position',CS.Origin' - 500*CS.Y - 500*CS.X + 500*CS.Z,'Style','local')
lighting gouraud

% only for presentation 7/2019 (DELETE AFTER)
plotArrow( CS.X, 1, CS.Origin, 30, 1, 'r')
plotArrow( -CS.Y, 1, CS.Origin, 30, 1, 'b')
plotArrow( CS.Z, 1, CS.Origin, 30, 1, 'g')

% Remove grid
grid off

%% Figure 3 (hip joint)
figure()

trisurf(TrObjects.ProxFem,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',0.7,'edgecolor','none');
hold on
axis equal
% Plot the identified articular surfaces
trisurf(TrObjects.FemHead,'Facecolor','b','FaceAlpha',1,'edgecolor','none');
% trisurf(TrObjects.EpiFemASMed,'Facecolor','b','FaceAlpha',1,'edgecolor','none');

% handle lighting of objects
light('Position',CS.Origin' + 500*CS.Y + 500*CS.X,'Style','local')
light('Position',CS.Origin' + 500*CS.Y - 500*CS.X,'Style','local')
light('Position',CS.Origin' - 500*CS.Y + 500*CS.X - 500*CS.Z,'Style','local')
light('Position',CS.Origin' - 500*CS.Y - 500*CS.X + 500*CS.Z,'Style','local')
lighting gouraud

% only for presentation 7/2019 (DELETE AFTER)
plotArrow( CS.X, 1, FEM.CenterFH, 30, 1, 'r')
plotArrow( -CS.Y, 1, FEM.CenterFH, 30, 1, 'b')
plotArrow( CS.Z, 1, FEM.CenterFH, 30, 1, 'g')

% Remove grid
grid off
end

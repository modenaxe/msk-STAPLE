%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  % 
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
function PlotFemurProx_ISB( CS, TrObjects, FEM )

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

% transforming to ISB ref system
ISB2GB = [1  0  0
          0  0 -1
          0  1 0];
GB2Glob = CS.V;
CS.X = GB2Glob*ISB2GB*[1 0 0]';
CS.Y = GB2Glob*ISB2GB*[0 1 0]';
CS.Z = GB2Glob*ISB2GB*[0 0 1]';

% plot
plotArrow( CS.X, 1, FEM.CenterFH, 30, 1, 'r')
plotArrow( CS.Y, 1, FEM.CenterFH, 30, 1, 'g')
plotArrow( CS.Z, 1, FEM.CenterFH, 30, 1, 'b')

% Remove grid
grid off
end
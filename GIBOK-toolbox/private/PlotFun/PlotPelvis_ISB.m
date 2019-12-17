%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  % 
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
function PlotPelvis_ISB( CS, TrObjects )
%PLOTPELVIS Display figures of the femur
%   Detailed explanation goes here

% the first figure plots the entire femur (divided in two)
figure()
% Plot the whole tibia, here TrObjects.Femur is a Matlab triangulation object
trisurf(TrObjects,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',1,'edgecolor','none');
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

plotArrow( CS.X', 1, CS.Origin, 60, 1, 'r')
plotArrow( CS.Y', 1, CS.Origin, 60, 1, 'g')
plotArrow( CS.Z', 1, CS.Origin, 60, 1, 'b')

end

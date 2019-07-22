function PlotPelvis( CS, TrObjects )
%PLOTFEMUR Display figures of the femur
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
LASIS = [0.0062   71.9720  134.8688];
RASIS = [-38.5144   63.6268  141.5540];

% CS.Origin = (LASIS+RASIS)/2.0;
% only for presentation 7/2019 (DELETE AFTER)
plotArrow( CS.X', 1, CS.Origin, 60, 1, 'r')
plotArrow( CS.Y', 1, CS.Origin, 60, 1, 'b')
plotArrow( CS.Z', 1, CS.Origin, 60, 1, 'g')

% Remove grid
grid off

end

% PLOTPATELLA Plot a patella after indentifying articular surface 
% and coordinate system.
% The patella is displayed on a new figure with identified articular
% surface and associated coordinate system.
%
% PlotPatella( CS, TrObjects )
% 
% Inputs:
%   CS - A coordinate system structure.
%         * CS.Origin ~ the origin of the coordiante system.
%         * CS.X ~ the X direction of the coordiante system.
%         * CS.Y ~ the Y direction of the coordiante system.
%         * CS.Z ~ the Z direction of the coordiante system.
% 
%   TrObjects - A structure containing.
%               * TrObjects.Patella ~ The whole patella triangulation.
%               * TrObjects.PatArtSurf ~ The triangulation of the patella 
%                                        articular surface.
% 
% Outputs:
%   None - Plot a patella after indentifying articular surface 
%          and coordinate system.
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function PlotPatella( CS, TrObjects )


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


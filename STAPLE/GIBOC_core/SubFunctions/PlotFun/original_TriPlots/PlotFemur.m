% PLOTFEMUR Plot a femur after indentifying articular surface 
% and coordinate system.
% The femur is displayed on a new figure with identified articular
% surfaces and associated coordinate system.
%
% PlotFemur( CS, TrObjects )
% 
% Inputs:
%   CS - A coordinate system structure.
%         * CS.Origin ~ the origin of the coordiante system.
%         * CS.X ~ the X direction of the coordiante system.
%         * CS.Y ~ the Y direction of the coordiante system.
%         * CS.Z ~ the Z direction of the coordiante system.
% 
%   TrObjects - A structure containing.
%               * TrObjects.Femur ~ The whole femur triangulation.
%               * TrObjects.DistFem ~ The femur distal part triangulation.
%               * TrObjects.EpiFemASLat ~ The triangulation of the femur 
%                                         distal lateral articular surface.
%               * TrObjects.EpiFemASMed ~ The triangulation of the femur 
%                                         distal medial articular surface.
% 
% Outputs:
%   None - Plot a femur with indentified articular surfaces 
%          and coordinate system.
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function PlotFemur( CS, TrObjects, new_plot)


if new_plot == 1
    figure()
end

if ~isfield(CS,'Y') && isfield(CS,'V')
    CS.X = CS.V(:,1);
    CS.Y = CS.V(:,2);
    CS.Z = CS.V(:,3);
end
% Plot the whole tibia, here TrObjects.Femur is a Matlab triangulation object
trisurf(TrObjects.Femur,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',1,'edgecolor','none');
hold on
axis equal

% handle lighting of objects
light('Position',CS.Origin + 500*CS.Y + 500*CS.X,'Style','local')
light('Position',CS.Origin + 500*CS.Y - 500*CS.X,'Style','local')
light('Position',CS.Origin - 500*CS.Y + 500*CS.X - 500*CS.Z,'Style','local')
light('Position',CS.Origin - 500*CS.Y - 500*CS.X + 500*CS.Z,'Style','local')
lighting gouraud

% Remove grid
grid off

%% Figure 2
if isfield(TrObjects, 'DistFem') && isfield(TrObjects, 'EpiFemASLat') && isfield(TrObjects, 'EpiFemASMed')
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
    light('Position',CS.Origin + 500*CS.Y + 500*CS.X,'Style','local')
    light('Position',CS.Origin + 500*CS.Y - 500*CS.X,'Style','local')
    light('Position',CS.Origin - 500*CS.Y + 500*CS.X - 500*CS.Z,'Style','local')
    light('Position',CS.Origin - 500*CS.Y - 500*CS.X + 500*CS.Z,'Style','local')
    lighting gouraud
    
    %
    plotArrow( CS.X, 1, CS.Origin, 30, 1, 'b')
    plotArrow( CS.Y, 1, CS.Origin, 30, 1, 'r')
    plotArrow( CS.Z, 1, CS.Origin, 30, 1, 'k')
    
    % Remove grid
    grid off
    
end



end

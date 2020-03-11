function PlotFemur( CS, TrObjects, new_plot)
%PLOTTIBIA Display figures of the femur
%   Detailed explanation goes here
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

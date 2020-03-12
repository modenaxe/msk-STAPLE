function PlotTriangLight(Triang, CS, new_plot, alpha)

if nargin<3
    figure()
elseif new_plot==1
    figure()
end

if nargin<2
    CS = [];
end

% Plot the whole tibia, here TrObjects.Femur is a Matlab triangulation object
trisurf(Triang,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',alpha,'edgecolor','none');
hold on
axis equal

if ~isempty(CS)
    
    if ~isfield(CS,'Y') && isfield(CS,'V')
        CS.X = CS.V(:,1);
        CS.Y = CS.V(:,2);
        CS.Z = CS.V(:,3);
    end
    
    % handle lighting of objects
    light('Position',CS.Origin + 500*CS.Y + 500*CS.X,'Style','local')
    light('Position',CS.Origin + 500*CS.Y - 500*CS.X,'Style','local')
    light('Position',CS.Origin - 500*CS.Y + 500*CS.X - 500*CS.Z,'Style','local')
    light('Position',CS.Origin - 500*CS.Y - 500*CS.X + 500*CS.Z,'Style','local')
    lighting gouraud
end

% Remove grid
grid off

end
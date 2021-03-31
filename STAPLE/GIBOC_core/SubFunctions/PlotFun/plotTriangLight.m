%-------------------------------------------------------------------------%
%    Copyright (c) 2021 Modenese L.                                       %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
function plotTriangLight(Triang, CS, new_plot, alpha)

% TODO: add handling when there is no CS defined at all

% open a new figure plot is asked to or nothing specified
if nargin<3
    figure()
elseif new_plot==1
    figure()
end

% assign empty coord system is there is no entry
if nargin<2
    CS = [];
end

% default alpha value
if nargin<4
    alpha = 0.7;
end

% Plot the triangulation object with grey color
trisurf(Triang,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',alpha,'edgecolor','none');
hold on; axis equal

% define the lighting
if ~isempty(CS)
    
    % if there are no axes but there is a pose matrix, use the matrix as
    % reference
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
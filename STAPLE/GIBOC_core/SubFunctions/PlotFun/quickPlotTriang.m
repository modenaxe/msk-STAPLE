%-------------------------------------------------------------------------%
%    Copyright (c) 2021 Modenese L.                                       %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
function quickPlotTriang(triangObj, face_color, new_figure, alpha)

if nargin>2
    if isempty(new_figure)
        figure
    elseif new_figure == 1
        figure
    end
end

if nargin==1 || (nargin>=2 && isempty(face_color))
    face_color = [0.65    0.65    0.6290];
end

if nargin < 4
    alpha = 1;
end

trisurf(triangObj,'Facecolor', face_color,'FaceAlpha',alpha, 'edgecolor','none');
light; lighting phong; % light
hold on, axis equal

end
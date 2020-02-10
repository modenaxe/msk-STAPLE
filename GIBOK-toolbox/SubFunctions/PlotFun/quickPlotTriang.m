% 
% Author: Luca Modenese
function quickPlotTriang(triangObj, face_color, new_figure)

if nargin>2 && ~isempty(new_figure)
    figure
end
trisurf(triangObj,'Facecolor', face_color, 'edgecolor','none');
light; lighting phong; % light
hold on, axis equal

end









% 
% Author: Luca Modenese
function quickPlotTriang(triangObj, face_color, new_figure)

if nargin>2 && ~isempty(new_figure)
    figure
end

if nargin==1 || (nargin>=2 && isempty(face_color))
    face_color = [0.65    0.65    0.6290];
end

trisurf(triangObj,'Facecolor', face_color,'FaceAlpha',1, 'edgecolor','none');
light; lighting phong; % light
hold on, axis equal

end









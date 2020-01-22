function quickPlotTriang(triangObj, varargin)

if isempty(varargin)
    face_color = [0.65    0.65    0.6290];;
else
    face_color = varargin{1};
end

trisurf(triangObj,'Facecolor',face_color,'edgecolor',[0.5    0.5    0.5]);

axis equal

end
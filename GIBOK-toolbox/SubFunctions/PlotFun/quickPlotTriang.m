function quickPlotTriang(triangObj, XYZ, CenterVol, face_color)

if nargin<4
    face_color = [0.65    0.65    0.6290];
end

if nargin == 3
    
    trisurf(triangObj,'Facecolor',face_color,'FaceAlpha',.8,'edgecolor','none');
    hold on; axis equal; grid off
    
    % handle lighting of objects
    X0 = XYZ(:,1);
    Y0 = XYZ(:,2);
    Z0 = XYZ(:,3);
    light('Position',CenterVol' + 500*Y0' + 500*X0','Style','local')
    light('Position',CenterVol' + 500*Y0' - 500*X0','Style','local')
    light('Position',CenterVol' - 500*Y0' + 500*X0' - 500*Z0','Style','local')
    light('Position',CenterVol' - 500*Y0' - 500*X0' + 500*Z0','Style','local')
    lighting gouraud
    
    %Plot the inertia Axis & Volumic center
    plotDot( CenterVol', 'k', 2 )
    plotArrow( X0, 1, CenterVol, 40, 1, 'r')
    plotArrow( Y0, 1, CenterVol, 40, 1, 'g')
    plotArrow( Z0, 1, CenterVol, 40, 1, 'b')
else
    trisurf(triangObj,'Facecolor', face_color, 'edgecolor',[0.5    0.5    0.5]);
    
end









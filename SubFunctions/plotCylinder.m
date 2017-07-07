function plotCylinder( u, radius, center, Length, alpha, color)
%plotCylinder Plot a cylinder 
%(the cylinder top and bottom face are not represented)
%Plot a cylinder whose axis is determined by u and center, whose radius is radius and length is Length
%Visual Aspect of the cylinder are set by the transparency parameter 0=< alpha =<1 and the color color

% Creat an CS aligned rightly dimensionned cylinder
[X,Y,Z] = cylinder(radius,359);
Z = Z.*Length - Length/2;

Vertices_Down = [X(1,:);Y(1,:);Z(1,:)];
Vertices_Up = [X(2,:);Y(2,:);Z(2,:)];

% Align along the imposed axis orientation
Uz = u/norm(u);
Uy = cross(Uz,[1;0;0]); Uy = Uy/norm(Uy);
Ux = cross(Uy,Uz);

U = [Ux, Uy, Uz];

Vertices_Down_rot = U*Vertices_Down;
Vertices_Up_rot = U*Vertices_Up;

% Displace to the axis
Xr = [Vertices_Down_rot(1,:);Vertices_Up_rot(1,:)] + center(1) ;
Yr = [Vertices_Down_rot(2,:);Vertices_Up_rot(2,:)] + center(2) ;
Zr = [Vertices_Down_rot(3,:);Vertices_Up_rot(3,:)] + center(3) ;

% Plot
lighting gouraud
surf(Xr,Yr,Zr,'facecolor',color,'edgecolor','none',...
    'FaceAlpha',alpha,'FaceLighting','gouraud')
axis equal
hold on

end

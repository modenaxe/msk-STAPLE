function plotCylinder( u, radius, center, Length, alpha, color)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


[X,Y,Z] = cylinder(radius,359);
Z = Z.*Length - Length/2;

Vertices_Down = [X(1,:);Y(1,:);Z(1,:)];
Vertices_Up = [X(2,:);Y(2,:);Z(2,:)];

Uz = u/norm(u);
Uy = cross(Uz,[1;0;0]); Uy = Uy/norm(Uy);
Ux = cross(Uy,Uz);

U = [Ux, Uy, Uz];

Vertices_Down_rot = U*Vertices_Down;
Vertices_Up_rot = U*Vertices_Up;

Xr = [Vertices_Down_rot(1,:);Vertices_Up_rot(1,:)] + center(1) ;
Yr = [Vertices_Down_rot(2,:);Vertices_Up_rot(2,:)] + center(2) ;
Zr = [Vertices_Down_rot(3,:);Vertices_Up_rot(3,:)] + center(3) ;


lighting gouraud
surf(Xr,Yr,Zr,'facecolor',color,'edgecolor','none',...
    'FaceAlpha',alpha,'FaceLighting','gouraud')
axis equal
% light('Position',center' + 3*radius*Uy ,'Style','local')
% light('Position',center' + 3*radius*Ux ,'Style','local')
hold on
% pl3tVctrs(center,Uz,30)

end


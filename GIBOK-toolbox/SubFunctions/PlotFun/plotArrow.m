function plotArrow( u, radius, center, Length, alpha, color)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


[X,Y,Z] = cylinder(radius,359);
Z = Z.*Length;

[Xc,Yc,Zc] = cylinder(2*radius,359);
Xc(2,:)=0;
Yc(2,:)=0;
Zc = Zc*4*radius+Length;

Vertices_Down = [X(1,:);Y(1,:);Z(1,:)];
Vertices_Up = [X(2,:);Y(2,:);Z(2,:)];

Vertices_Down_C = [Xc(1,:);Yc(1,:);Zc(1,:)];
Vertices_Up_C = [Xc(2,:);Yc(2,:);Zc(2,:)];

Uz = u/norm(u);
if ~isequal(u, [1; 0; 0])
    Uy = cross(Uz,[1;0;0]); Uy = Uy/norm(Uy);
    Ux = cross(Uy,Uz);
    
else
    warning('PlotArrow has a bug here')
    Uy = [0; 1; 0] ;
    Ux = [0; 0; 1] ;
end

U = [Ux, Uy, Uz];



Vertices_Down_rot = U*Vertices_Down;
Vertices_Up_rot = U*Vertices_Up;

Vertices_Down_rot_C = U*Vertices_Down_C;
Vertices_Up_rot_C = U*Vertices_Up_C;

Xr = [Vertices_Down_rot(1,:);Vertices_Up_rot(1,:)] + center(1) ;
Yr = [Vertices_Down_rot(2,:);Vertices_Up_rot(2,:)] + center(2) ;
Zr = [Vertices_Down_rot(3,:);Vertices_Up_rot(3,:)] + center(3) ;

Xrc = [Vertices_Down_rot_C(1,:);Vertices_Up_rot_C(1,:)] + center(1) ;
Yrc = [Vertices_Down_rot_C(2,:);Vertices_Up_rot_C(2,:)] + center(2) ;
Zrc = [Vertices_Down_rot_C(3,:);Vertices_Up_rot_C(3,:)] + center(3) ;

hold on
surf(Xr,Yr,Zr,'facecolor',[0.5 0.9 0.3],'edgecolor','none',...
    'FaceAlpha',alpha,'FaceLighting','gouraud','FaceColor',color)
hold on
surf(Xrc,Yrc,Zrc,'facecolor',[0.5 0.9 0.3],'edgecolor','none',...
    'FaceAlpha',alpha,'FaceLighting','gouraud','FaceColor',color)
fill3(Xrc(1,:),Yrc(1,:),Zrc(1,:),color,'edgecolor','none',...
    'FaceAlpha',alpha,'FaceLighting','gouraud')
fill3(Xr(1,:),Yr(1,:),Zr(1,:),color,'edgecolor','none',...
    'FaceAlpha',alpha,'FaceLighting','gouraud')
axis equal
% light('Position',center' + 3*radius*Uy ,'Style','local')
% light('Position',center' + 3*radius*Ux ,'Style','local')
hold on
% pl3tVctrs(center,Uz,30)

end
% PLOTCYLINDER Plot a 3D cylinder on the current axis.
% This plot a volumetric 3D cylinder.
%
% plotCylinder( u, radius, Origin, Length, alpha, color)
%
% Inputs:
%   u - Direction of the arrow.
%   radius - The radius of the arrow shaft cylinder.
%   center - Center point along the cylinder axis.
%   Length - The length of the arrow on the plot.
%   alpha - Matlab transparency factor for plots.
%   color - Color of the arrow.
% 
% Outputs:
%   None - Plot the 3D cylinder on the current axis
%
% See also PL3TVECTORS, PLOTARROW.
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function plotCylinder( u, radius, center, Length, alpha, color)

[X,Y,Z] = cylinder(radius,359);
Z = Z.*Length - Length/2;

Vertices_Down = [X(1,:);Y(1,:);Z(1,:)];
Vertices_Up = [X(2,:);Y(2,:);Z(2,:)];

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

Xr = [Vertices_Down_rot(1,:);Vertices_Up_rot(1,:)] + center(1) ;
Yr = [Vertices_Down_rot(2,:);Vertices_Up_rot(2,:)] + center(2) ;
Zr = [Vertices_Down_rot(3,:);Vertices_Up_rot(3,:)] + center(3) ;


lighting gouraud
surf(Xr,Yr,Zr, 'facecolor',color, 'edgecolor','none',...
    'FaceAlpha',alpha, 'FaceLighting','gouraud')

% % Fill the cylinder bottom face 
% fill3(Xr(1,:), Yr(1,:), Zr(1,:), color, 'edgecolor','none',...
% 'FaceAlpha',alpha, 'FaceLighting','gouraud')

% % Fill the cylinder top face 
% fill3(Xr(2,:), Yr(2,:), Zr(2,:), color, 'edgecolor','none',...
%     'FaceAlpha',alpha, 'FaceLighting','gouraud')

axis equal
% light('Position',center' + 3*radius*Uy ,'Style','local')
% light('Position',center' + 3*radius*Ux ,'Style','local')
hold on
% pl3tVctrs(center,Uz,30)

end


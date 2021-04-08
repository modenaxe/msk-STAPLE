% PLOTARROW Plot a 3D arrow on the current axis.
% This plot a better looking quiver3 by assembling surface
% objects to construct a volumetric 3D arrow.
%
% plotArrow( u, radius, Origin, Length, alpha, color)
%
% Inputs:
%   u - Direction of the arrow.
%   radius - The radius of the arrow shaft cylinder.
%   Origin - Origin point of each vector.
%   Length - The length of the arrow on the plot.
%   alpha - Matlab transparency factor for plots.
%   color - Color of the arrow.
% 
% Outputs:
%   None - Plot the 3D arrow on the current axis
%
% See also PL3TVECTORS, PLOTCYLINDER.
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function plotArrow( u, radius, Origin, Length, alpha, color)


% Create an initial arrow +Z oriented
% Shaft of the arrow
[X,Y,Z] = cylinder(radius,359);
Z = Z*Length - 4*radius ;

% Tip of the arrow (twice as large as arrow shaft)
[Xc,Yc,Zc] = cylinder(2*radius,359);
Xc(2,:)=0;
Yc(2,:)=0;
Zc = Zc*4*radius + Length;

Vertices_Down = [X(1,:);Y(1,:);Z(1,:)];
Vertices_Up = [X(2,:);Y(2,:);Z(2,:)];

Vertices_Down_C = [Xc(1,:);Yc(1,:);Zc(1,:)];
Vertices_Up_C = [Xc(2,:);Yc(2,:);Zc(2,:)];

% Construct then apply a rotation-translation transformation
% to the generic arrow
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

Xr = [Vertices_Down_rot(1,:);Vertices_Up_rot(1,:)] + Origin(1) ;
Yr = [Vertices_Down_rot(2,:);Vertices_Up_rot(2,:)] + Origin(2) ;
Zr = [Vertices_Down_rot(3,:);Vertices_Up_rot(3,:)] + Origin(3) ;

Xrc = [Vertices_Down_rot_C(1,:);Vertices_Up_rot_C(1,:)] + Origin(1) ;
Yrc = [Vertices_Down_rot_C(2,:);Vertices_Up_rot_C(2,:)] + Origin(2) ;
Zrc = [Vertices_Down_rot_C(3,:);Vertices_Up_rot_C(3,:)] + Origin(3) ;

hold on
% Plot the shaft
surf(Xr, Yr, Zr, 'edgecolor','none', ...
    'FaceAlpha',alpha, 'FaceLighting','gouraud', 'FaceColor',color)

% Plot the tip
surf(Xrc, Yrc, Zrc, 'edgecolor','none', ...
    'FaceAlpha',alpha, 'FaceLighting','gouraud', 'FaceColor',color)

% Fill the shaft bottom face 
fill3(Xr(1,:), Yr(1,:), Zr(1,:), color, 'edgecolor','none',...
    'FaceAlpha',alpha, 'FaceLighting','gouraud')
    
% Fill the tip bottom face
fill3(Xrc(1,:), Yrc(1,:), Zrc(1,:), color, 'edgecolor','none',...
    'FaceAlpha',alpha, 'FaceLighting','gouraud')

axis equal
% light('Position',Origin' + 3*radius*Uy ,'Style','local')
% light('Position',Origin' + 3*radius*Ux ,'Style','local')
hold on
% pl3tVctrs(Origin,Uz,30)

end
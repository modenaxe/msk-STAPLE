% Test with ellipsoid produced using NMSBuilder
% the ellipsoid has 
% Rx = 3; 
% Ry = 5;
% Rz = 2;

clear;clc; close all

% reads coordinate of rototranslated ellipsoid
[v, f, n, c, stltitle] = stlread('Ellipsoid_rototraslated.stl', 1);
% calculating inertial parameters
InertiaInfo  = calcInertiaMatrix(v);
% PLOTTING: 1) ELLIPSOID
plot3(v(:,1),v(:,2),v(:,3),'.'); hold on;axis equal;grid on
% PLOTTING: 2) INERTIAL AXES (nb for my plotting function I have to use ')
plot_refsyst(gca, InertiaInfo.COM, InertiaInfo.PrincAxes', 10);

% apply transformation:
% now the ellipsoid should be centered at the origin, and inertial axes aligned
% with main axes
v = transfMeshPointsRefSyst(v, InertiaInfo.COM, InertiaInfo.PrincAxes);
plot3(v(:,1),v(:,2),v(:,3),'r.'); hold on;axis equal;grid on
plot_refsyst(gca, [0 0 0], eye(3), 10);


% VALIDATION SET FROM BUILDER
% Ellisoid in the center
[v_val, f, n, c, stltitle] = stlread('Ellipsoid.stl', 1);
% transformation matrix
Transf_Mat = [0.489081 -0.271102 0.829038   5 
              0.737817 0.635527 -0.227444   7 
              -0.465215 0.722917 0.510848   12 
              0         0           0       1 ];

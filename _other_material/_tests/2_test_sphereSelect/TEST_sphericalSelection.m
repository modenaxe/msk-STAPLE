% Test with ellipsoid produced using NMSBuilder
% the ellipsoid has 
% Rx = 3; 
% Ry = 5;
% Rz = 2;

clear;clc; close all

% reads coordinate of rototranslated ellipsoid
[v0, f0, n, c, stltitle] = stlread('Ellipsoid_rototraslated.stl', 1);
[v, f]=patchslim(v0, f0);
% calculating inertial parameters
InertiaInfo  = calcInertiaMatrix(v);

% PLOTTING: 1) ELLIPSOID
% plot3(v(:,1),v(:,2),v(:,3),'.'); hold on;axis equal;grid on
patch('Faces',f,'Vertices',v,'FaceColor',[0.5 0.5 0.5]); hold on;axis equal;grid on
% PLOTTING: 2) INERTIAL AXES (nb for my plotting function I have to use ')
plot_refsyst(gca, InertiaInfo.COM, InertiaInfo.PrincAxes', 10);


%====================== script version ==========================

%========= SETTINGS =========
% select a point
P = [3.938, 4.154, 12.67];
% and a sphere radius
Radius = 2;
%============================

% building vector for vectorial difference
P_vec = ones(size(v,1),1)*P;

% calculate distance between P and all points in mesh
dist = (sum((v-P_vec).^2.0, 2)).^0.5;

% logic indeces of vectors inside the sphere
ind_v_int = dist<Radius;

% verteces of the ellipsoid inside the sphere
v_int = v(ind_v_int,:);

% plot identified verteces
plot3(P(1),P(2),P(3),'ko', 'Markersize', 15), hold on
plot3(v_int(:,1),v_int(:,2),v_int(:,3),'r*', 'Markersize', 10)
% plot sphere
[x,y,z] = sphere;
surf(Radius*x+P(1),Radius*y+P(2),Radius*z+P(3),'FaceAlpha', 0.3, 'FaceColor',[1 0 0]); hold on


%============ FUNCTION VERSION ======================
clear v_int

[v_subset, v_subset_ind] = getVerticesWithinSphere(v, P, Radius);
%====================================================

% get faces subset
[f_subset, f_subset_ind] = getFacetsFromVertices(v, f, v_subset, 'include');
patch('Faces',f_subset,'Vertices',v,'FaceColor','g');

n_subset = n(f_subset_ind, :);

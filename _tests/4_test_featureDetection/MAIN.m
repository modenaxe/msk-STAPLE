% Test with ellipsoid produced using NMSBuilder
% the ellipsoid has 
% Rx = 3; 
% Ry = 5;
% Rz = 2;

clear;clc; close all
addpath(genpath('../SupportFunctions'))

% reads coordinate of rototranslated ellipsoid
[v0, f0, n, c, stltitle] = stlread('Ellipsoid_rototraslated.stl', 1);
[v, f]=patchslim(v0, f0);

% PLOTTING: 1) ELLIPSOID
patch('Faces',f,'Vertices',v,'FaceColor',[0.5 0.5 0.5]); hold on;axis equal;grid on

%========= SETTINGS =========
% select a point
P = [3.938, 4.154, 12.67];
% and a sphere radius
Radius = 2;

% sphere
[x,y,z] = sphere;
surf(Radius*x+P(1),Radius*y+P(2),Radius*z+P(3),'FaceAlpha', 0.3, 'FaceColor',[1 0 0]); hold on
%============================

% use sphere intersection
[v_subset, v_subset_ind] = getVerticesWithinSphere(v, P, Radius);

% get faces subset
[f_subset, f_subset_ind] = getFacetsFromVertices(v, f, v_subset, 'include');
patch('Faces',f_subset,'Vertices',v,'FaceColor','g');

% plot identified verteces
f_subset_v = [v(f_subset(:,1),:), v(f_subset(:,2),:), v(f_subset(:,3),:)];
COMs = (v(f_subset(:,1),:)+v(f_subset(:,2),:)+v(f_subset(:,3),:))/3;
n_subset = n(f_subset_ind,:);



for n_ind= 1:size(n_subset,1)
     n_subset_norm(n_ind,:) = n_subset(n_ind,:)/norm(n_subset(n_ind,:));
end

n_vec_plot = COMs+n_subset_norm;

for n_ind= 1:size(COMs,1)
    plot3([COMs(n_ind,1),n_vec_plot(n_ind,1)], [COMs(n_ind,2),n_vec_plot(n_ind,2)], [COMs(n_ind,3),n_vec_plot(n_ind,3)], '-b', 'Linewidth',2)
end

v_subset_nr = find(v_subset_ind);
for n_ind =1:size(v_subset,1)
    cur_v = v_subset(n_ind,:);
    n_vert(n_ind,1:3) = calcNormalAtVertex(v,f,n,cur_v);
%     plot('')
    plot3([cur_v(1),cur_v(1)+n_vert(n_ind,1)], [cur_v(2),cur_v(2)+n_vert(n_ind,2)], [cur_v(3),cur_v(3)+n_vert(n_ind,3)], '-r', 'Linewidth',2)
end

plot3(P(1),P(2),P(3),'ko', 'Markersize', 15), hold on
plot3(v_int(:,1),v_int(:,2),v_int(:,3),'r*', 'Markersize', 10)


n_subset = n_ind(f_subset_ind, :);

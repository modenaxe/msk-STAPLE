clear;clc; close all


[v, f, n, c, stltitle] = stlread('Femur_r.stl', 1);

% FEMUR R COM MEshlab
% 351.997864 257.376434 -653.661987

% meshlab
% Thin shell barycenter 118.164619 265.227966 -642.188660
% Center of Mass is 118.519882 265.340149 -650.006958
% matlab(POINTS BARICENTER): 118.3803  265.5279 -639.6645

COM_matlab = mean(v);

% if DX: lateral condyle
ind_points = find(v(:,1)<0 & v(:,2)>0 & v(:,3)>0);
% face_matr = zeros(size(f));
% for n = 1:length(ind_points)
%     n
%     curr_point = ind_points(n);
%     face_matr = face_matr+(f(:,:) == curr_point);
% end
% ind_faces = find(f(:,1)=ind_points & f(:,2)==ind_points & f(:,3)==ind_points)
v_proc =   v(ind_points,:);
% patch('Faces',f,'Vertices',v_proc);hold on
plot3(v_proc(:,1),v_proc(:,2),v_proc(:,3),'.'); hold on;axis equal;grid on

% condyle
[x,lat_cond] = max(v_proc(:,3));
plot3(v_proc(lat_cond,1),v_proc(lat_cond,2),v_proc(lat_cond,3),'o', 'MarkerEdgeColor','r','MarkerFaceColor','r')
hold on
% lower point (1)
[x,low_fem] = max(v_proc(:,2));
plot3(v_proc(low_fem,1),v_proc(low_fem,2),v_proc(low_fem,3),'o', 'MarkerEdgeColor','r','MarkerFaceColor','r')
% lower point (2)
dist = (v_proc(:,1).^2.0+v_proc(:,2).^2.0+v_proc(:,3).^2.0).^0.5;
[x,low_fem2] = max(dist);
plot3(v_proc(low_fem2,1),v_proc(low_fem2,2),v_proc(low_fem2,3),'o', 'MarkerEdgeColor','k','MarkerFaceColor','k')
% front point
[x,low_fem2] = max(v_proc(:,1));


% if DX medial condyle
v_proc = v(v(:,2)>0 & v(:,1)<0 & v(:,3)<0,:);
figure
plot3(v_proc(:,1),v_proc(:,2),v_proc(:,3),'.'); axis equal;grid on

% if DX: great trochanter bit
v_proc = v(v(:,2)<0 & v(:,1)>0 & v(:,3)>0,:);
figure
plot3(v_proc(:,1),v_proc(:,2),v_proc(:,3),'.'); axis equal;grid on

% if DX Head
v_proc = v(v(:,2)<0 & v(:,1)>0 & v(:,3)<0,:);
figure
plot3(v_proc(:,1),v_proc(:,2),v_proc(:,3),'.'); axis equal;grid on

% femur left
[v, f, n, c, stltitle] = stlread('Femur_l_untouched.stl', 1);

COM = mean(v);
figure
plot3(v(:,1),v(:,2),v(:,3),'.'); axis equal;grid on

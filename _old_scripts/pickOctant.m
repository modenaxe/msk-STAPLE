clear;clc; close all

[v, f, n, c, stltitle] = stlread('./Test_Femur/Femur_l_Poisson2.stl', 1);
[v, f, n, c, stltitle] = stlread('./Test_Pelvis/Pelvis_single_file.stl', 1);
%[v, f, n, c, stltitle] = stlread('./Test_Pelvis/Pelvis_NO_SACRUM_single_file.stl', 1);
PointCloud = v;
InertiaInfo  = calcInertiaMatrix(PointCloud);
v = transfMeshPointsRefSyst(v, InertiaInfo.COM, InertiaInfo.PrincAxes);

% oct_vec = getOctSignVector(oct_id);

% calculate inertial properties
PointCloud = v;
color_set = {'b','r','g','y','k','m','c','r'};

for n = 1:8
%     subplot(1,2,2);
    v_oct2 = pickPointsInOctant(v, n);
    plot3(v_oct2(:,1),v_oct2(:,2),v_oct2(:,3),'.','Color',color_set{n}); hold on;axis equal;grid on
end

% % n_col  = 1;
% % for x = [1, -1]
% %     for y = [1, -1]
% %         for z = [1, -1]
% %             v_oct = v(x*v(:,1)>0 & y*v(:,2)>0 & z*v(:,3)>0,:);
% % %             subplot(1,2,1)
% % %             plot3(v_oct(:,1),v_oct(:,2),v_oct(:,3),'.','Color',color_set{n_col}); hold on;axis equal;grid on
% %             n_col = n_col +1;
% %         end
% %     end
% % end
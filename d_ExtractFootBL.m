% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %
clear;clc; close all

% [v_MRI, f, n, c, stltitle] = stlread('./Test_Foot/R_Midfoot_12m.stl', 1);
[v_MRI1, f, n, c, stltitle] = stlread('./Test_Geometries/calcn_r.stl', 1);
% [v_MRI2, f, n, c, stltitle] = stlread('./Test_Foot/R_Midfoot_12m.stl', 1);
% [v_MRI3, f, n, c, stltitle] = stlread('./Test_Foot/R_Toes_12m.stl', 1);
% [v_MRI4, f, n, c, stltitle] = stlread('./Test_Foot/R_Hindfoot_Talus_12m.stl', 1);

% v_MRI = [v_MRI1;v_MRI2;v_MRI3;v_MRI4];
v_MRI = [v_MRI1];
% makes left femur becoming right
% side = 1;
% if side == -1
%     v(:,2) = -v(:,2);
% end

PointCloud = [v_MRI];

InertiaInfo  = calcInertiaMatrix(PointCloud);

v = transfMeshPointsRefSyst(v_MRI, InertiaInfo.COM, InertiaInfo.PrincAxes);
color_set = {'b','r','g','y','k','m','c','r'};
plot3(v(:,1),v(:,2),v(:,3),'.','Color',color_set{1}); hold on;grid on;axis equal

plot_refsyst(gca, [0 0 0], eye(3), 200); hold on;axis equal;grid on


Markers.FRONT = getBonyLandmark(v,'min','x');
Markers.BACK = getBonyLandmark(v,'max','x');


% plot bony landmarks with label
label_switch = 1;
% plotBL(Markers, label_switch);


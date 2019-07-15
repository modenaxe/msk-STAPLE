% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 % 
% ----------------------------------------------------------------------- %
%
% first version of detection script.
% abandoned and improved (labels on markers, more markers, etc etc).
% HOWEVER, HERE I WENT THROUGH THE OCTANTS TO CHECK HOW TO IDENTIFY THE
% BONY LANDMARKS

clear;clc; close all

addpath(genpath('./SupportFunctions'))
% ======================= SETTINGS ===========================
% GEOMETRIES WITHOUT SACRUM
geom_folder = './Test_Geometries/Test_Pelvis';
% bone_geom_file = 'Pelvis_single_file.stl';
% bone_geom_file = 'Pelvis_NO_SACRUM_single_file.stl';
bone_geom_file = 'IGG-RF-25122000- Pelvis_no_sacrum.stl';
%=============================================================

% import mesh
stl_file_path = fullfile(geom_folder, bone_geom_file);
[v_MRI, f, n, c, stltitle] = stlread(stl_file_path, 1);
PointCloud = v_MRI;
InertiaInfo  = calcInertiaMatrix(PointCloud);
v = transfMeshPointsRefSyst(v_MRI, InertiaInfo.COM, InertiaInfo.PrincAxes);

% calculate inertial properties
PointCloud = v;
color_set = {'b','r','g','y','k','m','c','r'};

%======== OCTREE 1 =========
v_oct1 = pickPointsInOctant(v, 1);
LASI = getBonyLandmark(v_oct1,'max','z');
LICT = getBonyLandmark(v_oct1,'max','x');
plot3(v_oct1(:,1),v_oct1(:,2),v_oct1(:,3),'.','Color',color_set{1}); hold on;axis equal;grid on
plot3(gca, LASI(1), LASI(2), LASI(3),'o', 'MarkerSize',15,'MarkerEdgeColor','k','MarkerFaceColor','r','Linewidth',2,'Color','r'); hold on
% plot_refsyst(gca, LASI, eye(3), 10);
% plot_refsyst(gca, LICT, eye(3), 10);

%======== OCTREE 2 =========
v_oct2 = pickPointsInOctant(v, 2);
RASI = getBonyLandmark(v_oct2,'max','z');
RICT = getBonyLandmark(v_oct2,'min','x');
plot3(v_oct2(:,1),v_oct2(:,2),v_oct2(:,3),'.','Color',color_set{2}); hold on;axis equal;grid on
plot_refsyst(gca, RASI, eye(3), 10);
plot_refsyst(gca, RICT, eye(3), 10);

%======== OCTREE 3 =========
v_oct3 = pickPointsInOctant(v, 3);
RPTUB = getBonyLandmark(v_oct3,'max','z');
% RAIIS = getBonyLandmark(v_oct2,'max','yx');
plot3(v_oct3(:,1),v_oct3(:,2),v_oct3(:,3),'.','Color',color_set{3}); hold on;axis equal;grid on
plot_refsyst(gca, RPTUB, eye(3), 10);

%======== OCTREE 4 =========
v_oct4 = pickPointsInOctant(v, 4);
LPTUB = getBonyLandmark(v_oct4,'max','z');
% RAIIS = getBonyLandmark(v_oct2,'max','yx');
plot3(v_oct4(:,1),v_oct4(:,2),v_oct4(:,3),'.','Color',color_set{4}); hold on;axis equal;grid on
plot_refsyst(gca, LPTUB, eye(3), 10);

%======== OCTREE 5 =========
v_oct5 = pickPointsInOctant(v, 5);
LPSIS = getBonyLandmark(v_oct5,'min','z');
plot3(v_oct5(:,1),v_oct5(:,2),v_oct5(:,3),'.','Color',color_set{5}); hold on;axis equal;grid on
plot_refsyst(gca, LPSIS, eye(3), 10);

%======== OCTREE 6 =========
v_oct6 = pickPointsInOctant(v, 6);
RPSIS = getBonyLandmark(v_oct6,'min','z');
plot3(v_oct6(:,1),v_oct6(:,2),v_oct6(:,3),'.','Color',color_set{6}); hold on;axis equal;grid on
plot_refsyst(gca, RPSIS, eye(3), 10);

%======== OCTREE 7 =========
v_oct7 = pickPointsInOctant(v, 7);
RLPP = getBonyLandmark(v_oct7,'min','y');
RIIT = getBonyLandmark(v_oct7,'min','z');
plot3(v_oct7(:,1),v_oct7(:,2),v_oct7(:,3),'.','Color',color_set{7}); hold on;axis equal;grid on
plot_refsyst(gca, RLPP, eye(3), 10);
plot_refsyst(gca, RIIT, eye(3), 10);

%======== OCTREE 8 =========
v_oct8 = pickPointsInOctant(v, 8);
LLPP = getBonyLandmark(v_oct8,'min','y');
LIIT = getBonyLandmark(v_oct8,'min','z');
plot3(v_oct8(:,1),v_oct8(:,2),v_oct8(:,3),'.','Color',color_set{5}); hold on;axis equal;grid on
plot_refsyst(gca, LLPP, eye(3), 10);
plot_refsyst(gca, LIIT, eye(3), 10);

% GLOBAL REF 
plot_refsyst(gca, [0 0 0], eye(3), 100);
plot_refsyst(gca, [0 0 0], eye(3), 100);
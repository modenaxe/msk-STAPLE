%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('GIBOC-toolbox'));
addpath('autoMSK_functions');
addpath(genpath('FemPatTibACS/KneeACS/Tools'));

%----------
% SETTINGS
%----------
results_folder = 'results_ACS_estimations';
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'P0_MRI', 'JIA_MRI'};
in_mm = 1;
cur_bone_set = {'femur_r','tibia_r'};
results_plots = 1;
%----------

if ~isfolder(results_folder); mkdir(results_folder); end
nf = 1;

cur_bone = 'tibia_r';
for n_d = 1:numel(dataset_set)
    
    % setup folders
    cur_dataset = dataset_set{n_d};
    main_ds_folder =  ['test_geometries',filesep,cur_dataset];
    cur_geom_file = fullfile(main_ds_folder,'tri', cur_bone);
    cur_bone_name = strrep(cur_bone,'_',' ');
    
    % load the femur and split it on prox and dist
    cur_tibia = load_mesh(cur_geom_file);
    [ProxTibia, DistTibia] = cutLongBoneMesh(cur_tibia);
    unitedTibia = TriUnite(DistTibia, ProxTibia);
    
    figure('Name',['comparison of options-',cur_dataset])
    subplot(1,3,1);     quickPlotTriang(cur_tibia); title(['full ',cur_bone_name])
    subplot(1,3,2);     quickPlotTriang(ProxTibia); title(['proximal ',cur_bone_name])
    subplot(1,3,3);     quickPlotTriang(unitedTibia); title(['proximal+distal ',cur_bone_name])
    
    % full tibia
    V_all_PCA = pca(cur_tibia.Points);
    V_all_Inertia = TriInertiaPpties( cur_tibia );
    angle_PCA_Inertia(n_d)     = acosd(dot(V_all_PCA(:,3), V_all_Inertia(:,3)));
    
    % partial tibia
    V_all_PCA = pca(ProxTibia.Points);
    V_all_Inertia_ProxTibia = TriInertiaPpties( ProxTibia );
    angle_PCA_Inertia_partial(n_d)     = acosd(dot(V_all_PCA(:,3), V_all_Inertia_ProxTibia(:,3)));
    
    %united tibia
    V_all_PCA = pca(unitedTibia.Points);
    V_all_Inertia_unitedTibia = TriInertiaPpties( unitedTibia );
    angle_PCA_Inertia_united(n_d)     = acosd(dot(V_all_PCA(:,3), V_all_Inertia_unitedTibia(:,3)));
end

% adjusting angles > 90 (axes not pointing in the same direction)
angle_PCA_Inertia(:, angle_PCA_Inertia>90) = 180 - angle_PCA_Inertia(:, angle_PCA_Inertia>90);
angle_PCA_Inertia_partial(:, angle_PCA_Inertia_partial>90) = 180 - angle_PCA_Inertia_partial(:, angle_PCA_Inertia_partial>90);
angle_PCA_Inertia_united(:, angle_PCA_Inertia_united>90) = 180 - angle_PCA_Inertia_united(:, angle_PCA_Inertia_united>90);

% table of results: angular difference between PCA and Inertial long axes
% on the tibia
PCA_vs_Inert_table = table(angle_PCA_Inertia', angle_PCA_Inertia_partial', angle_PCA_Inertia_united',...
                     'VariableNames',{['full ',cur_bone_name], ['proximal ',cur_bone_name], ['proximal and distal ',cur_bone_name]},...
                     'RowNames', {'LHDL-CT', 'TLEM-CT', 'ICL-MRI', 'JIA-MRI'});
                 
disp(PCA_vs_Inert_table)
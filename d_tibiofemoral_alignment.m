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
results_folder = 'results_tibio_femoral_alignment';
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'P0_MRI', 'JIA_MRI'};
in_mm = 1;
bone_set = { 'femur_r', 'tibia_r'};
results_plots = 0;
%----------

if ~isfolder(results_folder); mkdir(results_folder); end
nf = 1;

cur_bone = 'tibia_r';
for n_d = 4%1:3%numel(dataset_set)
    
    % setup folders
    cur_dataset = dataset_set{n_d};
    main_ds_folder =  ['test_geometries',filesep,cur_dataset];
    
    % compute femur JCS
    cur_fem_file = fullfile(main_ds_folder,'tri',  'femur_r');
    fem_triang = load_mesh(cur_fem_file);
    [~, JCSFem] = GIBOK_femur(fem_triang, [], 'cylinder', results_plots);
    
    % load the femur and split it on prox and dist
    cur_geom_file = fullfile(main_ds_folder,'tri',  cur_bone);
    bone_triang = load_mesh(cur_geom_file);
    [ProxFem, DistFem] = cutLongBoneMesh(bone_triang);
    
    % Get eigen vectors V_all of the Femur 3D geometry and volumetric center
    [ CS.V_all, CS.CenterVol ] = TriInertiaPpties(bone_triang);
    % take the long direction for femur
    CS.Z0 = CS.V_all(:,1);
    CoeffMorpho = computeTriCoeffMorpho(bone_triang);
    
    
    try
        [CS1, JCS1] = Miranda2010_buildtACS(bone_triang);
    catch
        JCS1.knee_r.Origin = nan(1,3);
        JCS1.knee_r.V = nan(3,3);
    end
    [CS2, JCS2] = CS_tibia_Kai2014(bone_triang, [], results_plots);
    [CS3, JCS3] = GIBOK_tibia(bone_triang, [], 'plateau', results_plots);
    [CS4, JCS4] = GIBOK_tibia(bone_triang, [], 'ellipse', results_plots);
    [CS5, JCS5] = GIBOK_tibia(bone_triang, [], 'centroids', results_plots);
    table_head = {'KneeJointCentre_tibia_v_mm', 'Dist_norm_mm' 'KneeJointAxis_tibia', 'Ang_diff_deg'};
    methods_list = {'Miranda2010','Kai2014','GIBOK-Plateau','GIBOK-Ellipse','GIBOK-Centroids'};
    
    joint_centres = [  JCS1.knee_r.Origin;
        JCS2.knee_r.Origin;
        JCS3.knee_r.Origin;
        JCS4.knee_r.Origin;
        JCS5.knee_r.Origin];
    
    % compute angular deviations
    
    % cylinder fit chosen as reference - easy to change
    ref_JCS = JCSFem;
    
    
    % compute metrics (distance vectors in ref femur/tibia coord frame)
    orig_diff = (ref_JCS.knee_r.V'*(joint_centres - ref_JCS.knee_r.Origin)')';
    orig_dist = sqrt(sum(orig_diff.^2, 2));
    
    for naxis = 1:3
        joint_axis =[JCS1.knee_r.V(:,naxis)';
            JCS2.knee_r.V(:,naxis)';
            JCS3.knee_r.V(:,naxis)';
            JCS4.knee_r.V(:,naxis)';
            JCS5.knee_r.V(:,naxis)'];
        ang_diff(:,naxis) = acosd(joint_axis*ref_JCS.knee_r.V(:,naxis));
    end
    
    % second option
    row_ind = n_d:numel(dataset_set):numel(methods_list)*numel(dataset_set);
    orig_diff_opt2(row_ind,:) = orig_diff;
    orig_dist_opt2(row_ind,:) = orig_dist;
    ang_diff_opt2(row_ind,:) = ang_diff;
    
    % table with results (one per method)
    %         res_table = table(orig_diff, orig_dist, joint_axis, ang_diff, ...
    %                           'VariableNames',table_head);
    %         res_table.Properties.RowNames = methods_list;
    %         writetable(res_table,fullfile(results_folder, [cur_bone,'_', cur_dataset,'.xlsx']));
    
    
    clear JCS1 JCS2 JCS3 JCS4 JCS5 ref_JCS ang_diff orig_dist orig_diff bone_triang
    
    close all
end
%
res_table2 = table(orig_diff_opt2, orig_dist_opt2, ang_diff_opt2, ...
    'VariableNames',table_head([1,2,4]));
writetable(res_table2,fullfile(results_folder, [cur_bone,'_tibio-femoral_alignment.xlsx']));

clear orig_diff_opt2 orig_dist_opt2 ang_diff_opt2



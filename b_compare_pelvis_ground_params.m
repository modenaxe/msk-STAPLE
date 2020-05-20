%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('GIBOK-toolbox'));
addpath('autoMSK_functions');
addpath(genpath('FemPatTibACS/KneeACS/Tools'));

%----------
% SETTINGS
%----------
results_folder = 'results_ACS_estimations';
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'P0_MRI', 'JIA_MRI'};
in_mm = 1;
bone_set = { 'pelvis_no_sacrum'};
results_plots = 1;
%----------

table_head = {'PelvisGroundJointCentre_v_mm', 'Dist_norm_mm' 'PelvisGroundJointAxis_femur', 'Ang_diff_deg'};
methods_list = {'Kai2014','GIBOC'};

if ~isfolder(results_folder); mkdir(results_folder); end
nf = 1;
for nb = 1:numel(bone_set)
    cur_bone = bone_set{nb};
    
    for n_d = 1:numel(dataset_set)
        % setup folders
        cur_dataset = dataset_set{n_d};
        main_ds_folder =  ['test_geometries',filesep,cur_dataset];
        cur_geom_file = fullfile(main_ds_folder,'tri', cur_bone);
        
        % load the femur and split it on prox and dist
        Pelvis = load_mesh(cur_geom_file);
        
        [CS1, JCS1] = GIBOK_pelvis(Pelvis, results_plots, 0);
        [CS2, JCS2] = CS_pelvis_Kai2014(Pelvis, results_plots, 0);
        
        joint_centres = [  JCS1.ground_pelvis.Origin';
            JCS2.ground_pelvis.Origin'];
        
        % Kai2013 chosen as reference - easy to change
        ref_JCS = JCS2;
        
        % compute metrics (distance vectors in ref femur/tibia coord frame)
        orig_diff = (ref_JCS.ground_pelvis.V'*(joint_centres - ref_JCS.ground_pelvis.Origin')')';
        orig_dist = sqrt(sum(orig_diff.^2, 2));
        
        for naxis = 1:3
            joint_axis = [JCS1.ground_pelvis.V(:,naxis)'; JCS2.ground_pelvis.V(:,naxis)'];
            ang_diff(:,naxis) = acosd(joint_axis*ref_JCS.ground_pelvis.V(:,naxis));
        end
        % equivalent better way to avoid loop
%         ang_offset_child = acosd(diag(JCS1.ground_pelvis.V'*JCS2.ground_pelvis.V));
        
        % second option
        row_ind = n_d:numel(dataset_set):numel(methods_list)*numel(dataset_set);
        orig_diff_opt2(row_ind,:) = orig_diff;
        orig_dist_opt2(row_ind,:) = orig_dist;
        ang_diff_opt2(row_ind,:) = ang_diff;
        
        % table with results (one per method)
        res_table = table(orig_diff, orig_dist, joint_axis, ang_diff, ...
            'VariableNames',table_head);
        res_table.Properties.RowNames = methods_list;
        writetable(res_table,fullfile(results_folder, [cur_bone,'_', cur_dataset,'.xlsx']));
        
        clear JCS1 JCS2 JCS3 JCS4 JCS5
        
        close all
    end
    %
    res_table2 = table(orig_diff_opt2, orig_dist_opt2, ang_diff_opt2, ...
        'VariableNames',table_head([1,2,4]));
    writetable(res_table2,fullfile(results_folder, [cur_bone,'_summary_of_method.xlsx']));
    
    clear orig_diff_opt2 orig_dist_opt2 ang_diff_opt2
end


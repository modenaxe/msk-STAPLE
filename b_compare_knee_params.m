%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('GIBOC-toolbox'));
addpath(genpath('autoMSK_functions'));
addpath(genpath('FemPatTibACS/KneeACS/Tools'));

%----------
% SETTINGS
%----------
results_folder = 'results_ACS_estimations';
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'P0_MRI', 'JIA_MRI'};
in_mm = 1;
bone_set = { 'femur_r', 'tibia_r'};
results_plots = 0;
%----------

if ~isfolder(results_folder); mkdir(results_folder); end
nf = 1;
for nb = 2
    cur_bone = bone_set{nb};
    for n_d = 1:numel(dataset_set)    
        % setup folders
        cur_dataset = dataset_set{n_d};
        main_ds_folder =  ['test_geometries',filesep,cur_dataset];
        cur_geom_file = fullfile(main_ds_folder,'tri', cur_bone);
        
        % load the femur and split it on prox and dist
        bone_triang = load_mesh(cur_geom_file);
        [ProxFem, DistFem] = cutLongBoneMesh(bone_triang);
        
        % Get eigen vectors V_all of the Femur 3D geometry and volumetric center
        [ CS.V_all, CS.CenterVol ] = TriInertiaPpties(bone_triang);
        % take the long direction for femur
        CS.Z0 = CS.V_all(:,1);
        CoeffMorpho = computeTriCoeffMorpho(bone_triang);
        
        switch cur_bone
            case 'femur_r'
                try
                    [CS1, JCS1] = Miranda2010_buildfACS(bone_triang);
                catch
                    JCS1.knee_r.Origin = nan(1,3); 
                    JCS1.knee_r.V = nan(3,3);
                end
                [CS2, JCS2] = CS_femur_Kai2014(bone_triang, [], results_plots);
                [CS3, JCS3] = GIBOK_femur(bone_triang, [], 'spheres', results_plots);
                [CS4, JCS4] = GIBOK_femur(bone_triang, [], 'ellipsoids', results_plots);
                [CS5, JCS5] = GIBOK_femur(bone_triang, [], 'cylinder', results_plots);
                table_head = {'KneeJointCentre_femur_dist_v_mm', 'Dist_norm_mm' 'KneeJointAxis_femur', 'Ang_diff_deg'};
                methods_list = {'Miranda2010','Kai2014','GIBOK-Sphere','GIBOK-Ellipsoids','GIBOK-Cylinder'};
            case 'tibia_r'
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
            otherwise
        end
        joint_centres = [  JCS1.knee_r.Origin;
                                    JCS2.knee_r.Origin;
                                    JCS3.knee_r.Origin;
                                    JCS4.knee_r.Origin;
                                    JCS5.knee_r.Origin];
        
        % compute angular deviations
        switch cur_bone
            case 'femur_r'
                % cylinder fit chosen as reference - easy to change
                ref_JCS = JCS5;
            case 'tibia_r'
                % Kai2013 chosen as reference - easy to change
%                 ref_JCS = JCS2;
                [CS, ref_JCS] = CRACK_tibia(bone_triang, [], results_plots);
                
        end
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
        writetable(res_table2,fullfile(results_folder, [cur_bone,'_summary_of_method.xlsx']));
        
        clear orig_diff_opt2 orig_dist_opt2 ang_diff_opt2
end


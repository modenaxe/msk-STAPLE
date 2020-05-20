%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clearvars;  close all

model_set = {'LHDL_CT', 'TLEM2_CT', 'P0_MRI', 'JIA_MRI'};
% modelling_method = 'Modenese2018P';
modelling_method = 'Modenese2018';
osim_model_folder = './opensim_models';
results_folder = './validation';

N_datasets = numel(model_set);
for n_d = 1:N_datasets
    cur_model = model_set{n_d};
    
    % create joint structures for easy comparison
    auto = createJointParamsMatStructFromOsimModel([osim_model_folder,filesep,'manual_',cur_model,'.osim']);
    manual = createJointParamsMatStructFromOsimModel([osim_model_folder,filesep,modelling_method,'_',cur_model,'.osim']);
    
    % check if identical ground ref syst (essential - meaning model built in
    % same reference frame)
    assert(isequal(auto.ground_pelvis.parent-manual.ground_pelvis.parent, zeros(4)))
    
    % Offsets
    joint_list = fields(auto);
    N_joint = numel(joint_list);
    for n = 1:N_joint
        cur_joint_name = joint_list{n};
        % compute joint centre offsets in mm (identical for child and
        % parent)
        jc_offset(n, :) = (auto.(cur_joint_name).child(1:3,4) - manual.(cur_joint_name).child(1:3,4))*1000;
        % compute angular offsets for child reference systems
        ang_offset_child(n,:) = acosd(diag(auto.(cur_joint_name).child(1:3,1:3)'*manual.(cur_joint_name).child(1:3,1:3)));
        % compute angular offsets for parent reference systems
        ang_offset_parent(n,:) = acosd(diag(auto.(cur_joint_name).parent(1:3,1:3)'*manual.(cur_joint_name).parent(1:3,1:3)));
        
    end
    
    %------------- COMPLETE EVALUATION ------------------------------------
    % build a table to visualise all differences in all joint parameters
    cur_res_table = table(  jc_offset, ang_offset_parent, ang_offset_child,...
                                'VariableNames',{'JC-Offset_mm', 'Angular_offset_parent_JCS (XYZ)','Angular_offset_child_JCS (XYZ)'});
    cur_res_table.Properties.RowNames = {'pelvis_ground' 'hip_r' 'knee_r' 'ankle_r' 'subtalar_r'};
    cur_res_table.Properties.Description = cur_model;
    cur_res_table.Properties.VariableUnits = {'mm', 'deg', 'deg'};
    
    % store structure of results
    validation_tables(n_d) = {cur_res_table};
    
    % write results on xlsx file
    writetable(cur_res_table, [results_folder,filesep,'valid_results_',cur_model,'.xlsx']);
    
    % clear variables
    clear jc_offset ang_offset_child ang_offset_parent cur_res_table
end

clc
% display all tables of results
for nt = 1:N_datasets
    cur_model = model_set{nt};
    disp( '--------------------')
    disp([' DATASET: ', cur_model])
    disp( '--------------------')
    disp(validation_tables{nt})
end



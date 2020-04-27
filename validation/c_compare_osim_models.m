%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clearvars;  close all

model_set = {'LHDL_CT', 'P0_MRI', 'JIA_MRI', 'TLEM2_CT'};


for n_d = 1:numel(model_set)
    cur_model = model_set{n_d};
    
    % create joint structures for easy comparison
    auto = createJointParamsMatStructFromOsimModel(['opensim_models/manual_',cur_model,'.osim']);
    manual = createJointParamsMatStructFromOsimModel(['opensim_models/auto_',cur_model,'.osim']);
    
    % check if identical ground ref syst (essential - meaning model built in
    % same reference frame)
    assert(isequal(auto.ground_pelvis.parent-manual.ground_pelvis.parent, zeros(4)))
    
    disp('--------------------------------')
    disp(['PROCESSING MODEL: ', cur_model])
    disp('--------------------------------')
    % Offsets
    joint_list = fields(auto);
    for n = 1:numel(joint_list)
        cur_joint_name = joint_list{n};
        % 4th column is the vector locating the joint centre
%         results(n_d).
        jc_offset(n) = norm(auto.(cur_joint_name).child(:,4) - manual.(cur_joint_name).child(:,4))*1000;
%         results(n_d).
        ang_offset_child(n,:) = acosd(diag(auto.(cur_joint_name).child(1:3,1:3)'*manual.(cur_joint_name).child(1:3,1:3)));
%         results(n_d).
        ang_offset_parent(n,:) = acosd(diag(auto.(cur_joint_name).parent(1:3,1:3)'*manual.(cur_joint_name).parent(1:3,1:3)));
        
    end
    
    %------------- COMPLETE EVALUATION ------------------------------------
    % BUILD A FULL TABLE
    
    
    
    %------------- VALIDATION AGAINST MANUAL MODELS -----------------------
    % data needed for validation against manual models
    diff_summary = [ang_offset_child(1:2,:); ang_offset_parent(3,:);ang_offset_child(4,:); ang_offset_parent(5,:)];
    % build the table
    cur_val_res_table = table(  jc_offset', diff_summary(:,1), diff_summary(:,2), diff_summary(:,3),...
                                'VariableNames',{'JC-Offset_mm', 'X-axis_deg','Y-axis_deg','Z-axis_deg'});
    cur_val_res_table.Properties.RowNames = {'pelvis_ground_child' 'hip_r_child' 'knee_r_parent' 'ankle_r_child' 'subtalar_r_parent'};
    cur_val_res_table.Properties.Description = cur_model;
    cur_val_res_table.Properties.VariableUnits = {'mm', 'deg', 'deg', 'deg'};
    % store all validation tables in structure    
    validation_tables(n_d) = {cur_val_res_table};
    %----------------------------------------------------------------------
    
    clear jc_offset ang_offset_child ang_offset_parent
end


%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         % 
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Author: Luca Modenese                                                %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
% Test that checks if the model built using the current version of STAPLE
% are identical, within a tolerance, to those created for the 2020 paper.
% the models are built using the Modenese2018 joints definition.
% ----------------------------------------------------------------------- %
clearvars;  close all

% import opensim libraries
import org.opensim.modeling.*
addpath(genpath('../STAPLE/sandbox'));

% create models as in the paper (assumes examples have not been run)
run('../Example_create_kinetic_models.m');

% where the model created using the current version of STAPLE are (created
% with the previous run(../Example...)
osim_model_folder = '../opensim_models';

% where the models created for the paper have been stored
ref_models_folder = 'ref_models_from_paper';

% list ref models
model_list = dir('ref_models_from_paper');

nm = 1;
for n_file = 1:length(model_list)
    
    if isfolder(model_list(n_file).name)
        continue
    else
        model_name = model_list(n_file).name;
        disp('-----------------------------------------')
        disp(['Evaluating model ', model_name]);
        disp('-----------------------------------------')
        % create joint structures for each model for easy comparison
        STAPLE_model = createJointParamsMatStructFromOsimModel(fullfile(osim_model_folder,model_name));
        reference_model = createJointParamsMatStructFromOsimModel(fullfile(ref_models_folder,model_name));
        model_set(nm) = {model_name};
        nm = nm+1;
    end
    
    % check if ground ref syst is identical
    % essential for comparison (model built in same reference frame)
    assert(isequal(STAPLE_model.ground_pelvis.parent-reference_model.ground_pelvis.parent, zeros(4)),...
           ['Not both ', model_name, ' models are connected to ground.'])
    disp('  Both model connected to ground via pelvis')
    % cheking the origins of the models
    joint_list = fields(STAPLE_model);
    N_joint = numel(joint_list);
    
    % going through the joints
    for n = 1:N_joint
        cur_joint_name = joint_list{n};
        
        % joint centre offsets (identical for child and parent)
        auto_child_loc = STAPLE_model.(cur_joint_name).child(1:3,4);
        ref_child_loc = reference_model.(cur_joint_name).child(1:3,4);
        % they should be identical between papers and STAPLE
        assert(norm(auto_child_loc-ref_child_loc)<0.000001,...
            ['Joint centres of joint ', cur_joint_name, ' in models ', model_name, ' are different.']);
        disp(['  Same joint centres for ', cur_joint_name])
        % store for debugging if they are not [in mm]
        jc_offset(n, :) = (auto_child_loc - ref_child_loc)*1000; %#ok<*SAGROW>
        jc_offset_norm(n,1) = norm(jc_offset(n, :));
        
        % compute angular offsets for child reference systems
        auto_child_orient = STAPLE_model.(cur_joint_name).child(1:3,1:3);
        ref_child_orient  = reference_model.(cur_joint_name).child(1:3,1:3);
        % they should be identical between papers and STAPLE
        assert(max(max(auto_child_orient-ref_child_orient))<0.000001, ...
            ['child_orientation of joint ', cur_joint_name, ' in models ', model_name, ' are different.'])
        disp(['  Same child orientation for ', cur_joint_name])
        % store for debugging if they are not
        ang_offset_child(n,:) = acosd(diag(auto_child_orient'*ref_child_orient));
        
        % compute angular offsets for parent reference systems
        auto_parent_orient = STAPLE_model.(cur_joint_name).parent(1:3,1:3);
        ref_parent_orient  = reference_model.(cur_joint_name).parent(1:3,1:3);
        % they should be identical between papers and STAPLE
        assert(max(max(auto_parent_orient-ref_parent_orient))<0.000001, ...
            ['parent_orientation of joint ', cur_joint_name, ' in models ', model_name, ' are different.'])
        disp(['  Same parent orientation for ', cur_joint_name])
        % store for debugging if they are not
        ang_offset_parent(n,:) = acosd(diag(auto_parent_orient'*ref_parent_orient));
    end
    
    %------------- COMPLETE EVALUATION ------------------------------------
    % build a table to visualise all differences in all joint parameters
    cur_res_table = table(jc_offset, jc_offset_norm, ang_offset_parent, ang_offset_child,...
                          'VariableNames',{'JC-Offset_mm', 'JC-Offset-Norm_mm', ...
                                           'Angular_offset_parent_JCS (XYZ)',...
                                           'Angular_offset_child_JCS (XYZ)'});
    cur_res_table.Properties.RowNames = {'pelvis_ground' 'hip_r' 'knee_r' 'ankle_r' 'subtalar_r'};
    cur_res_table.Properties.Description = model_name;
    cur_res_table.Properties.VariableUnits = {'mm', 'mm','deg', 'deg'};
    
    % store structure of results
    test_results_tables(n_file) = {cur_res_table};
    
    % write results on xlsx file
%     writetable(cur_res_table, [results_folder,filesep,'JCS_differences_',cur_dataset,'.xlsx']);
    
    % clear variables
    clear jc_offset ang_offset_child ang_offset_parent cur_res_table jc_offset_norm
end
rmpath(genpath('../STAPLE/sandbox'));
% clc
% % display all tables of results
% for nt = 1:length(model_set)
%     cur_model = model_set{nt};
%     disp( '--------------------------------')
%     disp([' MODEL: ', cur_model])
%     disp( '--------------------------------')
%     disp(test_results_tables{nt})
% end
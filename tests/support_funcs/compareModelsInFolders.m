%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
function test_pass = compareModelsInFolders(models_folder, ref_models_folder, tol, table_on)

if nargin <3; tol = 0.000001; table_on = 0; end
if nargin <4; table_on = 0; end
    
% list ref models
model_list = dir(ref_models_folder);

nm = 1;

test_pass = 1;

for n_file = 1:length(model_list)
    
    if isfolder(model_list(n_file).name)
        continue
    else
        model_name = model_list(n_file).name;
        disp('---------------------------------------------------')
        disp(['Evaluating model ', model_name, ' vs reference']);
        disp('---------------------------------------------------')
        % create joint structures for each model for easy comparison
        STAPLE_model = createJointParamsMatStructFromOsimModel(fullfile(models_folder, model_name));
        reference_model = createJointParamsMatStructFromOsimModel(fullfile(ref_models_folder,model_name));
        model_set(nm) = {model_name};
        nm = nm+1;
    end
    
%     % check if ground ref syst is identical
%     % essential for comparison (model built in same reference frame)
%     assert(isequal(STAPLE_model.ground_pelvis.parent-reference_model.ground_pelvis.parent, zeros(4)),...
%            ['Not both ', model_name, ' models are connected to ground.'])
%     disp('  Both model connected to ground via pelvis')
    % cheking the origins of the models
    joint_list = fields(STAPLE_model);
    N_joint = numel(joint_list);
    
    % going through the joints
    disp('Joint comparison:')
    for n = 1:N_joint
        cur_joint_name = joint_list{n};
        disp([' * ', cur_joint_name])
        % joint centre offsets (identical for child and parent)
        auto_child_loc = STAPLE_model.(cur_joint_name).child(1:3,4);
        ref_child_loc = reference_model.(cur_joint_name).child(1:3,4);
        % they should be identical between papers and STAPLE
        if norm(auto_child_loc-ref_child_loc)<tol
            disp('  - same joint centres');
        else
            disp(['---WARNING: Joint centres of joint ', cur_joint_name, ' in models ', model_name, ' are different.']);
            test_pass = 0;
        end
        % store for debugging if they are not [in mm]
        jc_offset(n, :) = (auto_child_loc - ref_child_loc)*1000; %#ok<*SAGROW>
        jc_offset_norm(n,1) = norm(jc_offset(n, :));
        
        % compute angular offsets for child reference systems
        auto_child_orient = STAPLE_model.(cur_joint_name).child(1:3,1:3);
        ref_child_orient  = reference_model.(cur_joint_name).child(1:3,1:3);
        % they should be identical between papers and STAPLE
        if max(max(auto_child_orient-ref_child_orient))<tol
            disp('  - same child_orientation');
        else
            disp(['---WARNING: child_orientation of joint ', cur_joint_name, ' in models ', model_name, ' are different.']);
            disp(['            max diff: ', num2str(180/pi*max(max(auto_child_orient-ref_child_orient))),' deg'])
            test_pass = 0;
        end
        % store for debugging if they are not
        ang_offset_child(n,:) = acosd(diag(auto_child_orient'*ref_child_orient));
        
        % compute angular offsets for parent reference systems
        auto_parent_orient = STAPLE_model.(cur_joint_name).parent(1:3,1:3);
        ref_parent_orient  = reference_model.(cur_joint_name).parent(1:3,1:3);
        % they should be identical between papers and STAPLE
        if max(max(auto_parent_orient-ref_parent_orient))<tol
            disp('  - same parent_orientation');
        else
            disp(['---WARNING: parent_orientation of joint ', cur_joint_name, ' in models ', model_name, ' are different.'])
            disp(['            max diff: ', num2str(180/pi*max(max(auto_parent_orient-ref_parent_orient))),' deg'])
            test_pass = 0;
        end
        % store for debugging if they are not
        ang_offset_parent(n,:) = acosd(diag(auto_parent_orient'*ref_parent_orient));
    end
    
    if table_on
        %------------- COMPLETE EVALUATION ------------------------------------
        % build a table to visualise all differences in all joint parameters
        cur_res_table = table(jc_offset, jc_offset_norm, ang_offset_parent, ang_offset_child,...
            'VariableNames',{'JC-Offset_mm', 'JC-Offset-Norm_mm', ...
            'Angular_offset_parent_JCS (XYZ)',...
            'Angular_offset_child_JCS (XYZ)'});
        cur_res_table.Properties.RowNames = joint_list;
        cur_res_table.Properties.Description = model_name;
        cur_res_table.Properties.VariableUnits = {'mm', 'mm','deg', 'deg'};
        
        % store structure of results
%         test_results_tables(n_file) = {cur_res_table};
        
        % write results on xlsx file
        writetable(cur_res_table, ['JCS_differences_',model_name,'.xlsx']);
    end
    % clear variables
    clear jc_offset ang_offset_child ang_offset_parent cur_res_table jc_offset_norm
end

end
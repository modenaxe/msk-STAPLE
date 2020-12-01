function updJointStruct = finalizeJointStruct(jointStruct)
    
joint_list = fields(jointStruct);

fields_v = {'parent_location', 'parent_orientation', ...
                   'child_location', 'child_orientation',...
                   'parent_location', 'parent_orientation'};
fields_to_check = fields_v(1:4);

disp('Finalizing joints:')

for n_j = 1:length(joint_list)
    cur_joint_name = joint_list{n_j};
    disp([' *', cur_joint_name]);
    complete_fields = isfield(jointStruct.(cur_joint_name), fields_to_check(1:4));
    % joint is finalised
    if isequal(complete_fields, ones(1,4))
        disp('   - already complete.')
        continue
    end
    if sum(complete_fields([1,3]))==0
        disp(['   - WARNING: ', cur_joint_name, ' cannot be finalized: no joint locations available on neither bodies. Please read log and fix it.'])
        continue
    end
    if sum(complete_fields([2,4]))==0
        disp(['   - WARNING: Joint ', cur_joint_name, ' cannot be finalized: no joint orientation available on neither bodies. Please read log and fix it.'])
        continue
    end
    % the other cases should be covered here
    missing_fields_ind = find(~complete_fields);
    for nm = missing_fields_ind
        cur_miss = fields_v{nm};
        cur_fix  = fields_v{nm+2};
        jointStruct.(cur_joint_name).(cur_miss) = jointStruct.(cur_joint_name).(cur_fix);
        disp(['   - ',cur_miss, ' missing: copied from ''', cur_fix,'''.'])
    end
    clear missing_fields cur_miss cur_fix
    
end

updJointStruct = jointStruct;

end

function verifyJointStructCompleteness(jointStruct)

nF = fields(jointStruct);
fields_to_check = {'jointName', 'parentName', 'parent_location', 'parent_orientation', ...
                   'childName', 'child_location', 'child_orientation',...
                   'coordsNames', 'coordsTypes', 'rotationAxes'};
throw_error = 0;
for nf = 1:length(nF)
    cur_joint = nF{nf};
    defined_joint_params = isfield(jointStruct.(cur_joint),fields_to_check);
    if min(defined_joint_params)~=1
        throw_error = 1;
        disp([cur_joint, ' definition incomplete. Missing fields:']);
        error_printout = fields_to_check(~defined_joint_params);
        for nerr = 1:length(error_printout)
            disp(['   -> ', error_printout{nerr}])
        end
    end
end
if throw_error==1
    error('createOpenSimModelJoints.m Incomplete joint(s) definition(s): the joint(s) cannot be generated. See printout above.');
else
    disp('All joints are complete!')
end

end
% ASSEMBLEJOINTSTRUCT Fill the MATLAB structure that will
% be used for creating the OpenSim joints using the available information
% on the joint parameters. It makes the simple assumption that when a
% parameter is missing (child/parent_location/orientation), it is
% appropriate to copy the information from the corresponding
% parent/child_location/orientation parameter. This works when using
% geometries segmented from consistent medical images and might not be
% appropriate for all intended uses of STAPLE (although it is for most
% uses).
%
%   updJointStruct = assembleJointStruct(jointStruct)
%
% Inputs:
%   jointStruct - MATLAB structure including the reference parameters
%       that will be used to generate an OpenSim JointSet. It might be
%       incomplete, with joints missing some of the required parameters.
%
% Outputs:
%   updJointStruct - updated jointStruct with the joints with fields
%       completed as discussed above.
%
% See also VERIFYJOINTSTRUCTCOMPLETENESS, JOINTDEFINITIONS_AUTO2020,...
% JOINTDEFINITIONS_MODENESE2018.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function updJointStruct = assembleJointStruct(jointStruct)
    

fields_to_check = {'parent_location', 'parent_orientation', ...
                   'child_location',  'child_orientation',...
                   'parent_location', 'parent_orientation'};

disp('Finalizing joints:')

joint_list = fields(jointStruct);
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
    % if wither child or parent location/orientation is available, copy on
    % the missing field
    missing_fields_ind = find(~complete_fields);
    for nm = missing_fields_ind
        cur_miss = fields_to_check{nm};
        cur_fix  = fields_to_check{nm+2};
        jointStruct.(cur_joint_name).(cur_miss) = jointStruct.(cur_joint_name).(cur_fix);
        disp(['   - ',cur_miss, ' missing: copied from ''', cur_fix,'''.'])
    end
    clear missing_fields cur_miss cur_fix
    
end

updJointStruct = jointStruct;

end

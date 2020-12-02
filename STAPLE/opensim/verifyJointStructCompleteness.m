% VERIFYJOINTSTRUCTCOMPLETENESS Check that the MATLAB structure that will
% be used for creating the OpenSim joints includes all the required
% parameters, so that the joint generation will not failed when the OpenSim
% API are called. This function should be called after the joint
% definitions have been applied, as a "last check" before running the
% OpenSim API. It checked that the following fields are defined:
%   - child/parent_location/orientation
%   - joint/parent/child_name
%   - coordsNames/Types
%   - rotationAxes
%
%   verifyJointStructCompleteness(jointStruct)
%
% Inputs:
%   jointStruct - MATLAB structure including all the reference parameters
%       that will be used to generate an OpenSim JointSet. 
%
% Outputs:
%   none
%
% See also ASSEMBLEJOINTSTRUCT, JOINTDEFINITIONS_AUTO2020, 
% JOINTDEFINITIONS_MODENESE2018.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function verifyJointStructCompleteness(jointStruct)

% fields that will be checked on each joint in jointStruct
fields_to_check = {'jointName', 'parentName', 'parent_location', 'parent_orientation', ...
                   'childName', 'child_location', 'child_orientation',...
                   'coordsNames', 'coordsTypes', 'rotationAxes'};
               
throw_error = 0;
nF = fields(jointStruct);
for nf = 1:length(nF)
    cur_joint = nF{nf};
    defined_joint_params = isfield(jointStruct.(cur_joint),fields_to_check);
    % if error will be thrown (not all fields are present), 
    % printout where the issue is
    if min(defined_joint_params)~=1
        throw_error = 1;
        disp([cur_joint, ' definition incomplete. Missing fields:']);
        error_printout = fields_to_check(~defined_joint_params);
        for nerr = 1:length(error_printout)
            disp(['   -> ', error_printout{nerr}])
        end
    end
end

% if flag is now positive, throw the error
if throw_error==1
    error('createOpenSimModelJoints.m Incomplete joint(s) definition(s): the joint(s) cannot be generated. See printout above.');
else
    disp('All joints are complete!')
end

end
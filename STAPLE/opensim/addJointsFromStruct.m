% ADDJOINTSFROMSTRUCT Create the lower limb joints specified in the
% jointStruct MATLAB structure and add them to the specified OpenSim model.
%
% addJointsToOpenSimModel(osimModel,jointStruct)
%
% Inputs:
%   osimModel - an OpenSim model of the lower limb to which we want to add
%       the lower limb joints.
%
%   jointStruct - a MATLAB structure created using the function
%       createLowerLimbJoints().
%
% Outputs:
%   none - the joints are added to the input OpenSim model.
%
% See also GETJOINTPARAMS, CREATECUSTOMJOINTFROMSTRUCT, 
%          VERIFYJOINTSTRUCTCOMPLETENESS, CREATEOPENSIMMODELJOINTS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2021 Luca Modenese
%-------------------------------------------------------------------------%
function osimModel = addJointsFromStruct(osimModel,jointStruct)

% check that all joints are completed
verifyJointStructCompleteness(jointStruct)

% after the verification joints can be added
disp('Adding joints to model:')
available_joints =  fields(jointStruct);
for ncj = 1:length(available_joints)
    cur_joint_name = available_joints{ncj};
    % create the joint
    createCustomJointFromStruct(osimModel, jointStruct.(cur_joint_name));
    % display what has been created
    disp(['   * ', cur_joint_name]);
end

disp('Done adding.')

end
% GETJOINTPARAMS Assemble a structure with all the information required to
% create a CustomJoint of a specified lower limb joint. Normally this
% function is used after the geometrical analyses on the bones and before
% generating the joint for the automatic OpenSim model using 
% createCustomJointFromStruct. It is assumed that the inputs will contain
% enough information (location and orientation) to define the joint
% reference system. 
% NOTE: 
% A body is connected to ground with a free_to_ground joint if no other 
% specifics are provided, please see examples on partial models for 
% practical examples.
% IMPORTANT: modifying the values of the fields of JointParamsStruct output
% structure allows to modify the joint model according to the preferences
% of the researcher. See advanced examples.
%
% JointParamsStruct = getJointParams(joint_name, root_body)
%
% Inputs:
%   joint_name - name of the lower limb joint for which we want to create
%       the structure containing all parameters (string).
%
%   root_body - a string specifying the name of the body attached to ground
%       in the case it is not the default (pelvis).
%
% Outputs:
%   JointParamsStruct - a structure collecting all the information required
%       to define an OpenSim CustomJoint. The typical fields of this
%       structure are the following: name, parent, child, coordsNames,
%       coordsTypes, ROM and rotationAxes. An example of JointParamsStruct is
%       the following:
%         JointParamsStruct.jointName           = 'hip_r';
%         JointParamsStruct.parentName          = 'pelvis';
%         JointParamsStruct.childName           = 'femur_r';
%         JointParamsStruct.coordsNames         = {'hip_flexion_r','hip_adduction_r','hip_rotation_r'};
%         JointParamsStruct.coordsTypes         = {'rotational', 'rotational', 'rotational'};
%         JointParamsStruct.coordRanges         = {[-120 120], [-120 120], [-120 120]};% in degrees 
%         JointParamsStruct.rotationAxes        = 'zxy';
%
% See also CREATECUSTOMJOINTFROMSTRUCT, CREATELOWERLIMBJOINTS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function JointParamsStruct = getJointParams(joint_name, root_body)


if nargin<2; root_body='root_body'; end

% detect side from bone names
if strcmp(joint_name(end-1:end), '_r') || strcmp(joint_name(end-1:end), '_l')
    side = joint_name(end);
end

%% assign the parameters required to create a CustomJoint
switch joint_name
    case 'ground_pelvis'
        JointParamsStruct.jointName           = 'ground_pelvis';
        JointParamsStruct.parentName          = 'ground';
        JointParamsStruct.childName           = 'pelvis';
        JointParamsStruct.coordsNames         = {'pelvis_tilt','pelvis_list','pelvis_rotation', 'pelvis_tx','pelvis_ty', 'pelvis_tz'};
        JointParamsStruct.coordsTypes         = {'rotational', 'rotational', 'rotational', 'translational', 'translational','translational'};
        JointParamsStruct.coordRanges         = {[-90 90], [-90 90] , [-90 90], [-10, 10] , [-10, 10] , [-10, 10]};
        JointParamsStruct.rotationAxes        = 'zxy';
    case 'free_to_ground'
        cb                                    = root_body; % cb = current bone (for brevity)
        JointParamsStruct.jointName           = ['ground_',cb];
        JointParamsStruct.parentName          = 'ground';
        JointParamsStruct.childName           = cb;
        JointParamsStruct.coordsNames         = {['ground_', cb,'_rz'],['ground_', cb,'_rx'],['ground_', cb,'_ry'],...
                                                 ['ground_', cb,'_tx'],['ground_', cb,'_ty'],['ground_', cb,'_tz']};
        JointParamsStruct.coordsTypes         = {'rotational', 'rotational', 'rotational', 'translational', 'translational','translational'};
        JointParamsStruct.coordRanges         = {[-120 120], [-120 120] , [-120 120], [-10, 10] , [-10, 10] , [-10, 10]};
        JointParamsStruct.rotationAxes        = 'zxy';  
    case ['hip_', side]
        JointParamsStruct.jointName           = ['hip_', side];
        JointParamsStruct.parentName          = 'pelvis';
        JointParamsStruct.childName           = ['femur_', side];
        JointParamsStruct.coordsNames         = {['hip_flexion_', side],['hip_adduction_', side],['hip_rotation_', side]};
        JointParamsStruct.coordsTypes         = {'rotational', 'rotational', 'rotational'};
        JointParamsStruct.coordRanges         = {[-120 120], [-120 120], [-120 120]};
        JointParamsStruct.rotationAxes        = 'zxy';
    case ['knee_', side]
        JointParamsStruct.jointName          = ['knee_', side];
        JointParamsStruct.parentName         = ['femur_', side];
        JointParamsStruct.childName          = ['tibia_', side];
        JointParamsStruct.coordsNames        = {['knee_angle_', side]};
        JointParamsStruct.coordsTypes        = {'rotational'};
        JointParamsStruct.coordRanges        = {[-120 10]};
        JointParamsStruct.rotationAxes       = 'zxy';   
    case ['ankle_', side]
        JointParamsStruct.jointName          = ['ankle_', side];
        JointParamsStruct.parentName         = ['tibia_', side];
        JointParamsStruct.childName          = ['talus_', side];
        JointParamsStruct.coordsNames        = {['ankle_angle_', side]};
        JointParamsStruct.coordsTypes        = {'rotational'};
        JointParamsStruct.coordRanges        = {[-90 90]};
        JointParamsStruct.rotationAxes       = 'zxy';
    case ['subtalar_', side]
        JointParamsStruct.jointName          = ['subtalar_', side];
        JointParamsStruct.parentName         = ['talus_', side];
        JointParamsStruct.childName          = ['calcn_', side];
        JointParamsStruct.coordsNames        = {['subtalar_angle_', side]};
        JointParamsStruct.coordsTypes        = {'rotational'};
        JointParamsStruct.coordRanges        = {[-90 90]};
        JointParamsStruct.rotationAxes       = 'zxy';
    case 'patellofemoral_r'
        JointParamsStruct.jointName          = ['patellofemoral_', side];
        JointParamsStruct.parentName         = ['femur_', side];
        JointParamsStruct.childName          = ['patella_', side];
        JointParamsStruct.coordsNames        = {['knee_angle_',side,'_beta']};
        JointParamsStruct.coordsTypes        = {'rotational'};
%         JointParamsStruct.coordRanges            = {[-90 90]};
        JointParamsStruct.rotationAxes       = 'zxy';
    case ['mtp_', side]
        JointParamsStruct.jointName          = ['toes_', side];
        JointParamsStruct.parentName         = ['calcn_', side];
        JointParamsStruct.childName          = ['toes_', side];
        JointParamsStruct.coordsNames        = {['mtp_angle_',side]};
        JointParamsStruct.coordsTypes        = {'rotational'};
        JointParamsStruct.coordRanges        = {[-90 90]};
        JointParamsStruct.rotationAxes       = 'zxy';
    otherwise
        error(['getJointParams.m Unsupported joint ',joint_name ,'.']);
end
% GETJOINTPARAMS3DOFKNEE Custom function that implements a lower limb model
% with a 3 degrees of freedom knee joint.
% This script is an example of advanced use of STAPLE.
%
% See also GETJOINTPARAMS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function JointParamsStruct = getJointParams3DoFKnee(joint_name, root_body)


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
%-----------------------------------
% SPECIAL SETTING FOR ALTERING JOINT
%-----------------------------------
    case ['knee_', side]
        JointParamsStruct.jointName          = ['knee_', side];
        JointParamsStruct.parentName         = ['femur_', side];
        JointParamsStruct.childName          = ['tibia_', side];
        JointParamsStruct.coordsNames        = {['knee_angle_', side], ['knee_varus_', side], ['knee_rotation_', side]};
        JointParamsStruct.coordsTypes        = {'rotational', 'rotational', 'rotational'};
        JointParamsStruct.coordRanges        = {[-120 10], [-20 20], [-30 30]};
        JointParamsStruct.rotationAxes       = 'zxy';   
%-----------------------------------
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
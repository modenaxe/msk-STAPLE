% CREATELOWERLIMBJOINTS Create the lower limb joints based on assigned
% joint coordinate systems stored in a structure and adds them to an
% existing OpenSim model.
%
% createLowerLimbJoints(osimModel, JCS, method)
%
% Inputs:
%   osimModel - an OpenSim model of the lower limb to which we want to add
%       the lower limb joints. 
%
%   JCS - a MATLAB structure created using the function 
%       createLowerLimbJoints(). This structure includes as fields the
%       elements to generate a CustomJoint using the
%       createCustomJointFromStruct function. See these functions for
%       details.
%
%   method - optional input specifying the final arrangements of location
%       and orientation of the CustomJoint. Valid values are
%       'Modenese2018', which will define the same reference systems
%       described in Modenese et al. J Biomech (2018), or 'auto', that will
%       use the tibial JCS as well. See Modenese and Renault, JBiomech 2020
%       for details.
%
% Outputs:
%   none - the joints are added to the input OpenSim model.
%
% See also GETJOINTPARAMS, CREATECUSTOMJOINTFROMSTRUCT, CREATELOWERLIMBJOINTS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
%
% TODO add switches for adding custom workflows

function createLowerLimbJoints(osimModel, JCS, workflow, side)

% if not specified, method is auto. Other option is Modenese2018.
% This only influences ankle and subtalar joint.
if nargin<3;     error('createLowerLimbJoints.m Error: you need to specify a body side.');   end
if nargin<3;     workflow = 'auto';   end
if nargin<4
    side_low = inferBodySideFromAnatomicStruct(JCS);
else
    % get sign correspondent to body side
    [~, side_low] = bodySide2Sign(side);
end

% printout
disp('---------------------');
disp('   CREATING JOINTS   ')
disp('---------------------');
disp(['Workflow for joint definitions: ', workflow])

% joint names
hip_name      = ['hip_',side_low];
knee_name     = ['knee_',side_low];
ankle_name    = ['ankle_',side_low];
subtalar_name = ['subtalar_',side_low];
% patellofemoral_name = ['patellofemoral_',side_low];

% segment names
femur_name      = ['femur_',side_low];
tibia_name      = ['tibia_',side_low];
% patella_name    = ['patella_',side_low];
talus_name      = ['talus_',side_low];
calcn_name      = ['calcn_',side_low];

disp('Adding joints to model:')

% ground_pelvis joint
%---------------------
if isfield(JCS, 'pelvis')
    JointParams = getJointParams('ground_pelvis', [], JCS.pelvis, side_low);
    pelvis_ground_joint = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(pelvis_ground_joint);
    disp('   * ground_pelvis');
else
    % this allows to create a free body with ground using any segment
    % requires definition of fields child, child_orientation and
    % child_location in JCS.free_to_ground (as subfields).
    disp('Partial model detected (attaching proxbody to ground).')
    JointParams = getJointParams('free_to_ground', [], JCS.proxbody, side_low);
    free_joint = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(free_joint);
    disp('   * free_to_ground');
end


% hip joint
%-------------
if isfield(JCS, 'pelvis') && isfield(JCS, femur_name)
    JointParams = getJointParams(hip_name, JCS.pelvis, JCS.(femur_name), side_low);
    hip_joint = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(hip_joint);
    disp(['   * ', hip_name]);
end


% knee joint
%-------------
if isfield(JCS, femur_name) && isfield(JCS, tibia_name)
    if strcmp(workflow, 'Modenese2018')
        if isfield(JCS, talus_name)
            JCS.(tibia_name) = assembleKneeChildOrientationModenese2018(JCS.(femur_name), JCS.(tibia_name), JCS.(talus_name));
        else
            warndlg('JCS structure does not have a talus_r field required for Modenese 2018 knee joint definition. Defining joint as auto2020.')
        end
    end
    JointParams = getJointParams(knee_name, JCS.(femur_name), JCS.(tibia_name), side_low);
    knee_joint = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(knee_joint);
    disp(['   * ', knee_name]);
end


% ankle joint
%-------------
if isfield(JCS, tibia_name) && isfield(JCS, talus_name) 
    JCS.(tibia_name) = assembleAnkleParentOrientation(JCS.(tibia_name), JCS.(talus_name));
    % in case you want to replicate the modelling from Modenese et al. 2018
    if strcmp(workflow, 'Modenese2018')
        if isfield(JCS, calcn_name)
            JCS.(tibia_name) = assembleAnkleParentOrientationModenese2018(JCS.(tibia_name), JCS.(talus_name));
            JCS.(talus_name) = assembleAnkleChildOrientationModenese2018(JCS.(talus_name), JCS.(calcn_name));
        else
            warndlg('JCS structure does not have a calcn_r field required for Modenese 2018 ankle definition. Defining joint as auto2020.')
        end
    end
    JointParams = getJointParams(ankle_name, JCS.(tibia_name), JCS.(talus_name), side_low);
    ankle_joint = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(ankle_joint);
    disp(['   * ', ankle_name]);
end


% subtalar joint
%----------------
if isfield(JCS, talus_name) && isfield(JCS, calcn_name)
    % in case you want to replicate the modelling from Modenese et al. 2018
    if strcmp(workflow, 'Modenese2018')
        if isfield(JCS, femur_name)
            JCS.(talus_name) = assembleSubtalarParentOrientationModenese2018(JCS.(femur_name), JCS.(talus_name));
        else
            warndlg(['JCS structure does not have a ', femur_name,' field required for Modenese 2018 subtalar definition. Defining joint as auto2020.'])
        end
    end
    JointParams = getJointParams(subtalar_name, JCS.(talus_name), JCS.(calcn_name), side_low);
    subtalar_joint = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(subtalar_joint);
    disp(['   * ', subtalar_name]);
end 


% patella joint
%---------------
% if isfield(JCS, patella_name) && isfield(JCS, femur_name)
%     JCS.patella_r = assemblePatellofemoralParentOrientation(JCS.(femur_name), JCS.(patella_name));
%     JointParams = getJointParams(patellofemoral_name, JCS.(femur_name), JCS.(patella_name), side_low);
%     patfem_joint = createCustomJointFromStruct(osimModel, JointParams);
%     osimModel.addJoint(patfem_joint);
%     addPatFemJointCoordCouplerConstraint(osimModel, side)
%     addPatellarTendonConstraint(osimModel, TibiaRBL, PatellaRBL, side, in_mm)
% disp(['   * ', patellofemoral_name]);
% end

disp('Done.')

end
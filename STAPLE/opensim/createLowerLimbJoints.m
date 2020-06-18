%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, March 2020                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
function createLowerLimbJoints(osimModel, JCS, method)

% if not specified, method is auto. Other option is Modenese2018.
% This only influences ankle and subtalar joint.
if nargin<3;     method = 'auto';   end

% ground_pelvis joint
%---------------------
if isfield(JCS, 'pelvis')
    JointParams = getJointParams('ground_pelvis', [], JCS.pelvis);
    pelvis_ground_joint = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(pelvis_ground_joint);
else
    % this allows to create a free body with ground using any segment
    % requires definition of fields child, child_orientation and
    % child_location in JCS.free_to_ground (as subfields).
    disp('Partial lower limb model detected.')
    JointParams = getJointParams('free_to_ground', [], JCS.proxbody);
    free_joint = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(free_joint);
end

% hip joint
%-------------
if isfield(JCS, 'pelvis') && isfield(JCS, 'femur_r')
    JointParams = getJointParams('hip_r', JCS.pelvis, JCS.femur_r);
    hip_r = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(hip_r);
end

% knee joint
%-------------
if isfield(JCS, 'femur_r') && isfield(JCS, 'tibia_r')
    if strcmp(method, 'Modenese2018')
        if isfield(JCS, 'talus_r')
            JCS.tibia_r = assembleKneeChildOrientationModenese2018(JCS.femur_r, JCS.tibia_r, JCS.talus_r);
        else
            warndlg('JCS structure does not have a talus_r field required for Modenese 2018 knee joint definition. Defining joint as auto2020.')
        end
    end
    JointParams = getJointParams('knee_r', JCS.femur_r, JCS.tibia_r);
    knee_r = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(knee_r);
end

% ankle joint
%-------------
if isfield(JCS, 'tibia_r') && isfield(JCS, 'talus_r') 
    JCS.tibia_r = assembleAnkleParentOrientation(JCS.tibia_r, JCS.talus_r);
    % in case you want to replicate the modelling from Modenese et al. 2018
    if strcmp(method, 'Modenese2018')
        if isfield(JCS, 'calcn_r')
            JCS.tibia_r = assembleAnkleParentOrientationModenese2018(JCS.tibia_r, JCS.talus_r);
            JCS.talus_r = assembleAnkleChildOrientationModenese2018(JCS.talus_r, JCS.calcn_r);
        else
            warndlg('JCS structure does not have a calcn_r field required for Modenese 2018 ankle definition. Defining joint as auto2020.')
        end
    end
    JointParams = getJointParams('ankle_r', JCS.tibia_r, JCS.talus_r);
    ankle_r = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(ankle_r);
end

% subtalar joint
%----------------
if isfield(JCS, 'talus_r') && isfield(JCS, 'calcn_r')
    % in case you want to replicate the modelling from Modenese et al. 2018
    if strcmp(method, 'Modenese2018')
        if isfield(JCS, 'femur_r')
            JCS.talus_r = assembleSubtalarParentOrientationModenese2018(JCS.femur_r, JCS.talus_r);
        else
            warndlg('JCS structure does not have a femur_r field required for Modenese 2018 subtalar definition. Defining joint as auto2020.')
        end
    end
    JointParams = getJointParams('subtalar_r', JCS.talus_r, JCS.calcn_r);
    subtalar_r = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(subtalar_r);
end 

% patella joint
%---------------
% if isfield(JCS, 'patella_r') && isfield(JCS, 'femur_r')
%     JCS.patella_r = assemblePatellofemoralParentOrientation(JCS.femur_r, JCS.patella_r);
%     JointParams = getJointParams('patellofemoral_r', JCS.femur_r, JCS.patella_r);
%     patfem_r = createCustomJointFromStruct(osimModel, JointParams);
%     osimModel.addJoint(patfem_r);
%     addPatFemJointCoordCouplerConstraint(osimModel, side)
%     addPatellarTendonConstraint(osimModel, TibiaRBL, PatellaRBL, side, in_mm)
% end

end
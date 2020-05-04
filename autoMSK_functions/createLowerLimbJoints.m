%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, March 2020                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
function createLowerLimbJoints(osimModel, JCS, method)

% if not specified, method is auto. Other option is Modenese.
% This only influences ankle and subtalar joint.
if nargin<3;     method = 'auto';   end
    
% ground_pelvis joint
%---------------------
JointParams = getJointParams('ground_pelvis', [], JCS.pelvis);
pelvis_ground_joint = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(pelvis_ground_joint);

% hip joint
%-------------
JointParams = getJointParams('hip_r', JCS.pelvis, JCS.femur_r);
hip_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(hip_r);

% knee joint
%-------------
if strcmp(method, 'Modenese2018')
    JCS.tibia_r = assembleKneeChildOrientationModenese2018(JCS.femur_r, JCS.tibia_r, JCS.talus_r);
end
JointParams = getJointParams('knee_r', JCS.femur_r, JCS.tibia_r);
knee_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(knee_r);

% ankle joint
%-------------
JCS.tibia_r = assembleAnkleParentOrientation(JCS.tibia_r, JCS.talus_r);
% in case you want to replicate the modelling from Modenese et al. 2018
if strcmp(method, 'Modenese2018')
    JCS.tibia_r = assembleAnkleParentOrientationModenese2018(JCS.tibia_r, JCS.talus_r);
    JCS.talus_r = assembleAnkleChildOrientationModenese2018(JCS.talus_r, JCS.calcn_r);
end
JointParams = getJointParams('ankle_r', JCS.tibia_r, JCS.talus_r);
ankle_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(ankle_r);

% subtalar joint
%----------------
% in case you want to replicate the modelling from Modenese et al. 2018
if strcmp(method, 'Modenese2018')
    JCS.talus_r = assembleSubtalarParentOrientationModenese2018(JCS.femur_r, JCS.talus_r);
end
JointParams = getJointParams('subtalar_r', JCS.talus_r, JCS.calcn_r);
subtalar_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(subtalar_r);

% patella joint
if isfield(JCS, 'patella_r') && isfield(JCS, 'femur_r')
    JCS.patella_r = assemblePatellofemoralParentOrientation(JCS.femur_r, JCS.patella_r);
    JointParams = getJointParams('patellofemoral_r', JCS.femur_r, JCS.patella_r);
    patfem_r = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(patfem_r);
%     addPatFemJointCoordCouplerConstraint(osimModel, side)
%     addPatellarTendonConstraint(osimModel, TibiaRBL, PatellaRBL, side, in_mm)
end

end
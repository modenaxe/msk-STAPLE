%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, March 2020                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
function createLowerLimbJoints(osimModel, JCS)

% ground_pelvis joint
JointParams = getJointParams('ground_pelvis', [], JCS.pelvis);
pelvis_ground_joint = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(pelvis_ground_joint);

% hip joint
JointParams = getJointParams('hip_r', JCS.pelvis, JCS.femur_r);
hip_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(hip_r);

% knee joint
JointParams = getJointParams('knee_r', JCS.femur_r, JCS.tibia_r);
knee_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(knee_r);

% ankle joint
JCS.tibia_r = assembleAnkleParentOrientation(JCS.tibia_r, JCS.talus_r);
JointParams = getJointParams('ankle_r', JCS.tibia_r, JCS.talus_r);
ankle_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(ankle_r);

% subtalar joint
JointParams = getJointParams('subtalar_r', JCS.talus_r, JCS.calcn_r);
subtalar_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(subtalar_r);

% patella joint
if isfield(JCS, 'patella_r') && isfield(JCS, 'femur_r')
    JCS.patella_r = assemblePatellofemoralParentOrientation(JCS.femur_r, JCS.patella_r);
    JointParams = getJointParams('patellofemoral_r', JCS.femur_r, JCS.patella_r);
    patfem_r = createCustomJointFromStruct(osimModel, JointParams);
    osimModel.addJoint(patfem_r);
end

end
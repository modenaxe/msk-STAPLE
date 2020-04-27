function modelStruct = createJointParamsMatStructFromOsimModel(aOsimModel_name)

import org.opensim.modeling.*

osimModel = Model(aOsimModel_name);

% build a model structure from reading the opensim model
[modelStruct.ground_pelvis.parent, modelStruct.ground_pelvis.child] = getHomogeneusMatsForJoint(osimModel, 'ground_pelvis');
[modelStruct.hip_r.parent, modelStruct.hip_r.child]                 = getHomogeneusMatsForJoint(osimModel, 'hip_r');
[modelStruct.knee_r.parent, modelStruct.knee_r.child]               = getHomogeneusMatsForJoint(osimModel, 'knee_r');
[modelStruct.ankle_r.parent, modelStruct.ankle_r.child]             = getHomogeneusMatsForJoint(osimModel, 'ankle_r');
[modelStruct.subtalar.parent, modelStruct.subtalar.child]           = getHomogeneusMatsForJoint(osimModel, 'subtalar_r');

end

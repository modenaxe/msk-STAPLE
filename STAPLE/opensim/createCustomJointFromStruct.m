% CREATECUSTOMJOINTFROMSTRUCT Create a CustomJoint using the parameters
% defined in the structure given as input. 
%
%   myCustomJoint = createCustomJointFromStruct(model, struct)
%
% Inputs:
%   model - an OpenSim model (object).
%
%   struct - a Matlab structure with the typical fields of an OpenSim
%       CustomJoint: name, parent (name), child (name), parent location, 
%       parent orientation, child location, child orientation.
%
% Outputs:
%   myCustomJoint - a CustomJoint (object), that can be used outside this
%       function to add it to the OpenSim model.
%
% Example of structure to provide as input:
% JointParamsStruct.name               = 'knee_r';
% JointParamsStruct.parent             = 'femur_r';
% JointParamsStruct.child              = 'tibia_r';
% JointParamsStruct.coordsNames        = {'knee_angle_r'};
% JointParamsStruct.coordsTypes        = {'rotational'};
% JointParamsStruct.rotationAxes       = 'zxy';
%
% See also CREATESPATIALTRANSFORMFROMSTRUCT, GETJOINTPARAMS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function myCustomJoint = createCustomJointFromStruct(model, struct)

% OpenSim libraries
import org.opensim.modeling.*

% extract names
jointName   = struct.name;
parentName  = struct.parent;
childName   = struct.child;

% transform offsets in Vec3
location_in_parent    = ArrayDouble.createVec3(struct.parent_location);
orientation_in_parent = ArrayDouble.createVec3(struct.parent_orientation);
location_in_child     = ArrayDouble.createVec3(struct.child_location);
orientation_in_child  = ArrayDouble.createVec3(struct.child_orientation);

% get the Physical Frames to connect with the CustomJoint
if strcmp(parentName, 'ground')
    parent_frame = model.getGround();
else
    parent_frame = model.getBodySet.get(parentName);
end
child_frame = model.getBodySet.get(childName);

% create the spatialTransform from the assigned structure
% openSim 3.3
% OSJoint = setCustomJointSpatialTransform(OSJoint, struct);
% OpenSim 4.1
jointSpatialTransf = createSpatialTransformFromStruct(struct);

% create the joint m...f...!!
myCustomJoint= CustomJoint(jointName,...
             parent_frame,...
             location_in_parent,...
             orientation_in_parent,...
             child_frame,...
             location_in_child,...
             orientation_in_child,...
             jointSpatialTransf);

end
% CREATECUSTOMJOINTFROMSTRUCT Create and add to model a CustomJoint using 
% the parameters defined in the structure given as input. 
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
% JointParamsStruct.jointName          = 'knee_r';
% JointParamsStruct.parentName         = 'femur_r';
% JointParamsStruct.childName          = 'tibia_r';
% JointParamsStruct.coordsNames        = {'knee_angle_r'};
% JointParamsStruct.coordsTypes        = {'rotational'};
% JointParamsStruct.rotationAxes       = 'zxy';
% JointParamsStruct.parent_location    = [x y z];
% JointParamsStruct.parent_orientation = [x y z];
% JointParamsStruct.child_location     = [x y z];
% JointParamsStruct.child_orientation  = [x y z];
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
jointName   = struct.jointName;
parentName  = struct.parentName;
childName   = struct.childName;

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


% add joint to model
model.addJoint(myCustomJoint)

% update coordinates range of motion, if specified
if isfield(struct, 'coordRanges')
    for n_coord = 1:length(struct.coordsNames)
        curr_coord = myCustomJoint.get_coordinates(n_coord-1);
        curr_ROM = struct.coordRanges{n_coord};
        if strcmp(struct.coordsTypes{n_coord}, 'rotational')
            curr_ROM = curr_ROM/180*pi;
        end
        % set the range of motion for the coordinate
        curr_coord.setRangeMin(curr_ROM(1));
        curr_coord.setRangeMax(curr_ROM(2));
    end
end

end
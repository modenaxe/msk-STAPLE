%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         % 
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Author:   Luca Modenese,  2019                                       %
%    email:    l.modenese@mperial.ac.uk                                   % 
% ----------------------------------------------------------------------- %
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

% STEP1: get the Physical Frames to connect with the CustomJoint
if strcmp(parentName, 'ground')
    parent_frame = model.getGround();
else
    parent_frame = model.getBodySet.get(parentName);
end
child_frame = model.getBodySet.get(childName);


% OSJoint = setCustomJointSpatialTransform(OSJoint, struct);
jointSpatialTransf = createSpatialTransformFromStruct(struct);

% create the f... joint m...f...!!
myCustomJoint= CustomJoint(jointName,...
             parent_frame,...
             location_in_parent,...
             orientation_in_parent,...
             child_frame,...
             location_in_child,...
             orientation_in_child,...
             jointSpatialTransf);

% myCustomJoint = custom_joint;
end
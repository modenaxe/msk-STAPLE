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
function OSJoint = setJointRefSyst(OSJoint, struct)

% OpenSim libraries
import org.opensim.modeling.*

% set joint name
jointName = struct.name;
OSJoint.setName(jointName);

% set location and orientation for parent
parentName = struct.parent;
location_in_parent = ArrayDouble.createVec3(struct.parent_location);
orientation_in_parent = ArrayDouble.createVec3(struct.parent_orientation);

% % OpenSim 4 way of building the joint
% OSJoint.connectSocket_parent_frame
% OSJoint.connectSocket_parent_frame
% OSJoint.finalizeConnections()

OSJoint.setParentName(parentName);
OSJoint.setLocationInParent(location_in_parent);
OSJoint.setOrientationInParent(orientation_in_parent);

% set location and orientation for child
location  = ArrayDouble.createVec3(struct.child_location);
orientation = ArrayDouble.createVec3(struct.child_orientation);
OSJoint.setLocation(location);
OSJoint.setOrientation(orientation);

end
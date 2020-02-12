% % % %-------------------------------------------------------------------------%
% % % % Copyright (c) 2019 Modenese L.                                          %
% % % %                                                                         %
% % % % Licensed under the Apache License, Version 2.0 (the "License");         %
% % % % you may not use this file except in compliance with the License.        %
% % % % You may obtain a copy of the License at                                 %
% % % % http://www.apache.org/licenses/LICENSE-2.0.                             %
% % % %                                                                         % 
% % % % Unless required by applicable law or agreed to in writing, software     %
% % % % distributed under the License is distributed on an "AS IS" BASIS,       %
% % % % WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% % % % implied. See the License for the specific language governing            %
% % % % permissions and limitations under the License.                          %
% % % %                                                                         %
% % % %    Author:   Luca Modenese,  2019                                       %
% % % %    email:    l.modenese@mperial.ac.uk                                   % 
% % % % ----------------------------------------------------------------------- %
% % % function OSJoint = setJointRefSyst(OSJoint, struct, model)
% % % 
% % % % OpenSim libraries
% % % import org.opensim.modeling.*
% % % 
% % % % set joint name
% % % jointName = struct.name;
% % % OSJoint.setName(jointName);
% % % 
% % % % STEP0: prepare all it's needed to build the CustomJoint
% % % % set location and orientation for parent
% % % parentName = struct.parent;
% % % location_in_parent = ArrayDouble.createVec3(struct.parent_location);
% % % orientation_in_parent = ArrayDouble.createVec3(struct.parent_orientation);
% % % % set location and orientation for child
% % % childName = struct.child;
% % % location  = ArrayDouble.createVec3(struct.child_location);
% % % orientation = ArrayDouble.createVec3(struct.child_orientation);
% % % 
% % % % STEP1: get the Physical Frames to connect with the CustomJoint
% % % if strcmp(parentName, 'ground')
% % %     parent_frame = model.getGround();
% % % else
% % %     parent_frame = model.getBodySet.get(parentName);
% % % end
% % % child_frame = model.getBodySet.get(childName);
% % % 
% % % 
% % % % STEP2: need to create the SpatialTransform
% % % OSJoint = setJointCoords(OSJoint, struct);
% % % 
% % % % STEP3: just create the f... joint!
% % % CustomJoint()
% % % 
% % % % NB THERE IS NO CHILD/PARENT LOCATION OR OFFSET BECAUSE YOU CAN CREATE THE
% % % % OFFSET PHYSICLA FRAME NOW!
% % % 
% % % end
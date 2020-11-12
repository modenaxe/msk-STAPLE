%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
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
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
function [parent, child] = getHomogeneusMatsForJoint(osimModel, a_osim_joint_name)

import org.opensim.modeling.*

% get joint
osimJoint = osimModel.get_JointSet.get(a_osim_joint_name);
% loop parent and child
frame1_tr = osimVec3ToArray(osimJoint.get_frames(0).get_translation);
frame1_or = osimVec3ToArray(osimJoint.get_frames(0).get_orientation);
parent= [[orientation2MatRot(frame1_or), frame1_tr']; [0 0 0 1]];
frame2_tr = osimVec3ToArray(osimJoint.get_frames(1).get_translation);
frame2_or = osimVec3ToArray(osimJoint.get_frames(1).get_orientation);
child= [[orientation2MatRot(frame2_or), frame2_tr']; [0 0 0 1]];
end
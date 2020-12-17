%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%    Author:   Luca Modenese                                              %
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
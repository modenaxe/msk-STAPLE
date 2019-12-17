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
function updJointSet = createJointSet(JointParams, bodySet)

% OpenSim libraries
import org.opensim.modeling.*

% number of bodies
N = size(JointParams,2);

% create a bodyset
updJointSet = JointSet;

% create joints from structures
for n_joint = 1:N
    % get current joint
    currJoint = createCustomJointFromStruct(JointParams(n_joint));
    
    % need to connect the joint to the corresponding body
    child_body = bodySet.get(JointParams(n_joint).child);    
    child_body.setJoint(currJoint);
    
    % clone and append to jointSet
    updJointSet.cloneAndAppend(currJoint);
end

% test print
updJointSet.print('_test_jointSet.xml');

end
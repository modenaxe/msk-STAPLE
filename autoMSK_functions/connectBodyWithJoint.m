% --------------------------------------------------------------------------- %
% OpenSim: ModelBuildingFunctions.py                                          %
% --------------------------------------------------------------------------- %
% OpenSim is a toolkit for musculoskeletal modeling and simulation,           %
% developed as an open source project by a worldwide community. Development   %
% and support is coordinated from Stanford University, with funding from the  %
% U.S. NIH and DARPA. See http://opensim.stanford.edu and the README file     %
% for more information including specific grant numbers.                      %
%                                                                             %
% Copyright (c) 2005-2018 Stanford University and the Authors                 %
% Author(s): Ayman Habib, Carmichael Ong, Ajay Seth                           %
%                                                                             %
% Licensed under the Apache License, Version 2.0 (the "License"); you may     %
% not use this file except in compliance with the License. You may obtain a   %
% copy of the License at http://www.apache.org/licenses/LICENSE-2.0           %
%                                                                             %
% Unless required by applicable law or agreed to in writing, software         %
% distributed under the License is distributed on an "AS IS" BASIS,           %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    %
% See the License for the specific language governing permissions and         %
% limitations under the License.                                              %
% --------------------------------------------------------------------------- %
% Luca Modenese ported the function in MATLAB

function joint = connectBodyWithJoint(model, parentFrame, childFrame, jointName, jointType)
% 	Connect a childFrame on a Body to a parentFrame (on another Body or Ground)
% 	in the model using a Joint of the specified type.
% 	Arguments:
% 	model: model to be modified.
% 	parentFrame: the Body (or affixed offset) to be connected as the parent frame;
% 				 any PhysicalFrame already in the model is suitable.
% 	childFrame:  the Body (or affixed offset) to be connected as the child frame;
% 				 can be any PhysicalFrame that is not the parent Frame.
% 	jointName:   name to be given to the newly-created Joint.
% 	jointType is one of:
% 		'PinJoint', 'FreeJoint', 'WeldJoint', 'PlanarJoint', 'SliderJoint',
% 		'UniversalJoint'
% 	returns the Joint added to connect the Body to the model


validJointTypes = {'PinJoint',...
                   'FreeJoint',...
                   'WeldJoint',...
                   'PlanarJoint',...
                   'SliderJoint',...
                   'UniversalJoint'};

if ~strcmp(jointType, validJointTypes)
    error(['Provided jointType ', jointType, ' is not valid.'])
end

% OpenSim libraries
import org.opensim.modeling.*

JointClass = eval(jointType);

% Instantiate the user-requested Joint class.
joint = JointClass(jointName, parentFrame, childFrame);

model.addJoint(joint)

end
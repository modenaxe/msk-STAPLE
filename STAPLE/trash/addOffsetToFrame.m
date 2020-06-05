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
function [model, offset] = addOffsetToFrame(model, baseFrame, offsetName, trans, rot)
% 	Define a PhysicalOffsetFrame in terms of its translational and rotational
% 		offset with respect to a base (Physical) frame and add it to the model.
% 		Arguments:
% 			baseFrame: the PhysicalFrame in the model to offset.
% 		   offsetName: the name (string) of the OffsetFrame to be added
% 				trans: Translational offset (Vec3) in base frame coordinates
% 				  rot: Rotational offset in the base frame as body fixed X-Y-Z Euler angles (Vec3)
% 		return:
% 			offset: the PhysicalOffsetFrame added to the model
%

% OpenSim libraries
import org.opensim.modeling.*

offset = PhysicalOffsetFrame();
offset.setName(offsetName)

if nargin>2
    offset.set_translation(trans);
end

if nargin>3
    offset.set_orientation(rot);
end

if (model.hasComponent(baseFrame.getAbsolutePathString()))
    offset.connectSocket_parent(baseFrame)
    baseFrame.addComponent(offset)
else
    disp('baseFrame does not exist as a PhysicalFrame. No offset frame was added.')
end

end
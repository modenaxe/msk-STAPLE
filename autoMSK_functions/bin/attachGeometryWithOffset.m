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

function offset = attachGeometryWithOffset(frame, geometry)
%--------------------------------------------------------------------------
% 	Attach geometry to provided frame. This function adds an
% 	intermediate offset frame between the geometry and the provided frame
% 	to permit editing its properties to move the geometry around.
%
% 	This function returns the intermediate offset frame so that you can
% 	modify its location and orientation.
%--------------------------------------------------------------------------

% OpenSim libraries
import org.opensim.modeling.*

offset = modeling.PhysicalOffsetFrame();
offset.setName(frame.getName() + '_offset')
offset.set_translation(modeling.Vec3(0.))
offset.set_orientation(modeling.Vec3(0.))
frame.addComponent(offset);
bf = modeling.PhysicalFrame.safeDownCast(frame);
offset.connectSocket_parent(bf)
offset.attachGeometry(geometry)

end
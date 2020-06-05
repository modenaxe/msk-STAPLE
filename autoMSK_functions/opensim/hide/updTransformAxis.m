%-------------------------------------------------------------------------%
% Copyright (c) 2016 Modenese L.                                          %
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
%    Author:   Luca Modenese, May 2016                                    %
%    email:    l.modenese@sheffield.ac.uk                                 % 
% ----------------------------------------------------------------------- %
%
% This simple function allows, given a transformation axis of a spatial
% transform, to change the direction of its axis.
% NB: one input is a OS object, the other one is a double vector [1x3]
%---------------------------
% last modified: 18/05/2016
% Author: Luca Modenese

function updTransfAxis = updTransformAxis(OS_TransfAxis, upd_axis_double)

% importing libraries
import org.opensim.modeling.*

% changing variable
upd_axis = upd_axis_double;

% update the axis with the rotated values
upd_axis_v = Vec3;
upd_axis_v.set(0,upd_axis(1))
upd_axis_v.set(1,upd_axis(2))
upd_axis_v.set(2,upd_axis(3))

% update axis
OS_TransfAxis.setAxis(upd_axis_v);
updTransfAxis = OS_TransfAxis;

end
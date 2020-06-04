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
% this function allows to change the coordinate name associated with the
% transform axis. The name is given as a string.
%---------------------------
% last modified: 18/05/2016
% Author: Luca Modenese

function updTransfAxis = updTransformAxisCoordName(OS_TransfAxis, axis_coord_name)

% importing libraries
import org.opensim.modeling.*

% changing the name associated to the axis (only one coordinate)
% create string array
coord_names_array = OS_TransfAxis.getCoordinateNamesInArray;

if strcmp(axis_coord_name,'')
    % this is necessary to avoid issues in the unused dof (OpenSim would
    % not clone the models)
    coord_names_array = ArrayStr;
else
    % set new name
    coord_names_array.set(0,axis_coord_name);
end

% upd coordinate
OS_TransfAxis.setCoordinateNames(coord_names_array);

updTransfAxis = OS_TransfAxis;

end


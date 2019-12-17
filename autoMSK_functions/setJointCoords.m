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
function OSJoint = setJointCoords(OSJoint, struct)

% OpenSim libraries
import org.opensim.modeling.*

% get coordinate set to update
updCoordinates = OSJoint.upd_CoordinateSet();

% creating coordinates
coordsNames = struct.coordsNames;
coordsTypes = struct.coordsTypes;

% number of coords
N = size(coordsNames,2);

for n_c = 1:N
    coord = Coordinate();
    curr_coord_name = coordsNames{n_c};
    coord.setName(curr_coord_name);
    curr_coord_type = coordsTypes{n_c};
    if strcmp(curr_coord_type,'rotational') || strcmp(curr_coord_type,'translational')
        coord.set_motion_type(curr_coord_type);
    else
        error([curr_coord_type,' must be ''rotational'' or ''translational''.']);
    end
    
    % updating the coordinate set
    updCoordinates.cloneAndAppend(coord);
end

end
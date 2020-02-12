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

% This needs fixing - not working on OpenSim 4
% get coordinate set to update
updCoordinates = OSJoint.upd_CoordinateSet();
OSJoint.upd_coordinates(0)
% creating coordinates
coordsNames = struct.coordsNames;
coordsTypes = struct.coordsTypes;

% number of coords
N = size(coordsNames,2);

for n_c = 1:N
    % get coords values
    curr_coord_name = coordsNames{n_c};
    curr_coord_type = coordsTypes{n_c};
    curr_def_value  = 0;
    
    % define ranges
    if strcmp(curr_coord_type,'rotational')
        curr_range_min = -90/180*pi;
        curr_range_max =  90/180*pi;
    else
        curr_range_min = -4;
        curr_range_max =  4;
    end
    
    % define the coordinate
    Coordinate(curr_coord_name,...
               curr_coord_type,...
               curr_def_value,... 
               curr_range_min,...
               curr_range_max);
    
    % updating the coordinate set
    updCoordinates.cloneAndAppend(coord);
end

end
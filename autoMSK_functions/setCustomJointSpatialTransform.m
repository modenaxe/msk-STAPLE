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
function OSJoint = setCustomJointSpatialTransform(OSJoint, struct)

% OpenSim libraries
import org.opensim.modeling.*

% creating coordinates
coordsNames   = struct.coordsNames;
coordsTypes   = struct.coordsTypes;
rotationAxes  = struct.rotationAxes;

% checking rotational coordinates
nr_rot = sum(strcmp(coordsTypes,'rotational'));
rot_coords_names = coordsNames(strcmp(coordsTypes,'rotational'));
for nn = 1:3-nr_rot
    rot_coords_names(nr_rot+nn) = {''};
end

nr_trans = sum(strcmp(coordsTypes,'translational'));
trans_coords_names = coordsNames(strcmp(coordsTypes,'translational'));
for nn = 1:3-nr_trans
    trans_coords_names(nr_trans+nn) = {''};
end

coords_names = [rot_coords_names, trans_coords_names];

% number of coords
N_str = size(coordsNames,2);
if N_str~=(nr_trans+nr_rot)
    error('badly defined  joint')
end

% update variable names for as many dof as indicated
lin_fun = LinearFunction(1, 0);
const_fun = Constant(0);

% extracting the vectors associated with the order of rotation
v = eye(3);
if ischar(rotationAxes)
    for ind = 1:3
        v(ind,1:3) = getAxisVecFromStringLabel(rotationAxes(ind));
    end
else
    for ind = 1:nr_rot
        v(ind,1:3) = rotationAxes(ind, :);
    end
end

v(4:6,1:3) = eye(3);

% get spatial transform
jointSpatialTransf = OSJoint.upd_SpatialTransform();

%================= ROTATIONS ===================
% looping through rotations axes
for n = 1:6
    
    % get modifiable transform axis (upd..)
    TransAxis = jointSpatialTransf.updTransformAxis(n-1);
    
    % applying specified rotation order
    TransAxis = updTransformAxis(TransAxis, v(n,:));
    
    % this will update the coordinate names and assign a linear
    % function to those axes with a coordinate associated with,
    TransAxis = updTransformAxisCoordName(TransAxis, coords_names{n});
    
    if ~strcmp(coords_names{n},'')
        TransAxis.set_function(lin_fun);
    else
        TransAxis.set_function(const_fun);
    end
    
%     % printing check for dev
%     TransAxis.print(['TransformAxis_', num2str(n),'.xml']);
end

% this will take care of having independent axis;
jointSpatialTransf.constructIndependentAxes(nr_rot, 0)

end
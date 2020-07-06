% CREATESPATIALTRANSFORMFROMSTRUCT Create a SpatialTransform from the
% provided structure. Intended to be used to create a CustomJoint in 
% OpenSim >4.0.
%
% jointSpatialTransf = createSpatialTransformFromStruct(struct)
%
% Inputs:
%   struct - a Matlab structure with the fields required to define a
%       SpatialTransform: coordsNames, coordsTypes (rotational or
%       translational), rotationAxes (vectors).
%
% Outputs:
%   jointSpatialTransf - a SpatialTranform (object), to be included in an
%       OpenSim CustomJoint.
%
%
% Example of input structure:
% JointParamsStruct.coordsNames         = {'hip_flexion_r','hip_adduction_r','hip_rotation_r'};
% JointParamsStruct.coordsTypes         = {'rotational', 'rotational', 'rotational'};
% JointParamsStruct.rotationAxes        = 'zxy';
%
% See also GETAXISVECFROMSTRINGLABEL, CREATECUSTOMJOINTFROMSTRUCT, GETJOINTPARAMS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese, 2020
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function jointSpatialTransf = createSpatialTransformFromStruct(struct)

% OpenSim libraries
import org.opensim.modeling.*

% creating coordinates
coordsNames   = struct.coordsNames;
coordsTypes   = struct.coordsTypes;
rotationAxes  = struct.rotationAxes;

% rotational coordinates
nr_rot = sum(strcmp(coordsTypes,'rotational'));
rot_coords_names = coordsNames(strcmp(coordsTypes,'rotational'));
for nn = 1:3-nr_rot
    rot_coords_names(nr_rot+nn) = {''};
end

% translational coordinates
nr_trans = sum(strcmp(coordsTypes,'translational'));
trans_coords_names = coordsNames(strcmp(coordsTypes,'translational'));
for nn = 1:3-nr_trans
    trans_coords_names(nr_trans+nn) = {''};
end

% cell vector of coordinate names
coords_names = [rot_coords_names, trans_coords_names];
% check of consistency of dimentions
N_str = size(coordsNames,2);
if N_str~=(nr_trans+nr_rot)
    error('createSpatialTrasnformFromStruct.m The sum of translational and rotational coordinates does not match the coordinates names. Please double check.')
end

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

% translations are always along the axes XYZ (in this order)
v(4:6,1:3) = eye(3);

% create spatial transform
jointSpatialTransf = SpatialTransform();

%================= ROTATIONS ===================
% create a linear function and a constant function
lin_fun = LinearFunction(1, 0);
const_fun = Constant(0);

% looping through axes (3 rotations, 3 translations)
for n = 1:6
    
    % get modifiable transform axis (upd..)
    TransAxis = jointSpatialTransf.updTransformAxis(n-1);
    
    % applying specified rotation order
    TransAxis = updTransformAxis(TransAxis, v(n,:));
    
    % this will update the coordinate names and assign a linear
    % function to those axes with a coordinate associated with.
    % the axis without a coordinate associated will be assigned a constant
    % zero function (they will not move).
    TransAxis = updTransformAxisCoordName(TransAxis, coords_names{n});
    if ~strcmp(coords_names{n},'')
        TransAxis.set_function(lin_fun);
    else
        TransAxis.set_function(const_fun);
    end
    
%     % printing check
%     TransAxis.print(['TransformAxis_', num2str(n),'.xml']);
end

% this will take care of having 3 independent axis
jointSpatialTransf.constructIndependentAxes(nr_rot, 0)

end
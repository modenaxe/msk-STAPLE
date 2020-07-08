% UPDTRANSFORMAXISCOORDNAME Change name of coordinate associated with the
% transformAxis. The name is provided as a string.
%
%   updTransfAxis = updTransformAxisCoordName(OS_TransfAxis, axis_coord_name)
%
% Inputs:
%   OS_TransfAxis - a transformation axis taken from a SpatialTransform of
%       an OpenSim CustomJoint. 
%
%   axis_coord_name - a string with the name of a coordinate of the OpenSim
%       model.
%
% Outputs:
%   updTransfAxis - the updated transformed axis of the SpatialTransform.
%
% See also CREATESPATIALTRANSFORMFROMSTRUCT, UPDTRANSFORMAXIS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
% modified: 18/05/2016
% last modified: July 2020


function updTransfAxis = updTransformAxisCoordName(OS_TransfAxis, axis_coord_name)

% importing libraries
import org.opensim.modeling.*

% changing the name associated to the axis (only one coordinate)
% create string array
coord_names_array = OS_TransfAxis.getCoordinateNamesInArray();

if strcmp(axis_coord_name,'')
    % this is necessary to avoid issues in the unused dof (OpenSim would
    % not clone the models) - comment from OpenSim 3.3
    coord_names_array = ArrayStr;
else
    % set new name
    coord_names_array.set(0,axis_coord_name);
end

% upd coordinate name
OS_TransfAxis.setCoordinateNames(coord_names_array);

% return it as new variable
updTransfAxis = OS_TransfAxis;

end


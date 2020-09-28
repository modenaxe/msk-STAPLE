% UPDTRANSFORMAXIS Change axis of a SpatialTransform object to an assign
% axis.
%
%   updTransfAxis = updTransformAxis(OS_TransfAxis, upd_axis_double)
%
% Inputs:
%   OS_TransfAxis - a transformation axis taken from a SpatialTransform of
%       an OpenSim CustomJoint. 
%
%   upd_axis_double - a row vector indicating the new vector to assign to
%       the SpatialTransform axis. This is a MATLAB row vector [1x3] of
%       doubles.
%
% Outputs:
%   updTransfAxis - the updated transformed axis of the SpatialTransform.
%
%
% See also CREATESPATIALTRANSFORMFROMSTRUCT, UPDTRANSFORMAXISCOORDNAME.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
% modified: 18/05/2016
% last modified: 08/07/2020

function updTransfAxis = updTransformAxis(OS_TransfAxis, upd_axis_double)

% importing libraries
import org.opensim.modeling.*

% update the axis with the rotated values
upd_axis_v = Vec3;
upd_axis_v.set(0,upd_axis_double(1))
upd_axis_v.set(1,upd_axis_double(2))
upd_axis_v.set(2,upd_axis_double(3))

% update axis
OS_TransfAxis.setAxis(upd_axis_v);
updTransfAxis = OS_TransfAxis;

end
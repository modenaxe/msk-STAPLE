% COMPUTEXYZANGLESEQ Convert a rotation matrix in the orientation vector
% used in OpenSim (X-Y-Z axes rotation order).
%
%   orientation = computeXYZAngleSeq(aRotMat)
%
% Inputs:
%   aRotMat - a rotation matrix, normally obtained writing as columns the
%       axes of the body reference system, expressed in global reference
%       system.
%
% Outputs:
%   orientation - the sequence of angles used in OpenSim to define the
%       joint orientation. Sequence of rotation is X-Y-Z.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese, 2020
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function orientation = computeXYZAngleSeq(aRotMat)

% fixed body sequence of angles from rot mat usable for orientation in
% OpenSim
beta  = atan2(aRotMat(1,3),                   sqrt(aRotMat(1,1)^2.0+aRotMat(1,2)^2.0));
alpha = atan2(-aRotMat(2,3)/cos(beta),        aRotMat(3,3)/cos(beta));
gamma = atan2(-aRotMat(1, 2)/cos(beta),       aRotMat(1,1)/cos(beta));

% build a vector
orientation = [  alpha  beta  gamma];

end
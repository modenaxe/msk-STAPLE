% GETAXISVECFROMSTRINGLABEL Take one character as input ('x', 'y' or 'z')
% and returns the corresponding vector (as a row).
%
% v = getAxisVecFromStringLabel(axisLabel)
%
% Inputs:
%   axisLabel - a string indicating an axis. Valid values are: 'x', 'y' or
%       'z'.
%
% Outputs:
%   v - a row vector corresponding to the axis label specified as input.
%
% See also CREATECUSTOMJOINTFROMSTRUCT, GETJOINTPARAMS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese, 2015
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function v = getAxisVecFromStringLabel(axisLabel)

% TODO: needs a check on single character

% make it case independent
axisLabel = lower(axisLabel);

switch axisLabel
    case 'x'
        v = [1 0 0];
    case 'y'
        v = [0 1 0];
    case 'z'
        v = [0 0 1];
end

end   
% FINDLANDMARKCOORDS Pick points from a point cloud using string keywords.
%
%   [BL, BL_ind] = findLandmarkCoords(points, axis_name, direction)
%
% Inputs:
%   points - indicates a point cloud, i.e. a matrix of [N_point, 3]
%       dimensions.
%
%   axis_name - specifies the axis where the min/max operator will be
%       applied. Assumes values: 'x', 'y' or 'z', corresponding to first,
%       second or third column of the points input.
%
%   operator - specifies which point to pick in the specified axis.
%       Currently assumes values: 'min' or 'max', meaning smalles or
%       largest value in that direction.
%
% Outputs:
%   BL - coordinates of the point identified in the point cloud following
%       the directions provided as input. 
%
%   BL_ind - index of the point identified in the point cloud following the
%       direction provided as input.
% 
% Example:
% getBonyLandmark(pcloud,'max','z') asks to pick the point in the pcloud 
% with largest z coordinate. If pcloud was a right distal femur triangulation
% with points expressed in the reference system of the International
% Society of Biomechanics, this could be the lateral femoral epicondyle.
%
% See also GETBONELANDMARKLIST, LANDMARKTRIGEOMBONE.
%
% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.edu.au                                 % 
% ----------------------------------------------------------------------- %

function [BL, BL_ind] = findLandmarkCoords(points, axis_name, operator)

% TO DO ADD CHECK FOR DESCRIPT AND DIRECTION AS STRINGS
% interpreting direction of search
switch axis_name
    case 'x'
        dir_ind = 1;
    case 'y'
        dir_ind = 2;
    case 'z'
        dir_ind = 3;
        % TO DO ADD PLANES CHECKS
    otherwise
end

% interpreting description of search
switch operator
    case 'max'
        [~, BL_ind] = max(points(:,dir_ind));
    case 'min'
        [~, BL_ind] = min(points(:,dir_ind));
    otherwise
end

BL  = points(BL_ind,:);

end
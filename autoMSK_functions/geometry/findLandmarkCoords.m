% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese,  2015                                       %
%    email:    l.modenese@imperial.edu.au                                 % 
% ----------------------------------------------------------------------- %
%
% This function makes easier to pick points from a certain point cloud by
% specifying only the direction and the position through strings.
% For instance, the function call getBonyLandmark(v_oct,'max','x') reads as
% 'pick the point of v_oct with maximum x coordinate'.

function [BL, BL_ind] = findLandmarkCoords(points, axis_name, direction)

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
switch direction
    case 'max'
        [~, BL_ind] = max(points(:,dir_ind));
    case 'min'
        [~, BL_ind] = min(points(:,dir_ind));
    otherwise
end

BL  = points(BL_ind,:);

end
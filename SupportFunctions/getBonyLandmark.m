% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@griffith.edu.au                                 % 
% ----------------------------------------------------------------------- %
%
% This function makes easier to pick points from a certain point cloud by
% specifying only the direction and the position through strings.
% For instance, the function call getBonyLandmark(v_oct,'max','x') reads as
% 'pick the point of v_oct with maximum x coordinate'.

function [BL, BL_ind] = getBonyLandmark(v_oct,descrip,direction)

% TO DO ADD CHECK FOR DESCRIPT AND DIRECTION AS STRINGS
% interpreting direction of search
switch direction
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
switch descrip
    case 'max'
        [~, BL_ind] = max(v_oct(:,dir_ind));
    case 'min'
        [~, BL_ind] = min(v_oct(:,dir_ind));
    otherwise
end

BL  = v_oct(BL_ind,:);

end
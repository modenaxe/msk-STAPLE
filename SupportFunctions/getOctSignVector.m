% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@griffith.edu.au                                 % 
% ----------------------------------------------------------------------- %
%
% Given the identication number (from 1 to 8) of an octant, this function
% returns the vector describing the signs of the coordinates for that
% octree.
% Table of signs from https://en.wikipedia.org/wiki/Octant_(solid_geometry)

function oct_vec = getOctSignVector(oct_id)
switch oct_id
    case 1
        oct_vec = [1 1 1];
    case 2
        oct_vec = [-1 1 1];
    case 3
        oct_vec = [-1 -1 1];
    case 4
        oct_vec = [1 -1 1];
    case 5
        oct_vec = [1 1 -1];
    case 6
        oct_vec = [-1 1 -1];
    case 7
        oct_vec = [-1 -1 -1];
    case 8
        oct_vec = [1 -1 -1];
    otherwise
        error('Please specify an octant between 1 and 8')
end
end
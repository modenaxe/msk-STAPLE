% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@griffith.edu.au                                 % 
% ----------------------------------------------------------------------- %
%
% Given a cloud of points and the identifier of an octant, this function
% extracts the points belonging to the octant of the 3D space where the
% points are located.

function PointCloud_oct = pickPointsInOctant(PointCloud, oct_id)

% get octant vector of signs
oct_vec = getOctSignVector(oct_id);

PointCloud_oct = PointCloud(oct_vec(1)*PointCloud(:,1)>0 &...
                            oct_vec(2)*PointCloud(:,2)>0 &...
                            oct_vec(3)*PointCloud(:,3)>0,:);
                    
end

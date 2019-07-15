% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@griffith.edu.au                                 % 
% ----------------------------------------------------------------------- %
%
% Given a cloud of points v, this function needs a direction ('x', 'y',
% 'z') and the specification of a lower and upper bound on that axis: it
% will extract the subset of the vertices on that region of space.
% if upper or lower bound are not specified '[]', then the entire
% semi-plane is considered.

function v_subset = pickSubsetBetweenPlanes(v, normalDir, lb, up)
    
    switch normalDir
        case 'x'
            ind = 1;
        case 'y'
            ind = 2;
        case 'z'
            ind = 3;
            % TO DO ADD PLANES CHECKS
        otherwise
    end
    
    if isempty(lb)
        lb = min(v(:,ind));
    end
    if isempty(up)
        up = max(v(:,ind));
    end
    
    v_subset = v(v(:,ind)>lb & v(:,ind)<up,:);
    
%     figure
%     plot3(v_subset(:,1), v_subset(:,2), v_subset(:,3),'.')
    end
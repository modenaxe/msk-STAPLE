% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %
% Efficient function to identify the facets connects to a subset of
% vertices of a mesh. 
% E.g. Given vtot and ftot, vertices and facets of a certain mesh, the
% function returns the facets f_subset that have at least a vertices
% connected to the subset ('include') or that have all vertices connected
% ('exclude').

function [f_subset, f_subset_ind] = getFacetsFromVertices(vtot, ftot, v_subset, inclusive_string)

% identifies the vertices row/indeces
[Lia, Lib] = ismember(vtot, v_subset, 'rows');

f_select = Lib(ftot);
switch inclusive_string
    % inclusive: if a facet includes only one vertices of the subset v_subset
    % is included in f_subset
    case 'include'
        f_subset_ind = sum(f_select,2)>0;
    case 'exclude'
        % exclusive
        f_subset_ind =((f_select(:,1).*f_select(:,2).*f_select(:,3))>0);
    otherwise
        error('The inclusive_string must be ''include'' or ''exclude''')
end

% extract the facets selected according to the specified preferences
f_subset = ftot(f_subset_ind,:);

end

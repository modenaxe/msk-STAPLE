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

f_subset = ftot(f_subset_ind,:);

end

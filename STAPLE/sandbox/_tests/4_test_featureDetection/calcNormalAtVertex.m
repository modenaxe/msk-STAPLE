function n_vert = calcNormalAtVertex(v,f,n,vert)

[~, f_subset_ind] = getFacetsFromVertices(v, f, vert, 'include');

n_subset = n(f_subset_ind,:);

n_vert = mean(n_subset);

end
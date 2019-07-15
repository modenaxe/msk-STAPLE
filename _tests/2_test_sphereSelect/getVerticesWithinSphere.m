function [v_internal, v_internal_ind] = getVerticesWithinSphere(v, P, Radius)

% building vector for vectorial difference
P_vec = ones(size(v,1),1)*P;

% calculate distance between P and all points in mesh
dist = (sum((v-P_vec).^2.0, 2)).^0.5;

% logic indeces of vectors inside the sphere
v_internal_ind = dist<Radius;

% verteces of the ellipsoid inside the sphere
v_internal = v(v_internal_ind,:);

end
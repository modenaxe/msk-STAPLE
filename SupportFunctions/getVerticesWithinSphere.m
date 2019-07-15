% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %
% 
% function that allows to given a cloud of points v, allows to select all
% vertices within a sphere identified by its centre P and Radius.
% Outputs are the array of internal vertices and their logical indices,
% such that v(v_internal_ind,:) = v_internal;

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
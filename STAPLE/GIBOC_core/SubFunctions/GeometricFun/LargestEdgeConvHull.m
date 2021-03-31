% LARGESTEDGECONVHULL Compute the convex hull of the points cloud Pts and 
% sort the edges by their length.
%
% INPUTS:
%       - Pts :         A Point Cloud in 2D [nx2] or 3D [nx3]
%
%       - Minertia :    A matrice of inertia to transform the points
%                       beforehand
%
% OUTPUTS:
%       - IdxPointsPair :   [mx2] or [mx3] matrix of the index of pair of
%                           points forming the edges
%
%       - EdgesLength :     a [mx1] matrix of the edges length which rows 
%                           are in correspondance with IdxPointsPair matrix
%
%       - K :               The convex hull of the point cloud
%
%       - Edges_Length_and_VerticesIDs_merged_sorted : 
%                           A [mx3] matrix with first column corresponding 
%                           to the edges length and the last two columns 
%                           corresponding to the Index of the points
%                           forming the the edge.
%
% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault, modified by Luca Modenese (2020)
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ IdxPointsPair , EdgesLength , K, ...
    Edges_Length_and_VerticesIDs_sorted] = LargestEdgeConvHull(Pts, Minertia)

%
% TODO: this function can benefit from squeeze
if min(size(Pts)) == 2
    K = convhull(Pts,'simplify', false);
    EdgeLength = sqrt(sum(diff(Pts(K,:),1).^2,2));
    [EdgesLength,I] = sort(EdgeLength,'descend');
    IdxPointsPair = [K(I) K(I+1)];
    
elseif min(size(Pts)) == 3
    if nargin > 1
        Pts = bsxfun(@minus,Pts,mean(Pts))*Minertia;
    end
    
    % [LM] returns the indices of vertices of the convex hull. From docs:
    %   K is a triangulation representing
    %   the boundary of the convex hull. K is of size mtri-by-3, where mtri is 
    %   the number of triangular facets. That is, each row of K is a triangle 
    %   defined in terms of the point indices.
    K = convhull(Pts,'simplify', false);
    n_ch_elmts = size(K,1);
    % [LM] plot
    % plot3(Pts3(:,1), Pts3(:,2), Pts3(:,3),'.')

    % compute the length of the edges of the triangles of the convex hull
    % [LM] convenient arrangement for using diff and compute edge lengths
    % Pts3[n_points, x-y-z_coords, v1-v2-v3-v1_of_facets]
    Pts3(:,:,1)  = Pts(K(:,1),:);
    Pts3(:,:,2)  = Pts(K(:,2),:);
    Pts3(:,:,3)  = Pts(K(:,3),:);
    Pts3(:,:,4)  = Pts(K(:,1),:);
    
    % diff across coords of vertices to get the edges length
    % EdgeLength = [n_ch_elements x 1 x 3(edges)]
    Edges_Length = sqrt(sum(diff(Pts3,1,3).^2,2));
    
    % Create a matrix where the 1st colmuns is the length of the edges
    % the 2nd and 3rd columns contains the ID of the vertices composing the
    % edge. This matrix is repeated 3 times on a third axis because each
    % element is composed of 3 edges. So index 1 on the 3rd axis
    % corresponds to all the 1st edges, index 2 to all the 2nd edges and
    % index 3 to all the 3rd edges. This is convenient because we later sort
    % the edges by length and we can sort the first columns and keep the
    % correspondance with the corresponding edges vertices Ids.
    Edges_Length_and_VerticesIDs = zeros(n_ch_elmts, 3, 3) ;
    Edges_Length_and_VerticesIDs(:,1,:) = Edges_Length ;
    
    % Assign the edges vertices ID to each edge length
    Edges_Length_and_VerticesIDs(:, 2:3, 1) = [K(:,1) K(:,2)];
    Edges_Length_and_VerticesIDs(:, 2:3, 2) = [K(:,2) K(:,3)];
    Edges_Length_and_VerticesIDs(:, 2:3, 3) = [K(:,3) K(:,1)];
    
    % Concatenate the data from edges 1, 2 and 3 to the first axis
    Edges_Length_and_VerticesIDs_merged = ...
        [Edges_Length_and_VerticesIDs(:,:,1);...
        Edges_Length_and_VerticesIDs(:,:,2);...
        Edges_Length_and_VerticesIDs(:,:,3)];
    
    % Sort all edges by edge length
    Edges_Length_and_VerticesIDs_sorted = sortrows(...
        Edges_Length_and_VerticesIDs_merged,1,'descend');

    % outputs 
    %---------
    % the indices of the vertices
    IdxPointsPair = Edges_Length_and_VerticesIDs_sorted(:,2:3);
    % and their corresponding edges lengths
    EdgesLength = Edges_Length_and_VerticesIDs_sorted(:,1);

end

end


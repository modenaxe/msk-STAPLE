function [ IdxPointsPair , EdgesLength , K, EdgesIdx_merged ] = LargestEdgeConvHull( Pts, Minertia )
%Compute the convex hull of the points cloud Pts and sort the edges by 
% their length
% INPUTS :
%       - Pts :         A Point Cloud in 2D [nx2] or 3D [nx3]
%
%       - Minertia :    A matrice of inertia to transform the points
%                       beforehand
%
% OUTPUTS :
%       - IdxPointsPair :   [mx2] or [mx3] matrix of the index of pair of
%                           points forming the edges
%
%       - EdgesLength :     a [mx1] matrix of the edges length which rows 
%                           are in correspondance with IdxPointsPair matrix
%
%       - K :               The convex hull of the point cloud
%
%       - EdgesIdx_merged : A [mx3] matrix with first column corresponding 
%                           to the edges length and the last two columns 
%                           corresponding to the Index of the points
%                           forming the the edge.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% TODO: this function can benefit from squeeze
if min(size(Pts)) == 2
%     K = convhull(Pts,'simplify', true);
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
    % [LM] plot
    % plot3(Pts3(:,1), Pts3(:,2), Pts3(:,3),'.')

    % compute the edge length of the triangles of the convex hull
    % [LM] convenient arrangement for using diff and compute edge lengths
    % Pts3[n_points, x-y-z_coords, v1-v2-v3-v1_of_facets]
    Pts3(:,:,1)  = Pts(K(:,1),:);
    Pts3(:,:,2)  = Pts(K(:,2),:);
    Pts3(:,:,3)  = Pts(K(:,3),:);
    Pts3(:,:,4)  = Pts(K(:,1),:);
    
% % %===============================================================   
% %     % [LM] @RrenaultJB Note that the code below is partially incorrect.
% %     % you are overwriting the edge lengths of columns 2-3 BEFORE sortrow
% %     % so the EdgesLength variable actually does NOT necessarily include the
% %     % true longest edges.
% % %=============================================================== 
% % % PROPOSED CORRECTION
% % %=============================================================== 
% %     % edge lengths
% %     EdgeLength2 = squeeze(sqrt(sum(diff(Pts3,1,3).^2,2)));
% %     
% %     % sorting edge length (based on max length on facet)
% %     EdgesIdx_merged2=[];
% %     EdgesLength2 = [];
% %     for n = 1:3
% %         [EdgesIdx_col,I2] = sort(EdgeLength2(:,n),'descend');
% %         Ksorted_col = K(I2,n:mod(n,3)+1);
% %         % accumulate variables
% %         EdgesLength2 = [EdgesLength2; EdgesIdx_col];
% %         EdgesIdx_merged2 = [EdgesIdx_merged2; [Ksorted_col(:,n) Ksorted_col(:,mod(n,3)+1)]];
% %     end
% %     [EdgesLength, I_edge] = sort(EdgesLength2,'descend');
% %     IdxPointsPair = EdgesIdx_merged2(I_edge,:);
% % %===============================================================

    % diff across coords of vertices
    % EdgeLength = [n_points x 1 x 3(edges)]
    EdgeLength = sqrt(sum(diff(Pts3,1,3).^2,2));
    
    % sorting edge length
    % [LM] I = [n_points x 1 x 3(edges)]
    [EdgesIdx,I] = sort(EdgeLength,'descend');
    % reordering K indices in EdgesIdx so that they go from largest to smaller edge
    % indices stored in 2&3 col, so first column with length remains for
    % sortrow
    EdgesIdx(:,2:3,1) = [K(I(:,:,1),1) K(I(:,:,1),2)];
    EdgesIdx(:,2:3,2) = [K(I(:,:,2),2) K(I(:,:,2),3)];
    EdgesIdx(:,2:3,3) = [K(I(:,:,3),3) K(I(:,:,3),1)];
    
    % [LM] putting the vertices of the three edges together + ascending order
    % sorting (using edge length)
    EdgesIdx_merged = sortrows([EdgesIdx(:,:,1);EdgesIdx(:,:,2);EdgesIdx(:,:,3)],1);
    
    % [LM] and descending order again
    EdgesIdx_merged = flipud(EdgesIdx_merged);
    
    % outputs 
    %---------
    % the indices of the vertices
    IdxPointsPair = EdgesIdx_merged(:,2:3);
    % and their corresponding lengths
    EdgesLength = EdgesIdx_merged(:,1);

end

end


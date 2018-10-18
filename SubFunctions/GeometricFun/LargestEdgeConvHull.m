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
    
   
    K = convhull(Pts,'simplify', false);

    % compute the edge length of the triangles of the convex hull
    Pts3(:,:,1)  = Pts(K(:,1),:);
    Pts3(:,:,2)  = Pts(K(:,2),:);
    Pts3(:,:,3)  = Pts(K(:,3),:);
    Pts3(:,:,4)  = Pts(K(:,1),:);
    EdgeLength = sqrt(sum(diff(Pts3,1,3).^2,2));
    
    [EdgesIdx,I] = sort(EdgeLength,'descend');
    EdgesIdx(:,2:3,1) = [K(I(:,:,1),1) K(I(:,:,1),2)];
    EdgesIdx(:,2:3,2) = [K(I(:,:,2),2) K(I(:,:,2),3)];
    EdgesIdx(:,2:3,3) = [K(I(:,:,3),3) K(I(:,:,3),1)];
    
    EdgesIdx_merged = sortrows([EdgesIdx(:,:,1);EdgesIdx(:,:,2);EdgesIdx(:,:,3)],1);
    EdgesIdx_merged = flipud(EdgesIdx_merged);
    
    IdxPointsPair = EdgesIdx_merged(:,2:3);
    EdgesLength = EdgesIdx_merged(:,1);

end

end


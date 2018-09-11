function [ IdxPointsPair , EdgesLength , K, EdgesIdx_merged ] = LargestEdgeConvHull( Pts, Minertia )
%Compute the convex hull of the points cloud Pts and find the largest
% edge found by the convex hull
%   Detailed explanation goes here

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
    
%     Pts = bsxfun(@minus,Pts,mean(Pts));
%     [V,~] = eig(cov(Pts));
% %     [V,~] = eig(cov(Pts'*Pts));
%     Pts = (Pts*V);
%     Pts = round(Pts,6);


    
    K = convhull(Pts,'simplify', false);
%     K = convhull(Pts,'simplify', false);
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


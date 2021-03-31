% PLANPOLYGONCENTROID3D Find the centroid of a 2D Polygon, decribed by its
% boundary ( a close curve) in a 3D space.
% Works with arbitrary shapes (convex or not)
%
% [ Centroid, Area ] = PlanPolygonCentroid3D( Pts )
%
% Inputs:
%   Pts - A close curve in 3D space [nx3] matrix.
%
% Outputs:
%   Centroid - a 2x3 or 2x2 matrix of the pair of closest point.
%   Area - Area of the curves.
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ Centroid, Area ] = PlanPolygonCentroid3D( Pts )


if isequal(size(Pts), [0, 0])
    warning('PlanPolygonCentroid3D.m Empty Pts variable.')
    Centroid = nan;
    Area = nan;
    return
end

if Pts(1,:) ~= Pts(end,:)
    Pts(end+1,:) = Pts(1,:);
end

% Initial Guess of center
Center0 = mean(Pts(1:end-1,:));

% Middle Point of each polygon side
PtsMiddle = Pts(1:end-1,:) + diff(Pts)/2;

% Get the centroid of each points connected
TrianglesCentroid  = PtsMiddle - 1/3*bsxfun(@minus,PtsMiddle,Center0);

%Get the area of each triangles
[V,~] = eig(cov(Pts(1:end-1,:)));
n= V(:,1); % normal to polygon plan

TrianglesArea =1/2*cross(diff(Pts),-bsxfun(@minus,Pts(1:end-1,:),Center0))*n;

% Barycenter of triangles
Centroid = sum(TrianglesCentroid.*repmat(TrianglesArea,1,3))/sum(TrianglesArea);

if nargout>1
    Area = abs(sum(TrianglesArea));
end


end


% TRIMESH2DPROPERTIES Compute geometrical 2D properties of a triangulation object.
%
%   [ Properties ] = TriMesh2DProperties( TRin )
%
% Inputs:
%   Tr - A triangulation object.
%
% Outputs:
%   Properties - A structure with :
%       * Properties.Name ~ Name of the input variable.
%       * Properties.Area ~ Area of each element of input triangulation.
%       * Properties.Center ~ Centroid of the triangulation. Based on a weigthed
%                             by area mean of the triangles incenter.
%       * Properties.meanNormal ~ Mean normal vector of the triangulation. Based
%                               on a weigthed by area mean of the normal
%                               vector of each triangles.
%       * Properties.onMeshCenter ~ Closest point to Properties.Center in 
%                                   the triangulation.
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ Properties ] = TriMesh2DProperties( TR )

Properties.Name = inputname(1);

Properties.Area = 0.5*sum(cross(TR.Points(TR.ConnectivityList(:,2),:)-...
    TR.Points(TR.ConnectivityList(:,1),:),TR.Points(TR.ConnectivityList(:,3),:)-...
    TR.Points(TR.ConnectivityList(:,1),:)).*TR.faceNormal,2);

Properties.TotalArea = sum(Properties.Area);

Properties.Center = sum(TR.incenter.*repmat(Properties.Area,1,3),1)/Properties.TotalArea;


Properties.meanNormal =  sum(TR.faceNormal.*repmat(Properties.Area,1,3),1)/Properties.TotalArea;
Properties.meanNormal = Properties.meanNormal' /norm(Properties.meanNormal);

Properties.onMeshCenter = TR.Points(TR.nearestNeighbor(Properties.Center),:);


end


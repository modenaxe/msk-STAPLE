% TRIMESH2DPROPERTIES Compute some 2D properties of a triangulation object.
% ------------------------------------------------------------------------%
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


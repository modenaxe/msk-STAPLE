function [ NNID ] = TriDistanceMesh( TRfix , TReval )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
tic
NNID = TRfix.nearestNeighbor(TReval.Points);
toc

Area = 0.5*sum(cross(TReval.Points(TReval.ConnectivityList(:,2),:)-...
    TReval.Points(TReval.ConnectivityList(:,1),:),TReval.Points(TReval.ConnectivityList(:,3),:)-...
    TReval.Points(TReval.ConnectivityList(:,1),:)).*TReval.faceNormal,2);


ElmtID = TRfix.vertexAttachments(NNID);


TReval.Points

%Area of each triangle
Area = 0.5*sum(cross(TRfix.Points(TRfix.ConnectivityList(:,2),:)-...
    TRfix.Points(TRfix.ConnectivityList(:,1),:),TRfix.Points(TRfix.ConnectivityList(:,3),:)-...
    TRfix.Points(TRfix.ConnectivityList(:,1),:)).*TRfix.faceNormal,2);

% Calculate 


PtsOn = P - (P*TRfix.faceNormal(facesID,:))*TRfix.faceNormal(facesID,:)';
for facesID = 1:length(Face)
    
    
    v0 = TRfix.Points(TRfix.VertexConnectivity(facesID,3) - TRfix.Points(TRfix.VertexConnectivity(facesID,1));
    v1 = TRfix.Points(TRfix.VertexConnectivity(facesID,2) - TRfix.Points(TRfix.VertexConnectivity(facesID,1));
    v2 = PtsOn - TRfix.Points(TRfix.VertexConnectivity(facesID,1));
    
    dot00 = dot(v0, v0);
    dot01 = dot(v0, v1);
    dot02 = dot(v0, v2);
    dot11 = dot(v1, v1);
    dot12 = dot(v1, v2);
    
    
    U = (dot11 * dot02 - dot01 * dot12) / (dot00 * dot11 - dot01 * dot01);
    V = (dot00 * dot12 - dot01 * dot02) / (dot00 * dot11 - dot01 * dot01);

    TestPtIn = (U >= 0) & (V >= 0) & (U + V <= 1);


    




end


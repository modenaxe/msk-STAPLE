% -------------------------------------------------------------------------
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ PtOnMesh ] = TriPointOnMesh( TRin , Point )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

NNPtsID = TRin.nearestNeighbor(Point);

NeighboursElmtsID = cell2mat(TRin.vertexAttachments(NNPtsID));

% Adjacent triangles:

% 1] Project Point On Plan
TestOK = 0;
i=0;
while ~TestOK
    i = i+1;
    if i>length(NeighboursElmtsID)
        PtOnMesh = TRin.Points(TRin.nearestNeighbor(Point),:)
        TestOK = 1;
    else
        n = TRin.faceNormal(NeighboursElmtsID(i));
        V0 = TRin.Points(TRin.ConnectivityList(NeighboursElmtsID(i),1),:);
        V1 = TRin.Points(TRin.ConnectivityList(NeighboursElmtsID(i),2),:);
        V2 = TRin.Points(TRin.ConnectivityList(NeighboursElmtsID(i),3),:);
        u=V1'-V0'; v=V2'-V0';
        
        PtOnMesh = Point + ((V0-Point)*n')*n;
        
        w = PtOnMesh' - V0';
        
        denom = (u'*v)^2-(u'*u)*(v'*v);
        s1 = ((u'*v)*(w'*v) - (v'*v)*(w'*u))/denom;
        t1 = ((u'*v)*(w'*u) - (u'*u)*(w'*v))/denom;
        
        TestOK = (s1 >= 0) & (t1 >= 0) & (s1 <= 1) & (t1 <= 1) & (s1 + t1 <= 1)  ;
    end
end




end


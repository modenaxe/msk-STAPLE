function [ TRout ] = TriFillPlanarHoles( TRin)
%TRIFILLPLANARHOLES Fill planar convex holes in the triangulation
%   For now the holes have to be planar
%   FOR NOW WORKS WITH ONLY ONE HOLE

FB = TRin.freeBoundary;

HoleCenter = mean(TRin.Points(FB(:,1),:));
TriCenter =  mean(TRin.Points);

NewNode = length(TRin.Points)+1;
NewNodes = [TRin.Points;HoleCenter];

NewElements = [FB,ones(length(FB),1)*NewNode];

%% Check that the normals of the newly created element are properlu oriented
U = HoleCenter-TriCenter; U = U'/norm(U);
Vctrs1 = NewNodes(NewElements(:,2),:)' - NewNodes(NewElements(:,1),:)';
Vctrs2 = NewNodes(NewElements(:,3),:)' - NewNodes(NewElements(:,1),:)';

normals = transpose(cross(Vctrs1,Vctrs2));
normals = normals./repmat(sqrt(sum(normals.^2,2)),1,3);

% Invert node ordering if the normals are inverted
if mean(normals*U)<0
    NewElements = [FB(:,1),ones(length(FB),1)*NewNode,FB(:,2)];
end

%% Write output results
NewConnectivityList = [TRin.ConnectivityList;NewElements];
TRout = triangulation(NewConnectivityList,NewNodes);

end


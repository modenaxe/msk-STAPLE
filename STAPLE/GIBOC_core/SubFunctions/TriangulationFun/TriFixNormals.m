% TRIFIXNORMALS 
% Check if the triangulation is correctly oriented; normals should be
%pointing outwards. Randomly selct 2500 Points on the surface and move them
%by 5 mm in the normal direction. Fit a convexhull on the points before
%and after the move and compare volume. Volume should be higher after if
%normal are outwardly orientated.
% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TrOut ] = TriFixNormals( TrIn)


Nodes = TrIn.Points;
Elmts = TrIn.ConnectivityList;

Vctrs1 = Nodes(Elmts(:,2),:)' - Nodes(Elmts(:,1),:)';
Vctrs2 = Nodes(Elmts(:,3),:)' - Nodes(Elmts(:,1),:)';


normals = transpose(cross(Vctrs1,Vctrs2));

normals = normals./repmat(sqrt(sum(normals.^2,2)),1,3);

%% Check if normals point outwards

listnormals = round(linspace(1,length(normals),max(500,length(Nodes))));
[~,vol0] = convhulln(Nodes(Elmts(listnormals,1),:));
[~,vol1] = convhulln(Nodes(Elmts(listnormals,1),:)+5*normals(listnormals,:));

if vol1<vol0
    sprintf('The normal were pointing inwards, nodes order have been switched')
    Elmts = [Elmts(:,1) Elmts(:,3) Elmts(:,2)];
end

TrOut = triangulation(Elmts,Nodes);

end

% TRIFILLPLANARHOLES Fill planar convex holes in the triangulation
%   For now the holes have to be planar
%   FOR NOW WORKS WITH ONLY ONE HOLE
% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TRout ] = TriFillPlanarHoles( TRin)

FB = TRin.freeBoundary;

Pts = TRin.Points;
Segments = FB;

%%  Found and separate the holes
j=1;
Curves=struct();
i=1;
while ~isempty(Segments)
    % Initialise the Curves Structure, if there are multiple curves this
    % will lead to trailing zeros that will be removed afterwards
    Curves(i).NodesID = zeros(length(Pts),1);
    Curves(i).FB = [];
    
    % Initialise the first segment
    Curves(i).NodesID(j)=Segments(1,1);
    Curves(i).NodesID(j+1)=Segments(1,2);
    Curves(i).FB(end+1,:) = Segments(1,:);
    
    % Remove the segments added to Curves(i) from the segments matrix
    Segments(1,:)=[];
    j=j+1;
    
    % Find the edge in segments that has a node already in the curves(i).NodesID
    % This edge will be the next edge of the current curve because it's
    % connected to the current segment
    % Is, the index of the next edge
    % Js, the index of the node within this edge already present in NodesID
    [Is,Js] = ind2sub(size(Segments),find(Segments(:) == Curves(i).NodesID(j)));
    
    % Nk is the node of the previuously found edge that is not in the
    % current curves(i).NodeID list
    % round(Js+2*(1.5-Js)) give 1 if Js = 2 and 2 if Js = 1
    % It gives the other node not yet in NodesID of the identified next edge
    Nk = Segments(Is,round(Js+2*(1.5-Js)));
    
    Curves(i).FB(end+1,:) = Segments(Is,:);
    Segments(Is,:)=[];
    j=j+1;
    % Loop until there is no next node
    while ~isempty(Nk)
        Curves(i).NodesID(j) = Nk;
        [Is,Js] = ind2sub(size(Segments),find(Segments(:) == Curves(i).NodesID(j)));
        Is(2:end) = [];
        Js(2:end) = [];
        Nk = Segments(Is,round(Js+2*(1.5-Js)));
        if ~isempty(Nk)
            Curves(i).FB(end+1,:) = Segments(Is,:);
        end
        Segments(Is,:)=[];
        j=j+1;
    end
    % If there is on next node then we move to the next curve
    i=i+1;
end

if isempty(fields(Curves))
    % warning
    disp('No holes on triangulation.');
    TRout = TRin;
    return
else 
    for i = 1 : length(Curves)
        Curves(i).NodesID(Curves(i).NodesID==0) = [];
        Curves(i).Pts = Pts(Curves(i).NodesID,:);
    end
end


%% Fill the holes
NewNodes = TRin.Points;
NewNode = length(TRin.Points);
TriCenter =  mean(TRin.Points);
NewConnectivityList = TRin.ConnectivityList;

for i = 1 : length(Curves)
    HoleCenter = mean(Curves(i).Pts);
    NewNode = NewNode + 1;
    NewNodes(end+1,:) = HoleCenter;
    
    NewElements = [Curves(i).FB,ones(length(Curves(i).FB),1)*NewNode];
    
    U = HoleCenter-TriCenter; U = U'/norm(U);
    Vctrs1 = NewNodes(NewElements(:,2),:)' - NewNodes(NewElements(:,1),:)';
    Vctrs2 = NewNodes(NewElements(:,3),:)' - NewNodes(NewElements(:,1),:)';
    
    normals = transpose(cross(Vctrs1,Vctrs2));
    normals = normals./repmat(sqrt(sum(normals.^2,2)),1,3);
    
    % Invert node ordering if the normals are inverted
    if mean(normals*U)<0
        NewElements = [Curves(i).FB(:,1),...
            ones(length(Curves(i).FB),1)*NewNode,...
            Curves(i).FB(:,2)];
    end
    
    NewConnectivityList = cat(1, NewConnectivityList, NewElements);
end

TRout = triangulation(NewConnectivityList,NewNodes);


end


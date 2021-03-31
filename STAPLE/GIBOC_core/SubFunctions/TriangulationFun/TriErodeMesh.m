% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TRout ] = TriErodeMesh( TRin, nbElmts )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% Round the number of elements to upper integer;
nbElmts = ceil(nbElmts);

BorderNodesID = unique(TRin.freeBoundary);
ElmtsInitial = TRin.ConnectivityList;
ElmtsBorder = find(sum(ismember(ElmtsInitial,BorderNodesID),2)>0);
ElmtsInitial = ElmtsBorder;

if nbElmts>1
    for i = 1 : nbElmts-1
        ElmtNeighbours = unique(NotNaN(TRin.neighbors(ElmtsInitial)));
        ElmtsInitial = unique(ElmtNeighbours);
        ElmtsBorder = unique([ ElmtsBorder ; ElmtsInitial ]);
    end
end

ElmtsKept = ones(length(TRin.ConnectivityList),1);
ElmtsKept(ElmtsBorder) = 0;

TRout = TriReduceMesh( TRin, find(ElmtsKept));

end


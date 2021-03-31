% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TRout ] = TriConnectedPatch( TR, PtsInitial  )
%TriConnectedPatch : Find the connected mesh (elements sharing at least an
%edge) starting from a given point (not necessarily lying on the mesh)
%   Detailed explanation goes here

NodeInitial = TR.nearestNeighbor(PtsInitial);
NodeInitial = unique(NodeInitial);
ElmtsInitial = TR.vertexAttachments(NodeInitial);
ElmtsInitial = transpose(horzcat(ElmtsInitial{:}));
ElmtsConnected = ElmtsInitial;
test = 0;
while ~test
    PreviousLength = length(ElmtsConnected);
    ElmtNeighbours = unique(NotNaN(TR.neighbors(ElmtsInitial(:))));
    ElmtsInitial = unique(ElmtNeighbours);
    ElmtsConnected = unique([ ElmtsConnected(:) ; ElmtsInitial(:) ]);
    test = length(ElmtsConnected) == PreviousLength;
end

TRout = TriReduceMesh( TR, ElmtsConnected );

end


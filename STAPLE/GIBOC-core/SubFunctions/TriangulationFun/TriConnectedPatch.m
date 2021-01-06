% TRICONNECTEDPATCH On a triangulation object that might be composed
% of several unconnected regions, this function finds the connected region
% (elements sharing at least an edge) closest to a given point 
% (not necessarily lying on the mesh)
%
% [ TRout ] = TriConnectedPatch( TR, InitialPt )
%
% Inputs:
%   TR - A triangulation object.
%   InitialPt - A 1x3 or 3x1 coordinate vector of the point relative to 
%               which the closest connected patch must be identified.
%                 
%   
% Outputs:
%   TRout - A triangulation object.
%           The closest to InitialPt connected subset of TR.
%
% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TRout ] = TriConnectedPatch( TR, InitialPt )
    NodeInitial = TR.nearestNeighbor(InitialPt);
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


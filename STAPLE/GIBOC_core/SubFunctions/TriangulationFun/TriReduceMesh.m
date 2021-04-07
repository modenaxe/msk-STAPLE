% TRIREDUCEMESH Get a subset of triangulation object from a list of
% triangle elements id or a list of nodes (vertices) id.
%
% [ TRout ] = TriReduceMesh( TR, ElmtsKept, NodesKept )
%
% Inputs:
%   TR - A triangulation object of n elements
%   ElmtsKept - A mx1 (m<n) vectors of index of the rows of kept elments, 
%               or a nx1 binary vector indicating kept elements.
%   NodesKept : A kx1 (k<n) vector of id of kept nodes. Id(s) must
%               corresponds to TR connectibity list. 
%               Or kx3 list of nodes coordinates.
%
% Outputs:
%   TRout - A triangulation object, a subset of TR containing the elements
%           or nodes provided in inputs.
%
%--------------------------------------------------------------------------
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TRout ] = TriReduceMesh( TR, ElmtsKept, NodesKept )

if nargin >2
    
    if sum(sum(mod(NodesKept,1))) == 0 % NodesID given
        NodesIDKept = NodesKept;
    else % Nodes Coordinates given
        NodesIDKept = TR.nearestNeighbor(NodesKept);
        NodesIDKept = unique(NodesIDKept);
    end
    
    ElmtsKept = TR.vertexAttachments(NodesIDKept);
    ElmtsKept = unique(transpose(horzcat(ElmtsKept{:})));
end
     
    ElmtsNodesIDKept = TR.ConnectivityList(ElmtsKept,:);
    NodesKept = unique(ElmtsNodesIDKept(:));
    PointsKept = TR.Points(NodesKept,:);
    
    IndexTrsfrm = zeros(length(TR.Points),1);
    IndexTrsfrm(NodesKept) = 1 : length(NodesKept);

    ElmtKeptNewNodeId = IndexTrsfrm(ElmtsNodesIDKept);
    
    % Deal with case with only one element kept
    if size(IndexTrsfrm(ElmtsNodesIDKept),2) ~= 3
        ElmtKeptNewNodeId = ElmtKeptNewNodeId';
    end
    
    TRout = triangulation(ElmtKeptNewNodeId,PointsKept);
end


% TRIERODEMESH Remove n layers of triangles at the border of triangulation
% This function is analog to a erode function performed on binary images.
% (https://en.wikipedia.org/wiki/Mathematical_morphology)
%
% Inputs:
%   TRin - a triangulation object to be eroded (analog to the white pixels
%          of the binary image). The elements on the border of the triangulation
%          will be removed recursively nbElmts times.
%   nbElmts - The number of border elements/facets that will be eroded 
%             (analog to the number of pixel of the dilation). If the number
%             is not an integer it will be rounded up to the next integer
%   
% Outputs:
%   TRout - The eroded triangulation, a subset of TRin.
%
% See also TRICLOSEMESH, TRIOPENMESH, TRIERODEMESH
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TRout ] = TriErodeMesh( TRin, nbElmts )

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


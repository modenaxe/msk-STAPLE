% TRIDILATEMESH
% This function is analog to a dilate function performed on binary images 
% (https://en.wikipedia.org/wiki/Mathematical_morphology)
% In :
%   - TRsup :   a support triangulation object (analog to the whole image)
%   - TRin :    a triangulation object to be dilated (analog to the white pixels of the binary image)
%               TRin must me a subset (a region) of the TRsup triangulation, meaning that all vertices and elements of TRin
%               are included in TRsup even if they don't share the same numberings of vertices and elements.
%   - nbElemts : The number of neigbour elements/facets that will be dilated (analog to the number of pixel of the dilation)
% Out :
%   - TRout : the dilated triangulation
% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%

function [ TRout ] = TriDilateMesh( TRsup, TRin, nbElmts )

% Round the number of elements to upper integer;
nbElmts = ceil(nbElmts);

% returns the rows of the intersection in the same order as they appear 
% in the first vector given as input.
[~, ia ,ic] = intersect(TRsup.Points, TRin.Points,'rows','stable');

% Get the elements attached to the identified vertices
ElmtsOK = TRsup.vertexAttachments(ia)';
% Initially, ElmtsOk are the elements on TRsup that correspond to the geometry of the TRin
ElmtsOK = transpose(unique(horzcat(ElmtsOK{:})));
ElmtsInitial = ElmtsOK;

% Get the neighbours of the identified elements, loop 
for i = 1:nbElmts
    % Identify the neighbours of the elements of the ElmtsOK subset
    ElmtNeighbours = unique(NotNaN(TRsup.neighbors(ElmtsInitial)));
    ElmtsInitial = unique(ElmtNeighbours);
    % Add the new neighbours to the list of elements ElmtsOK
    ElmtsOK = unique([ ElmtsOK ; ElmtsInitial ]);
end

% The output is a subset of TRsup with ElmtsOK
TRout = TriReduceMesh( TRsup, ElmtsOK);

end

function [Y] = NotNaN(X)
% Keep only not NaN elements of a vector, because some
Y = X(~isnan(X));
end

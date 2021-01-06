% COMPUTETRICOEFFMORPHO Compute coeffecient that adapt
% other tri morphological operation to triangulation object
% that are not made of triangles with edge lengths different
% than 0.5 mm.
% 
% [ CoeffMorpho ] = computeTriCoeffMorpho(TR)
%
% Inputs:
%   TR - A triangulation object 
%
% Outputs:
%   CoeffMorpho - A ratio between expected edge length 0.5 and
%                 actual edge length of TR
%
% -------------------------------------------------------------------------
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ CoeffMorpho ] = computeTriCoeffMorpho(TR)

    % Get the mean edge length of the triangles composing a triangulation object
    % This is necessary because the functions were originally developed for
    % triangulation with constant mean edge lengths of 0.5 mm
    PptiesTriObj = TriMesh2DProperties( TR );

    % Assume triangles are equilaterals and get mean edge length
    meanEdgeLength = sqrt( 4/sqrt(3) * PptiesTriObj.TotalArea / TriObj.size(1) );

    % Get the coefficient for morphology operations
    CoeffMorpho = 0.5 / meanEdgeLength;
end
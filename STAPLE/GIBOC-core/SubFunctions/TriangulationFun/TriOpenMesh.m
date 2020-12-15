% TRIOPENMESH Perform open morphological operations on a triangulation.
% This works analogously to binary image morphological operations. Here,
% A triangular facet is analogous to a pixel. There is a triangulation object
% (TRsup) whose role is analogous to the image grid, and another triangulation 
% object (TRin) which define the subset of "white" triangles, all triangles in
% TRSup but not in TRin play the role of "black" pixel. 
% TRsup and TRin are subset of the same original triangulation object, and each
% triangle of TRin must also be part of TRsup.
% When applied this function will output a triangulation containing the triangles
% of TRin minus the ones forming bridges or spikes on the TRin border.
% In general this function will sharpen the border of TRin, might increase holes
% size and disconnect connected parts of TRin.  
% 
% [ TRout ] = TriOpenMesh( TRsup , TRin , nbElmts )
%
% Inputs:
%   TRsup - A support triangulation object. Analogous to the image grid.
%   TRin - The input triangulation, a subset of TRsup. Analogous to the 
%          white pixels in binary image morphological operation.
%   nbElmts - The number of layer of triangles to substract then add around
%             TRin boundaries. Analogous to number of pixel in binary image
%             morphological operation. If the number is not an integer it 
%             will be rounded up to the next integer.
%   
% Outputs:
%   TRout - The opened triangulation object.
%
%
% See also TRIDILATEMESH, TRIERODEMESH, TRICLOSEMESH
% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TRout ] = TriOpenMesh( TRsup , TRin , nbElmts )
    [ TR ] = TriErodeMesh( TRin, nbElmts );
    [ TRout ] = TriDilateMesh( TRsup, TR, nbElmts );
end


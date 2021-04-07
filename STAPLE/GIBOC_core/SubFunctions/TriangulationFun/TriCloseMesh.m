% TRICLOSEMESH Perform close morphological operations on a triangulation.
% This works analogously to binary image morphological operations. Here,
% A triangular facet is analogous to a pixel. There is a triangulation object
% (TRsup) whose role is analogous to the image grid, and another triangulation 
% object (TRin) which define the subset of "white" triangles, all triangles in
% TRSup but not in TRin play the role of "black" pixel. 
% TRsup and TRin are subset of the same original triangulation object, and each
% triangle of TRin is also part of TRsup.
% If two regions of TRin are connected by less than 2 x nbElmts triangles of TRsup,
% when applied this function will output a triangulation containing the triangles
% of TRin plus the ones of TRsup making the connection.
% In general this function will smooth the border of TRin might close holes and
% connect disconnected part of TRin.  
% 
% [ TRout ] = TriCloseMesh( TRsup , TRin , nbElmts )
%
% Inputs:
%   TRsup - A support triangulation object. Analogous to the image grid.
%   TRin - The input triangulation, a subset of TRsup. Analogous to the 
%          white pixels in binary image morphological operation.
%   nbElmts - The number of layer of triangles to add then substract around
%             TRin boundaries. Analogous to number of pixel in binary image
%             morphological operation. If the number is not an integer it 
%             will be rounded up to the next integer.
%   
% Outputs:
%   TRout - The closed triangulation object.
%
% See also TRIDILATEMESH, TRIERODEMESH, TRIOPENMESH
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TRout ] = TriCloseMesh( TRsup , TRin , nbElmts )


[ TR ] = TriDilateMesh( TRsup, TRin, nbElmts );
[ TRout ] = TriErodeMesh( TR, nbElmts );

end


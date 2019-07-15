function [ TRout ] = TriOpenMesh( TRsup , TRin , nbElmts )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

[ TR ] = TriErodeMesh( TRin, nbElmts );
[ TRout ] = TriDilateMesh( TRsup, TR, nbElmts );

end


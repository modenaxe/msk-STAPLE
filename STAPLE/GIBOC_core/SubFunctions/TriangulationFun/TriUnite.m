% TRIUNITE Unite triangulation objects TR1, TR2 to make a
% single TR object. All elements and nodes of TR1 and TR2 are kept. This
% is not a 3D boolean unite, if nodes of TR1 are inside TR2 that will still
% be the case after the unite is performed. This function will not connect
% TR1 and TR2.
%
% [ TR_united ] = TriUnite( TR1, TR2 )
%
% Inputs:
%   TR1 - A triangulation object of n1 elements
%   TR2 - A triangulation object of n2 elements
%
% Outputs:
%   TR_united - A triangulation object of n1 + n2 elements. Composed of 
%               both TR1 and TR2.
%
%--------------------------------------------------------------------------
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%--------------------------------------------------------------------------
function [ TR_united ] = TriUnite( TR1, TR2 )
    
    ConnectivityList = vertcat(TR1.ConnectivityList ,...
                               TR2.ConnectivityList + length(TR1.Points));
    Points = vertcat(TR1.Points, TR2.Points);

    TR_united =  triangulation(ConnectivityList, Points);
end


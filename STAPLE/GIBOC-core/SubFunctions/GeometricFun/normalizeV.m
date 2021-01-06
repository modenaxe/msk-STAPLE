% NORMALIZEV Normalize the vector or list of vectors V
%
% [ Vnormalized ] = normalizeV( V )
%
% Inputs:
%   V - A vector or matrix of vectors
%
% Outputs:
%   Vnormalized - A normalized vector or list of normalized vectors 
%
% -------------------------------------------------------------------------
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ Vnormalized ] = normalizeV( V )
        
    % Transpose v if necessary to get a vertically orientated vector  
    if min(size(V)) == 1
        if size(V,1) ~= length(V)
            V = V';
        end
        Vnormalized = V / norm(V);
    
    % Raise error if V is squared 
    elseif size(V,1) == size(V,2)
        error('input matrix is squared we can not tell if vector are in columns or lines')
    
    % Case for V being a list of vectors
    else
        % Transpose V if necessary to get vertically orientated vectors
        if  size(V,1) ~= length(V)
            V = V';
        end
        Vnorm = sqrt(sum(V.^2,2));
        Vnormalized = V./repmat(Vnorm,1,3);
    end

end


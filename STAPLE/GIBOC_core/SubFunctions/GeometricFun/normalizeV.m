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
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%

function [ Vnormalized ] = normalizeV( V )
	% NORMALIZEV Normalize the vector or list of vectors 
	%
	% 
	%
	% Parameters
	% ----------
	% V : [3x3] float matrix
	% 	A vector or matrix of vector
	%
	% Returns
	% -------
	% Vnormalized : [3x3] float matrix
	% 	A normalized vector or list of normalized vectors
	%
	%


if min(size(V)) == 1
    if size(V,1) ~= length(V)
        V = V';
    end
    Vnormalized = V / norm(V);
    
elseif size(V,1) == size(V,2)
    error('input matrix is squared we can not tell if vector are in columns or lines')
else
    if  size(V,1) ~= length(V)
        V = V';
    end
    Vnorm = sqrt(sum(V.^2,2));
    Vnormalized = V./repmat(Vnorm,1,3);
end

end


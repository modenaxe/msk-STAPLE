% NOTNAN Keep only not NaN elements of a vector
%
%   [Y] = NotNaN(X)
%
% Inputs:
%   X - A vector of length n that may contain some NaNs
%
% Outputs:
%   Y - A vector of length m <= n that does not contain any NaN
%
% ------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [Y] = NotNaN(X)
X = X(:);
Y = X(~isnan(X));
end

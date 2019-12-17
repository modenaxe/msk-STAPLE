function [Y] = NotNaN(X)
% Keep only not NaN elements of a vector
X = X(:);
Y = X(~isnan(X));
end

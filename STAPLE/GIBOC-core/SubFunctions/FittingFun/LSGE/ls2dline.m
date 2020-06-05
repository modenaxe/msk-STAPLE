  function [x0, a, d, normd] = ls2dline(X) 
% ---------------------------------------------------------------------
% LS2DLINE.M   Least-squares line in the plane.
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% ---------------------------------------------------------------------
% Input    
% X        Array [x y] where x = vector of x-coordinates, 
%          y = vector of y-coordinates. 
%          Dimension: m x 2. 
% 
% Output   
% x0       Centroid of the data = point on the best-fit line.
%          Dimension: 2 x 1. 
% 
% a        Direction cosines of the best-fit line. 
%          Dimension: 2 x 1.
% 
% <Optional... 
% d        Residuals. 
%          Dimension: m x 1. 
% 
% normd    Norm of residual errors. 
%          Dimension: 1 x 1. 
% ...>
%
% [x0, a <, d, normd >] = ls2dline(X)
% ---------------------------------------------------------------------

% check number of data points 
  m = size(X, 1);
  if m < 2
    error('At least 2 data points required: ' )
  end
%
% calculate centroid
  x0 = mean(X)';
%
% form matrix A of translated points
  A = [(X(:, 1) - x0(1)) (X(:, 2) - x0(2))];
%
% calculate the SVD of A
  [U, S, V] = svd(A, 0);
%
% find the larger singular value in S and extract from V the
% corresponding right singular vector
  [s, i] = max(diag(S));
  a = V(:, i);
% 
% calculate residual distances, if required  
  if nargout > 2 
    n = [-a(2) a(1)]'; 
    d = A * n; 
    normd = norm(d); 
  end % if nargout 
% ---------------------------------------------------------------------
% End of LS2DLINE.M
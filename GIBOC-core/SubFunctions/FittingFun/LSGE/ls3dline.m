  function [x0, a, d, normd] = ls3dline(X)
% ---------------------------------------------------------------------
% LS3DLINE.M   Least-squares line in 3 dimensions.
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% ---------------------------------------------------------------------
% Input    
% X        Array [x y z] where x = vector of x-coordinates, 
%          y = vector of y-coordinates and z = vector of 
%          z-coordinates. 
%          Dimension: m x 3. 
% 
% Output   
% x0       Centroid of the data = point on the best-fit line.
%          Dimension: 3 x 1. 
% 
% a        Direction cosines of the best-fit line. 
%          Dimension: 3 x 1.
% 
% <Optional... 
% d        Residuals. 
%          Dimension: m x 1. 
% 
% normd    Norm of residual errors. 
%          Dimension: 1 x 1. 
% ...>
%
% [x0, a <, d, normd >] = ls3dline(X)
% ---------------------------------------------------------------------

% check number of data points 
  m = size(X, 1);
  if m < 3
    error('At least 3 data points required: ' )
  end
%
% calculate centroid
  x0 = mean(X)';
%
% form matrix A of translated points
  A = [(X(:, 1) - x0(1)) (X(:, 2) - x0(2)) (X(:, 3) - x0(3))];
%
% calculate the SVD of A
  [U, S, V] = svd(A, 0);
%
% find the largest singular value in S and extract from V the
% corresponding right singular vector
  [s, i] = max(diag(S));
  a = V(:, i);
% 
% calculate residual distances, if required  
  if nargout > 2 
    m = size(X, 1); 
    d = zeros(m, 1); 
    for i = 1:m 
      d(i) = norm(cross((X(i, 1:3)' - x0), a)); 
    end % for i 
    normd = norm(d); 
  end % if nargout 
% ---------------------------------------------------------------------
% End of LS3DLINE.M
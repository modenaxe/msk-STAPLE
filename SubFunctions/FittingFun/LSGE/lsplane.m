  function [x0, a, d, normd] = lsplane(X, a0)
% ---------------------------------------------------------------------
% LSPLANE.M   Least-squares plane (orthogonal distance
%             regression).
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% Modified       J B Renault 12 Jan 2017
% ---------------------------------------------------------------------
% Input    
% X        Array [x y z] where x = vector of x-coordinates, 
%          y = vector of y-coordinates and z = vector of 
%          z-coordinates. 
%          Dimension: m x 3. 
%
%
% <Optional... 
% a0       Array  [v1; v2; v3] a vector to establish proper 
%          orientation for for plan normal.
%          Dimension: 3 x 1.
% ...>
%
% Output   
% x0       Centroid of the data = point on the best-fit plane.
%          Dimension: 1 x 3. 
% 
% a        Direction cosines of the normal to the best-fit 
%          plane. 
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
% [x0, a <, d, normd >] = lsplane(X)
% ---------------------------------------------------------------------

% check number of data points 
  m = size(X, 1);
  if m < 3
    error('At least 3 data points required: ' )
  end
%
% calculate centroid
  x0 = mean(X);
%
% form matrix A of translated points
  A = [(X(:, 1) - x0(1)) (X(:, 2) - x0(2)) (X(:, 3) - x0(3))];
%
% calculate the SVD of A
  [U, S, V] = svd(A, 0);
%
% find the smallest singular value in S and extract from V the
% corresponding right singular vector
  [s, i] = min(diag(S));
  a = V(:, i);
%
% Invert (or don"t) normal direction so to have same orientation as a0
if nargin > 1
    a = sign(a0'*a) * a;
end
% calculate residual distances, if required  
  if nargout > 2
    d = U(:, i)*s;
    normd = norm(d);
  end
% ---------------------------------------------------------------------
% End of LSPLANE.M.
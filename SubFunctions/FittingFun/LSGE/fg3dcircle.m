  function [f, J] = fg3dcircle(a, X, w)
% ---------------------------------------------------------------------
% FG3DCIRCLE.M   Function and gradient calculation for 
%                least-squares circle fit.
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% ---------------------------------------------------------------------
% Input 
% a        Parameters [x0 y0 z0 alpha beta s]'.
%          Dimension: 6 x 1.
%
% X        Array [x y z] where x = vector of x-coordinates, 
%          y = vector of y-coordinates and z = vector of z-coordinates. 
%          Dimension: m x 3. 
%
% <Optional...  
% w        Weights. 
%          Dimension: m x 1. 
% ...>
% 
% Output
% f        Vector [f1; f2] where f1 = vector of distances from the 
%          points to the plane containing the circle and f2 = vector 
%          of distances from the points to the cylinder containing 
%          the circle. 
%          Dimension: 2m x 1. 
%
% <Optional... 
% J        Jacobian matrix df(i)/da(j). 
%          Dimension: 2m x 6. 
% ...> 
%
% Modular structure: FGRROT3.M, FRROT3.M, DRROT3.M. 
%
% [f <, J >] = fg3dcircle(a, X <, w >)
% ---------------------------------------------------------------------

  m = size(X, 1); 
% if no weights are specified, use unit weights 
  if nargin == 2 
    w = ones(m, 1); 
  end % if nargin 
% 
  x0 = a(1); 
  y0 = a(2); 
  z0 = a(3); 
  alpha = a(4); 
  beta = a(5); 
  s = a(6); 
% 
  [R, DR1, DR2] = fgrrot3([alpha beta 0]'); 
% 
  Xt = (X - ones(m, 1) * [x0 y0 z0]) * R'; 
  xt = Xt(:, 1); 
  yt = Xt(:, 2); 
  zt = Xt(:, 3); 
% 
  rt = sqrt(xt.*xt + yt.*yt); 
  Nt1 = [xt./rt yt./rt zeros(m, 1)]; 
  f1 = dot(Xt, Nt1, 2); 
  f1 = f1 - s; 
  f1 = w .* f1; % incorporate weights 
  Nt2 = [zeros(m, 2) ones(m, 1)]; 
  f2 = dot(Xt, Nt2, 2); 
  f2 = w .* f2; % incorporate weights 
  f = [f1; f2]; 
% 
  if nargout > 1 % form the Jacobian matrix 
    J1 = zeros(m, 6); % derivatives of f1 
    J2 = zeros(m, 6); % derivatives of f2 
    A1 = ones(m, 1) * (R * [-1 0 0]')'; 
    J1(:, 1) = dot(A1, Nt1, 2); 
    J2(:, 1) = dot(A1, Nt2, 2); 
    A2 = ones(m, 1) * (R * [0 -1 0]')'; 
    J1(:, 2) = dot(A2, Nt1, 2); 
    J2(:, 2) = dot(A2, Nt2, 2); 
    A3 = ones(m, 1) * (R * [0 0 -1]')'; 
    J1(:, 3) = dot(A3, Nt1, 2); 
    J2(:, 3) = dot(A3, Nt2, 2); 
    A4 = (X - ones(m, 1) * [x0 y0 z0]) * DR1'; 
    J1(:, 4) = dot(A4, Nt1, 2); 
    J2(:, 4) = dot(A4, Nt2, 2); 
    A5 = (X - ones(m, 1) * [x0 y0 z0]) * DR2'; 
    J1(:, 5) = dot(A5, Nt1, 2); 
    J2(:, 5) = dot(A5, Nt2, 2); 
    J1(:, 6) = -1 * ones(m, 1); 
    J2(:, 6) = zeros(m, 1); 
    W = diag(w); 
    J1 = W * J1; % incorporate weights 
    J2 = W * J2; % incorporate weights 
    J = [J1; J2]; 
  end % if nargout
% ---------------------------------------------------------------------
% End of FG3DCIRCLE.M. 
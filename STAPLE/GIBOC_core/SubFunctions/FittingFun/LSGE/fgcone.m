  function [f, J] = fgcone(a, X, w)
% ---------------------------------------------------------------------
% FGCONE.M   Function and gradient calculation for 
%            least-squares cone fit.
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% ---------------------------------------------------------------------
% Input 
% a        Parameters [x0 y0 alpha beta phi s]'.
%          Dimension: 6 x 1.
%
% X        Array [x y z] where x = vector of x-coordinates, 
%          y = vector of x-coordinates and z = vector of y-coordinates 
%          Dimension: m x 3 
%
% <Optional...  
% w        Weights 
%          Dimension: m x 1 
% ...>
% 
% Output
% f       Signed distances of points to cone:
%         f(i) = cos(phi) * [sqrt(xh(i)^2 + yh(i)^2) - s] + 
%                sin(phi) * zh(i), where 
%         [xh yh zh]' = Ry(beta) * Rx(alpha) * ([x y z]' - [x0 y0 0]').
%         Dimension: m x 1.
%
% <Optional... 
% J       Jacobian matrix df(i)/da(j).
%         Dimension: m x 6.
% ...> 
%
% Modular structure: FGRROT3.M, FRROT3.M, DRROT3.M. 
%
% [f <, J >] = fgcone(a, X <, w >) 
% ---------------------------------------------------------------------

  m = size(X, 1); 
% if no weights are specified, use unit weights 
  if nargin == 2 
    w = ones(m, 1); 
  end % if nargin 
% 
  x0 = a(1); 
  y0 = a(2); 
  alpha = a(3); 
  beta = a(4); 
  phi = a(5); 
  s = a(6); 
% 
  [R, DR1, DR2] = fgrrot3([alpha beta 0]'); 
% 
  Xt = (X - ones(m, 1) * [x0 y0 0]) * R'; 
  xt = Xt(:, 1); 
  yt = Xt(:, 2); 
  rt = sqrt(xt.*xt + yt.*yt); 
  Nt = [(xt./rt)*cos(phi) (yt./rt)*cos(phi) sin(phi)*ones(m, 1)]; 
  DNt = [-(xt./rt)*sin(phi) -(yt./rt)*sin(phi) cos(phi)*ones(m, 1)]; 
  f = dot(Xt, Nt, 2); 
  f = f - s * cos(phi); 
  f = w .* f; % incorporate weights 
%
  if nargout > 1 % form the Jacobian matrix
    J = zeros(m, 6); 
    A1 = ones(m, 1) * (R * [-1 0 0]')'; 
    J(:, 1) = dot(A1, Nt, 2); 
    A2 = ones(m, 1) * (R * [0 -1 0]')'; 
    J(:, 2) = dot(A2, Nt, 2); 
    A3 = (X - ones(m, 1) * [x0 y0 0]) * DR1'; 
    J(:, 3) = dot(A3, Nt, 2); 
    A4 = (X - ones(m, 1) * [x0 y0 0]) * DR2'; 
    J(:, 4) = dot(A4, Nt, 2); 
    J(:, 5) = dot(Xt, DNt, 2) + s * sin(phi); 
    J(:, 6) = -cos(phi) * ones(m, 1); 
    W = diag(w); 
    J = W * J; % incorporate weights 
  end % if nargout 
% ---------------------------------------------------------------
% End of FGCONE.M.
  function [f, J] = fgtorus(a, X, w)
% ---------------------------------------------------------------------
% FGTORUS.M   Function and gradient for distance to a torus.
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% ---------------------------------------------------------------------
% Input 
% a        Parameters [x0 y0 z0 theta1 theta2 rb sb]'.
%          Dimension: 7 x 1.
%
% X        Array [x y z] where x = vector of x-coordinates, 
%          y = vector of x-coordinates and z = vector of y-coordinates.  
%          Dimension: m x 3. 
% 
% <Optional...  
% w        Weights. 
%          Dimension: m x 1. 
% ...> 
% 
% Output
% f        Distances of points to the torus. 
%          Dimension: m x 1. 
% 
% <Optional... 
% J        Jacobian matrix df(i)/da(j). 
%          Dimension: m x 7. 
% ...> 
%
% Modular structure: FGBRRT3.M, FGRROT3.M, FRROT3.M, DRROT3.M, CSR.M. 
% 
% [f <, J >] = fgtorus(a, X <, w >)
% ---------------------------------------------------------------------

% check number of data points 
  m = size(X, 1);
  if m < 7
    error('At least 7 data points required: ' )
  end
% 
% if no weights are specified, use unit weights 
  if nargin == 2 
    w = ones(m, 1); 
  end % if nargin 
% 
  tt = [a(1:5); 0]; 
  r0 = a(6); 
  s0 = a(7); 
%
  if nargout == 1 
    [Xb] = fgbrrt3(tt, X); 
  else 
    [Xb, Jx, Jy, Jz] = fgbrrt3(tt, X); 
  end 
%
  x = Xb(:,1); 
  y = Xb(:,2); 
  z = Xb(:,3); 
%
  [c, s, r] = csr(x, y);
  e = r - r0;
  d = z;
  [cg, sg, g] = csr(e, d);
%
  f = g - s0; 
  f = w.*f; % incorporate weights 
%
  if nargout > 1 % form the Jacobian matrix 
    N = [c.*cg, s.*cg, sg];
    for k = 1:5
      J(:, k) = (w .* Jx(:, k)) .* N(:, 1) + (w .* Jy(:, k)) .* N(:, 2) + (w .* Jz(:, k)) .* N(:, 3);
    end % for k 
    J(:, 6) = - cg .* w;
    J(:, 7) = - w;
 end % if nargout
% ---------------------------------------------------------------------
% End of FGTORUS.M.
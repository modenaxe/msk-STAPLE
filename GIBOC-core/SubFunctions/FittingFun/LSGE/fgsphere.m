  function [f, J] = fgsphere(a, X, w)
% ---------------------------------------------------------------------
% FGSPHERE.M   Function and gradient calculation for 
%              least-squares sphere fit.
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% ---------------------------------------------------------------------
% Input 
% a        Parameters [x0 y0 z0 r0]'.
%          Dimension: 4 x 1.
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
% f       Signed distances of points to sphere:
%         f(i) = sqrt((x(i)-x0)^2 + (y(i)-y0)^2 + (z(i)-z0)^2) - r0.
%         Dimension: m x 1.
%
% <Optional... 
% J       Jacobian matrix df(i)/da(j).
%         Dimension: m x 4.
% ...> 
%
% [f <, J >] = fgsphere(a, X <, w >)
% ---------------------------------------------------------------------

  m = size(X, 1); 
% if no weights are specified, use unit weights 
  if nargin == 2 
    w = ones(m, 1); 
  end % if nargin 
% 
  xt = X(:,1) - a(1);
  yt = X(:,2) - a(2);
  zt = X(:,3) - a(3);
%
  ri = sqrt(xt.*xt + yt.*yt + zt.*zt);
  f = ri - a(4);
  f = w .* f; % incorporate weights 
%
  if nargout > 1 % form the Jacobian matrix
    J = - [xt./ri,  yt./ri, zt./ri ones(length(xt), 1)];
    W = diag(w); 
    J = W * J; % incorporate weights 
  end % if nargout
% ---------------------------------------------------------------------
% End of FGSPHERE.M.
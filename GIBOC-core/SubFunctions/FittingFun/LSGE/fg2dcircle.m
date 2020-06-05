  function [f, J] = fg2dcircle(a, X, w)
% ---------------------------------------------------------------------
% FG2DCIRCLE.M   Function and gradient calculation for 
%                least-squares circle fit in the plane.
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% ---------------------------------------------------------------------
% Input 
% a        Parameters [x0 y0 r0]'.
%          Dimension: 3 x 1.
%
% X        Array [x y] where x = vector of x-coordinates and 
%          y = vector of y-coordinates. 
%          Dimension: m x 2. 
%
% <Optional... 
% w        Weights. 
%          Dimension: m x 1. 
% ...> 
% 
% Output
% f        Signed distances of points to circle:
%          f(i) = sqrt((x(i)-x0)^2 + (y(i)-y0)^2) - r0.
%          Dimension: m x 1.
%
% <Optional... 
% J        Jacobian matrix df(i)/da(j).
%          Dimension: m x 3.
% ...> 
%
% [f <, J >] = fg2dcircle(a, X <, w >) 
% ---------------------------------------------------------------------

  m = size(X, 1); 
% if no weights are specified, use unit weights 
  if nargin == 2 
    w = ones(m, 1); 
  end % if nargin 
% 
  xt = X(:,1) - a(1); 
  yt = X(:,2) - a(2); 
%
  ri = sqrt(xt.*xt + yt.*yt); 
  f = ri - a(3); 
  f = w .* f; % incorporate weights 
%
  if nargout > 1 % form the Jacobian matrix 
    J = - [xt./ri,  yt./ri, ones(length(xt), 1)]; 
    W = diag(w); 
    J = W * J; % incorporate weights 
  end % if nargout 
% ---------------------------------------------------------------------
% End of FG2DCIRCLE.M.
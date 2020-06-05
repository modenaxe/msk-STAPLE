  function [c, s, r] = csr(x, y)
% ---------------------------------------------------------------------
% CSR.M   Calculate r, c = x/r and s = y/r where 
%         r = sqrt(x^2 + y^2).
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% ---------------------------------------------------------------------
% Input 
% x        Array of x-coordinates. 
%          Dimension: m x 1. 
% 
% y        Array of x-coordinates. 
%          Dimension: m x 1. 
% 
% Output 
% c        Array x/r. 
%          Dimension: m x 1. 
% 
% s        Array y/r. 
%          Dimension: m x 1. 
% 
% r        Array r. Note that if r = 0, i.e., x = y = 0, then 
%          c = s = 0.
%          Dimension: m x 1. 
% 
% [c, s, r] = csr(x, y)
%
% References:   Matrix Computations by Golub and van Loan,
%               North Oxford Academic, Oxford, 1983.
% ----------------------------------------------------------------------

  m = length(x); 
  c = zeros(m,1); 
  s = c; 
  r = c; 
%
  Nz =  x ~= 0 | y ~= 0; 
  Ny = abs(y) > abs(x) & Nz; 
  Nx = ~Ny & Nz; 
%
% The ~Nz terms have been assigned. Assign the Ny terms. 
  if any(Ny), 
    t = x(Ny)./abs(y(Ny)); 
    q = sqrt(1 + t.*t); 
%
    s(Ny) = sign(y(Ny))./q; 
    c(Ny) = t.*abs(s(Ny)); 
    r(Ny) = abs(y(Ny)).*q; 
  end % if Ny 
%
% Assign the Nx terms 
  if any(Nx), 
    t = y(Nx)./abs(x(Nx)); 
    q = sqrt(1 + t.*t); 
    c(Nx) = sign(x(Nx))./q; 
    s(Nx) = t.*abs(c(Nx)); 
    r(Nx) = abs(x(Nx)).*q; 
  end % if Nx 
% ------------------------------------------------------------------
% End of CSR.M
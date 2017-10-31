  function [c, iconv, sp, sg] = gncc2(f0, f1, p, g, scale, tolr, scalef)
% --------------------------------------------------------------------------
% GNCC2   Gauss-Newton convergence conditions.
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% --------------------------------------------------------------------------
% Input 
% f0       Norm of residuals at old point: norm(f(a)) 
%          Dimension: 1 x 1.
% 
% f1       Norm of residuals at new point: norm(f(a + p))
%          Dimension: 1 x 1.
%
% p        Step
%          Dimension: n x 1.
% 
% g        Gradient
%          Dimension: n x 1.
% 
% scale    Scale for columns of Jacobian matrix.
%          Dimension: n x 1.
% 
% tolr     Relative tolerance.
%          Dimension: 1 x 1.
% 
% scalef   Scale for function values. 
%          Dimension: 1 x 1.
%
% Output 
% c        Convergence indices in the form of ratio of value over
%          scaled tolerance.
%          c(1) size of step
%          c(2) change in function value
%          c(3) size of gradient
%          c(4) sum of squares near zero
%          c(5) gradient near zero
%          Dimension: 1 x 5.
% 
% iconv    = 1 if convergence criteria have been met, i.e., 
%          C(1), C(2), C(3) < 1 or 
%                      C(4) < 1 or 
%                      C(5) < 1.
%          = 0 otherwise.
%          Dimension: 1 x 1.
%
% sp       Scaled size of the step.
%          Dimension: 1 x 1.
% 
% sg       Scaled size of the gradient.
%          Dimension: 1 x 1.
%
% [c, iconv, sp, sg] = gncc2(f0, f1, p, g, scale, tolr, scalef)
% -------------------------------------------------------------------------- 

  iconv = 0;
%
  sp = max(abs(p .* scale));
  sg = max(abs(g ./ scale));
%
  c(1) = sp/(scalef * tolr^(0.7));
%
  delf = f0 - f1;
  c(2) = abs(delf)/(tolr * scalef);
%
  d3 = (tolr^(0.7)) * (scalef);
  d4 = scalef * (eps^(0.7));
  d5 = (eps^(0.7)) * (scalef);
%
  c(3) = sg/d3;
  c(4) = f1/d4;
  c(5) = sg/d5;
%
  if c(1) < 1 &  c(2) < 1 & c(3) < 1
    iconv = 1;
  elseif (c(4)) < 1 
    iconv = 1;
  elseif (c(5) < 1)
    iconv = 1;
  end
% --------------------------------------------------------------------------
% End of GNCC2.M.
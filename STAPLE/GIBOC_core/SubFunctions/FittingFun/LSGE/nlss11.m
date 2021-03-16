  function [a, f, R, GNlog] = nlss11(ai,tol,fguser,p1,p2,p3,p4,p5,p6, ... 
            p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
% --------------------------------------------------------------------------
% NLSS11.M   Nonlinear least squares solver:
%            Minimise f'*f where 
%            [f, J] = fguser(a, p1, p2,...).
%
% Author   A B Forbes, CMSC, NPL.
% Amendment history
% v1.1  2002-05-03 IMS Prepared for MetroS. 
% v1.1  2002-01-04 ABF Output a, f, GNlog set to latest value.
% v1.1  2001-07-09 ABF Optional input arguments increased.
% v1.1  2000-12-19 ABF Better convergence criteria. Column scaling.
% v1.0a 1999-07-16 ABF Statistics removed.
% v1.0a 1999-07-16 ABF Created.
% --------------------------------------------------------------------------
% Input 
% ai       Optimisation parameters, intial estimates.
%          Dimension: n x 1
%
% tol      Convergence tolerances [tolr tols]', where 
%          tolr = relative tolerance, and 
%          tols = scale for function values. 
%          Dimension: 2 x 1. 
%
% fguser   Module to calculate function and gradients with
%          signature
%          [f, J] = fguser(a, p1, p2,...).
%
% p1,...   Additional parameters to be passed to fguser 
%          without change.
%          Note: The number of additional parameters supported is 20. 
%           
% Output 
% a        Solution estimates of the optimisation parameters.
%          Dimension: n x 1.
%
% f        Functions evaluated at a.
%          Dimension: m x 1.
%          Constraint: m >= n.
% 
% R        Triangular factor of the Jacobian matrix evaluated at a.
%          Dimension: n x n.
%
% GNlog    Log of the Gauss-Newton iterations. 
%          Rows 1 to niter contain 
%          [iter, norm(f_iter), |step_iter|, |gradient_iter|]. 
%          Row (niter + 1) contains 
%          [conv, norm(d), 0, 0]. 
%          Dimension: (niter + 1) x 4. 
% 
% Modular structure: GNCC2.M. 
% 
% [a, f, R, GNlog] = nlss11(a, tol, 'fguser', p1, p2, p3, ...)
% --------------------------------------------------------------------------

  a0 = ai;
%
  n = length(a0);
%
  if n == 0
    error('Empty vector of parameter estimates:')
  end
%
% Set up call to fguser:
% [f0, J ] = fguser(a0,p1,p2,....);
  callfg0 = [fguser,'(a0',];
  for k = 1:nargin-3
    callfg0 = [callfg0,',p',int2str(k),];
  end % for k
  callfg0 = [callfg0,')'];     
%
% [f1] = fguser(a1,p1,p2,....);
  callfg1 = [fguser,'(a1',];
  for k = 1:nargin-3
    callfg1 = [callfg1,',p',int2str(k),];
  end % for k
  callfg1 = [callfg1,')'];     
%
  mxiter = (100+ceil(sqrt(n)));
  conv = 0;
  niter = 0;
%
  eta = 0.01;
%
  GNlog = [];
%
% G-N iterations
  while niter < mxiter & conv == 0
%
    [f0, J] = eval(callfg0);
    if niter == 0 % scale by norm of columns of J 
      [mJ,nJ] = size(J);
      scale = zeros(nJ,1);
      for j = 1:nJ;
        scale(j) = norm(J(:,j));
      end 
    end % if niter
%
    m = length(f0);
% Check on m, n.
    if niter == 0 & m < n
      error('Number of observation less than number of parameters')
    end
%
% Calculate update step and gradient.
    F0 = norm(f0);
    Ra = triu(qr([J, f0]));
    R = Ra(1:nJ,1:nJ);
    q = Ra(1:nJ,nJ+1);
    p = -R\q;
    g = 2*R'*q;
    G0 = g'*p;
    a1 = a0 + p;
    niter = niter + 1;
%
% Check on convergence.
    [f1] = eval(callfg1);
    F1 = norm(f1);
    [c, conv, sp, sg] = gncc2(F0, F1, p, g, scale, tol(1), tol(2));
%
    if conv ~= 1
%
% ...otherwise check on reduction of sum of squares.
%
% Evaluate f at a1.
      rho = (F1 - F0)*(F1 + F0)/(G0);
      if rho < eta
        tmin = max([0.001; 1/(2*(1-rho))]);
        a0 = a0 + tmin*p;
      else
        a0 = a0 + p;
      end % if rho
%
    end % if conv
%
    GNlog = [GNlog; [niter, F0, sp, sg]];
%
  end % while niter 
% 
  a = a0+p;
  f = f1;
%
  GNlog = [GNlog; [conv, F1, 0, 0]];
%
% --------------------------------------------------------------------------
% End of NLSS11.M. 
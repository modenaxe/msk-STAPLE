  function [x0n, rn, d, sigmah, conv, Vx0n, urn, GNlog, a, R] = ... 
           ls2dcircle(X, x0, r, tolp, tolg, w)
% ---------------------------------------------------------------------
% LS2DCIRCLE.M   Least-squares circle in the plane using Gauss-Newton.
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% ---------------------------------------------------------------------
% Input    
% X        Array [x y] where x = vector of x-coordinates and 
%          y = vector of y-coordinates. 
%          Dimension: m x 2. 
% 
% x0       Estimate of the circle centre. 
%          Dimension: 2 x 1. 
%
% r        Estimate of the circle radius. 
%          Dimension: 1 x 1. 
% 
% tolp     Tolerance for test on step length. 
%          Dimension: 1 x 1. 
%
% tolg     Tolerance for test on gradient.
%          Dimension: 1 x 1. 
% 
% <Optional... 
% w        Weights. 
%          Dimension: m x 1. 
% ...> 
% 
% Output  
% x0n      Estimate of the circle centre. 
%          Dimension: 2 x 1. 
% 
% rn       Estimate of the circle radius. 
%          Dimension: 1 x 1. 
% 
% d        Vector of weighted radial distances from the points
%          to the circle. 
%          Dimension: m x 1. 
% 
% sigmah   Estimate of the standard deviation of the weighted 
%          residual errors. 
%          Dimension: 1 x 1. 
% 
% conv     If conv = 1 the algorithm has converged, 
%          if conv = 0 the algorithm has not converged
%          and x0n, rn, d, and sigmah are current estimates. 
%          Dimension: 1 x 1. 
% 
% Vx0n     Covariance matrix of circle centre. 
%          Dimension: 2 x 2. 
%
% urn      Uncertainty in circle radius. 
%          Dimension: 1 x 1. 
% 
% GNlog    Log of the Gauss-Newton iterations. 
%          Rows 1 to niter contain 
%          [iter, norm(f_iter), |step_iter|, |gradient_iter|]. 
%          Row (niter + 1) contains 
%          [conv, norm(d), 0, 0]. 
%          Dimension: (niter + 1) x 4. 
% 
% a        Optimisation parameters at the solution.
%          Dimension: 3 x 1. 
%             
% R        Upper-triangular factor of the Jacobian matrix
%          at the solution. 
%          Dimension: 3 x 3. 
%             
% Modular structure: NLSS11.M, GNCC2.M, FG2DCIRCLE.M. 
%
% [x0n, rn, d, sigmah, conv, Vx0n, urn, GNlog, a, R] = ... 
%   ls2dcircle(X, x0, r, tolp, tolg <, w >)
% ---------------------------------------------------------------------

% check number of data points 
  m = size(X, 1);
  if m < 3
    error('At least 3 data points required: ' )
  end
% 
% if no weights are specified, use unit weights 
  if nargin == 5 
    w = ones(m, 1); 
  end % if nargin 
% 
% find the centroid and translate the data and centre
% estimate
  xb  = mean(X)'; 
%
  xt  = X(:, 1) - xb(1);
  yt  = X(:, 2) - xb(2);
  Xt = [xt yt]; 
  x0b = x0 - xb;
%
  ai = [x0b; r]; 
  tol = [tolp; tolg]; 
% 
% Gauss-Newton algorithm to find estimate of centre and radius
  [a, d, R, GNlog] = nlss11(ai, tol, 'fg2dcircle', Xt, w); 
% 
  x0n = a(1:2); 
% translate circle centre 
  x0n = x0n + xb; 
  rn = a(3); 
% 
  nGN = size(GNlog, 1); 
  conv = GNlog(nGN, 1); 
  if conv == 0 
    beep; 
    warning('*** Gauss-Newton algorithm has not converged ***'); 
  end % if conv 
% 
% calculate statistics 
  dof = m - 3; 
  sigmah = norm(d)/sqrt(dof); 
  G = eye(3); 
  Gt = R'\(sigmah * G); % R' * Gt = sigmah * G' 
  Va = Gt'*Gt; 
  Vx0n = Va(1:2, 1:2); % covariance matrix for x0n 
  urn = sqrt(Va(3, 3)); % uncertainty in rn 
% ---------------------------------------------------------------------
% End of LS2DCIRCLE.M.
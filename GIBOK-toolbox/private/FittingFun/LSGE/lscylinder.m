 function [x0n, an, rn, d, sigmah, conv, Vx0n, Van, urn, GNlog, ... 
          a, R0, R] = lscylinder(X, x0, a0, r0, tolp, tolg, w)
% ---------------------------------------------------------------------
% LSCYLINDER.M   Least-squares cylinder using Gauss-Newton.
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% ---------------------------------------------------------------------
% Input    
% X        Array [x y z] where x = vector of x-coordinates, 
%          y = vector of y-coordinates and z = vector of z-coordinates.
%          Dimension: m x 3. 
% 
% x0       Estimate of the point on the axis. 
%          Dimension: 3 x 1. 
%
% a0       Estimate of the axis direction. 
%          Dimension: 3 x 1. 
% 
% r0       Estimate of the cylinder radius. 
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
% x0n      Estimate of the point on the axis. 
%          Dimension: 3 x 1. 
% 
% an       Estimate of the axis direction. 
%          Dimension: 3 x 1. 
% 
% rn       Estimate of the cylinder radius. 
%          Dimension: 1 x 1. 
% 
% d        Vector of radial distances from the points
%          to the cylinder. 
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
% Vx0n     Covariance matrix of point on the axis. 
%          Dimension: 3 x 3. 
%
% Van      Covariance matrix of axis direction. 
%          Dimension: 3 x 3. 
%
% urn      Uncertainty in cylinder radius. 
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
%          Dimension: 5 x 1. 
% 
% R0       Fixed rotation matrix. 
%          Dimension: 3 x 3. 
% 
% R        Upper-triangular factor of the Jacobian matrix
%          at the solution. 
%          Dimension: 5 x 5. 
%
% Modular structure: NLSS11.M, GNCC2.M, FGCYLINDER.M, ROT3Z.M, GR.M, 
%                    FGRROT3.M, FRROT3.M, DRROT3.M. 
%
% [x0n, an, rn, d, sigmah, conv, Vx0n, Van, urn, GNlog, a, R0, R] = 
%   lscylinder(X, x0, a0, r0, tolp, tolg <, w >)
% ---------------------------------------------------------------------

% check number of data points 
  m = size(X, 1);
  if m < 5
    error('At least 5 data points required: ' )
  end
% 
% if no weights are specified, use unit weights 
  if nargin == 6 
    w = ones(m, 1); 
  end % if nargin 
% 
% find the centroid of the data 
  xb = mean(X)'; 
% 
% transform the data to close to standard position via a rotation 
% followed by a translation 
  R0 = rot3z(a0); % U * a0 = [0 0 1]' 
  x1 = R0 * x0; 
  xb1 = R0 * xb; 
% find xp, the point on axis nearest the centroid of the rotated data 
  t = x1 + (xb1(3) - x1(3)) * [0 0 1]'; 
  X2 = (X * R0') - ones(m ,1) * t'; 
  x2 = x1 - t; 
  xb2 = xb1 - t; 
% 
  ai = [0 0 0 0 r0]'; 
  tol = [tolp; tolg]'; 
% 
% Gauss-Newton algorithm to find estimate of roto-translation 
% parameters that transform the data so that the best-fit circle is 
% one in standard position
  [a, d, R, GNlog] = nlss11(ai, tol, 'fgcylinder', X2, w); 
% 
% inverse transformation to find axis and point on axis 
% corresponding to original data 
  rn = a(5); 
  [R3, DR1, DR2, DR3] = fgrrot3([a(3:4); 0]); 
  an = R0' * R3' * [0 0 1]'; % axis 
  p = R3 * (xb2 - [a(1) a(2) 0]'); 
  pz = [0 0 p(3)]'; 
  x0n = R0' * (t + [a(1) a(2) 0]' + R3' * pz); 
% x0n = point on axis in plane containing centroid of data 
% 
  nGN = size(GNlog, 1); 
  conv = GNlog(nGN, 1); 
  if conv == 0 
    beep; 
    warning('*** Gauss-Newton algorithm has not converged ***'); 
  end % if conv 
% 
% calculate statistics 
  dof = m - 5; 
  sigmah = norm(d)/sqrt(dof); 
  ez = [0 0 1]'; 
  G = zeros(7, 5); 
% derivatives of x0n 
  dp1 = R3 * [-1 0 0]'; 
  dp2 = R3 * [0 -1 0]'; 
  dp3 = DR1 * (xb2 - [a(1) a(2) 0]'); 
  dp4 = DR2 * (xb2 - [a(1) a(2) 0]'); 
  G(1:3, 1) = R0' * ([1 0 0]' + R3' * [0 0 dp1'*ez]'); 
  G(1:3, 2) = R0' * ([0 1 0]' + R3' * [0 0 dp2'*ez]'); 
  G(1:3, 3) = R0' * (DR1' * [0 0 p'*ez]' + R3' * [0 0 dp3'*ez]'); 
  G(1:3, 4) = R0' * (DR2' * [0 0 p'*ez]' + R3' * [0 0 dp4'*ez]'); 
% derivatives of an 
  G(4:6, 3) = R0' * DR1' * [0 0 1]'; 
  G(4:6, 4) = R0' * DR2' * [0 0 1]'; 
% derivatives of rn 
  G(7, 5)   = 1; 
  Gt = R'\(sigmah * G'); % R' * Gt = sigmah * G' 
  Va = Gt' * Gt; 
  Vx0n = Va(1:3, 1:3); % covariance matrix for x0n 
  Van = Va(4:6, 4:6); % covariance matrix for an 
  urn = sqrt(Va(7, 7)); % uncertainty in rn 
% ---------------------------------------------------------------------
% End of LSCYLINDER.M.
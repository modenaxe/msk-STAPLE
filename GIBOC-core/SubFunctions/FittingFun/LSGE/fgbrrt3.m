  function [Xb, Jbx, Jby, Jbz] = fgbrrt3(tt, X, R0)
% ----------------------------------------------------------------------
% FGBRRT3.M   Function and gradient blocks for the rototranslation
%             [xb]                                        [x - x0]
%             [yb] = R3(theta3)*R2(theta2)*R1(theta1)*R0* [y - y0]
%             [zb]                                        [z - z0].
% 
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% ---------------------------------------------------------------------- 
% Input 
% tt       Array of parameters [x0 y0 z0 theta1 theta2 theta3]'.
%          Dimension: 6 x 1. 
% 
% X        Array [x y z] where x = vector of x-coordinates, 
%          y = vector of y-coordinates and z = vector of z-coordinates. 
%          Dimension: m x 3. 
% 
% <Optional...  
% R0       Fixed rotation matrix. 
%          Dimension: 3 x 3. 
% ...> 
%
% Output
% Xb       Array [xb, yb, zb] of transformed points. 
%          Dimension: m x 3. 
% 
% <Optional...  
% Jbx      Derivatives of the x coordinates of the transformed 
%          points with respect to the transformation parameters. 
%          Dimension: m x 6. 
% 
% Jby      Derivatives of the y coordinates of the transformed 
%          points with respect to the transformation parameters. 
%          Dimension: m x 6. 
% 
% Jbz      Derivatives of the z coordinates of the transformed 
%          points with respect to the transformation parameters. 
%          Dimension: m x 6. 
% ...> 
% 
% Modular structure: FGRROT3.M.
%
% [Xb <, Jbx, Jby, Jbz >] = fgbrrt3(tt, X <, R0 >)
% -----------------------------------------------------------------------------

  x0 = tt(1:3);
  theta = tt(4:6);
% 
% if no rotation matrix is specified, use the identity matrix 
  if nargin == 2 
    R0 = eye(3); 
  end % if nargin 
%
% form rotation matrices and their derivatives 
  [R, d1R, d2R, d3R] = fgrrot3(theta, R0);
%
% transform data points 
  xt = X(:,1) - x0(1);   
  yt = X(:,2) - x0(2);  
  zt = X(:,3) - x0(3);
%
  Xb = [xt yt zt] * R'; 
%
  if nargout > 1 % calculate derivatives 
    m = length(xt);
    om = ones(m, 1);
%
    dx = - [R(1, 1) * om, R(1, 2) * om, R(1, 3) * om];
    dy = - [R(2, 1) * om, R(2, 2) * om, R(2, 3) * om];
    dz = - [R(3, 1) * om, R(3, 2) * om, R(3, 3) * om];
%
    Xr1 = [xt yt zt] * d1R';
%
    dx = [dx, Xr1(:, 1)];
    dy = [dy, Xr1(:, 2)];
    dz = [dz, Xr1(:, 3)];
%
    Xr2 = [xt yt zt] * d2R';
%
    dx = [dx, Xr2(:, 1)];
    dy = [dy, Xr2(:, 2)];
    dz = [dz, Xr2(:, 3)];
%
    Xr3 = [xt yt zt] * d3R';
%
    dx = [dx, Xr3(:, 1)];
    dy = [dy, Xr3(:, 2)];
    dz = [dz, Xr3(:, 3)];
%
    Jbx = dx;  
    Jby = dy; 
    Jbz = dz;
  end % if nargout 
% -----------------------------------------------------------------
% End of FGBRRT3.M.
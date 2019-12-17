  function [U] = rot3z(a)
% --------------------------------------------------------------------------
% ROT3Z.M   Form rotation matrix U to rotate the vector a to a point along
%           the positive z-axis. 
%
% Version 1.0   
% Last amended  I M Smith 2 May 2002. 
% Created       I M Smith 2 May 2002. 
% --------------------------------------------------------------------------
% Input 
% a        Vector.
%          Dimension: 3 x 1. 
%
% Output 
% U        Rotation matrix with U * a = [0 0 z]', z > 0. 
%          Dimension: 3 x 3. 
% 
% Modular structure: GR.M. 
%
% [U] = rot3z(a)
% --------------------------------------------------------------------------

% form first Givens rotation
  [W, c1, s1] = gr(a(2), a(3));
  z = c1*a(2) + s1*a(3);
  V = [1 0 0; 0 s1 -c1; 0 c1 s1];
%
% form second Givens rotation
  [W, c2, s2] = gr(a(1), z);
%
% check positivity
  if c2 * a(1) + s2 * z < 0
    c2 = -c2;
    s2 = -s2;
  end  % if
%
  W = [s2 0 -c2; 0 1 0; c2 0 s2];
  U = W * V;
% --------------------------------------------------------------------------
% End of ROT3Z.M.
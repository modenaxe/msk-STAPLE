  function [R, R1, R2, R3] = frrot3(theta, U0)
% --------------------------------------------------------------------------
% FRROT3.M   Form rotation matrix R = R3*R2*R1*U0. - use right-handed
%            rotation matrices.
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% --------------------------------------------------------------------------
% Input 
% theta    Array of plane rotation angles (t1, t2, t3).
%          Dimension: 3 x 1. 
% 
% <Optional...  
% U0       Rotation matrix, optional, with default R0 = I.
%          Dimension: 3 x 3. 
% ...>
%
% Output 
% R        Rotation matrix. 
%          Dimension: 3 x 3. 
% 
% R1       Plane rotation [1 0 0; 0 c1 -s1; 0 s1 c1].
%	       Dimension: 3 x 3. 
% 
% <Optional...  
% R2       Plane rotation [c2 0 s2; 0 1 0; -s2 0 c2].
%          Dimension: 3 x 3. 
% 
% R3       Plane rotation [c3 -s3 0; s3 c3 0; 0 0 1].
%          Dimension: 3 x 3. 
% ...>
%
% [R, R1 <, R2, R3 >] = frrot3(theta <, U0 >)
% --------------------------------------------------------------------------

  ct = cos(theta); 
  st = sin(theta);
%
  if length(theta) > 0
    R1 = [ 1 0 0; 0 ct(1) -st(1); 0 st(1) ct(1)];
    R = R1;
  end %if
%
  if length(theta) > 1
    R2 = [ ct(2) 0 st(2); 0 1 0; -st(2) 0 ct(2)];
    R = R2*R;
  end % if
%
  if length(theta) > 2
    R3 = [ ct(3) -st(3) 0; st(3) ct(3) 0; 0 0 1];
    R = R3*R;
   end % if
%
  if nargin > 1
    R = R*U0;
  end % if
% --------------------------------------------------------------------------
% End of FRROT3.M.
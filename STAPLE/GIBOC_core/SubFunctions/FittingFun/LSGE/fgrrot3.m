  function [R, DR1, DR2, DR3] = fgrrot3(theta, R0)
% --------------------------------------------------------------------------
% FGRROT3.M   Form rotation matrix R = R3*R2*R1*R0 and its derivatives 
%             using right-handed rotation matrices:
%
%             R1 = [ 1  0   0 ]  R2 = [ c2 0  s2 ] and R3 = [ c3 -s3 0 ]
%                  [ 0 c1 -s1 ],      [ 0  1   0 ]          [ s3  c3 0 ].
%                  [ 0 s1  c2 ]       [-s2 0  c2 ]          [  0   0 1 ]
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
% R0       Rotation matrix, optional, with default R0 = I.
%          Dimension: 3 x 3. 
% ...>
%
% Output 
% R        Rotation matrix.
%          Dimension: 3 x 3. 
% 
% <Optional...  
% DR1      Derivative of R wrt t1.
%          Dimension: 3 x 3. 
% 
% DR2      Derivative of R wrt t2.
%          Dimension: 3 x 3. 
% 
% DR3      Derivative of R wrt t3.
%          Dimension: 3 x 3. 
% ...>
%
% Modular structure: FRROT3.M, DRROT3.M. 
%
% [R <, DR1, DR2, DR3 >] = fgrrot3(theta <, R0 >)
% --------------------------------------------------------------------------

  if nargin == 1
    R0 = eye(3);
  end % if
%
  [R, R1, R2, R3] = frrot3(theta, R0);
%
% Evaluate the derivative matrices if required.
  if nargout > 1
    [dR1, dR2, dR3] = drrot3(R1, R2, R3);
    DR1 = R3*R2*dR1*R0;
    DR2 = R3*dR2*R1*R0;
    DR3 = dR3*R2*R1*R0;
  end % if
% --------------------------------------------------------------------------
% End of FGRROT3.M.
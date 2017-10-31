  function [dR1, dR2, dR3] = drrot3(R1, R2, R3)
% --------------------------------------------------------------------------
% DRROT3.M   Calculate the derivatives of plane rotations - 
%            use right-handed rotation matrices.
%
% Version 1.0    
% Last amended   I M Smith 27 May 2002. 
% Created        I M Smith 08 Mar 2002
% --------------------------------------------------------------------------
% Input 
% R1       Plane rotation of the form
%          [1 0 0; 0 c1 -s1; 0 s1 c1]. 
%          Dimension: 3 x 3. 
% 
% <Optional...  
% R2       Plane rotation of the form
%          [c2 0 s2; 0 1 0; -s2 0 c2]. 
%          Dimension: 3 x 3. 
% 
% R3       Plane rotation of the form
%          [c3 -s3 0; s3 c3 0; 0 0 1]. 
%          Dimension: 3 x 3. 
% ...>
%
% Output 
% dR1      Derivative of R1 with respect to rotation angle. 
%          [0 0 0; 0 -s1 -c1; 0 c1 -s1]. 
%          Dimension: 3 x 3. 
% 
% <Optional...  
% dR2      Derivative of R2 with respect to rotation angle. 
%          [-s2 0 c2; 0 0 0; -c2 0 -s2]. 
%          Dimension: 3 x 3. 
% 
% dR3      Derivative of R3 with respect to rotation angle. 
%          [-s3 -c3 0; c3 -s3 0; 0 0 0]. 
%          Dimension: 3 x 3. 
% ...>
% 
% [dR1 <, dR2, dR3 >] = drrot3(R1 <, R2, R3 >)
% --------------------------------------------------------------------------

  if nargin > 0
    dR1 = [0 0 0; 0 -R1(3, 2) -R1(2, 2); 0 R1(2, 2) -R1(3, 2)];
  end % if nargin 
%
  if nargin > 1
    dR2 = [-R2(1, 3) 0 R2(1, 1); 0 0 0; -R2(1, 1) 0 -R2(1, 3)];
  end % if nargin 
%
  if nargin > 2
    dR3 = [-R3(2, 1) -R3(1, 1) 0; R3(1, 1) -R3(2, 1) 0; 0 0 0];
  end % if nargin 
% --------------------------------------------------------------------------
% End of DRROT3.M.
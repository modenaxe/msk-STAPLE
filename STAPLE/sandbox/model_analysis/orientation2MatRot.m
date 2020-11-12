%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
function RotMat = orientation2MatRot(XYZ_orientation)
% Transforms Euler XYZ body-fixed rotation angles used to express the orientation
% in OpenSim model in their rotation matrix

% compute all parts
c = cos(XYZ_orientation);
s = sin(XYZ_orientation);
% assign to elements of the matrix
[c1, c2, c3] = deal(c(1), c(2), c(3));
[s1, s2, s3] = deal(s(1), s(2), s(3));
% matrix for XYZ fixed-body rotation (see
% https://en.wikipedia.org/wiki/Euler_angles)
RotMat = [  c2*c3               -c2*s3          s2
            c1*s3+c3*s1*s2   c1*c3-s1*s2*s3   -c2*s1
            s1*s3-c1*c3*s2   c3*s1+c1*s2*s3    c1*c2];
        
end
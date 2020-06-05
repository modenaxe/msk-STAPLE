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
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
function orientation = computeXYZAngleSeq(aRotMat)
% fixed body sequence of angles from rot mat usable for orientation in
% OpenSim

beta  = atan2(aRotMat(1,3),                   sqrt(aRotMat(1,1)^2.0+aRotMat(1,2)^2.0));
alpha = atan2(-aRotMat(2,3)/cos(beta),        aRotMat(3,3)/cos(beta));
gamma = atan2(-aRotMat(1, 2)/cos(beta),       aRotMat(1,1)/cos(beta));

% build a vector
orientation = [  alpha  beta  gamma];
end
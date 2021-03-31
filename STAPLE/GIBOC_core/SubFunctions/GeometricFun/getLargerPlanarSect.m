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
% gets the larger section in a set of curves.
% use mostly by GIBOC_tibia
function [Curve, N_curves, Areas] = getLargerPlanarSect(Curves)

N_curves = length(Curves);

% check to use just the tibial curve, as in GIBOK
for nc = 1: N_curves
    Areas(nc) = Curves(nc).Area;
end
[~, ind_max_area] = max(Areas);
Curve = Curves(ind_max_area);

end
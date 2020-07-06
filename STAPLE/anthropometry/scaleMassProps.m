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
% This function scales mass and inertia of the bodies of an OpenSim model
% assuming that the geometry stays constant and only the mass changes.
% The coefficient coeff is used for both inertia and mass
function osimModel = scaleMassProps(osimModel, coeff)
% import libraries
import org.opensim.modeling.*

% get bodyset
subjspec_bodyset = osimModel.getBodySet;

for n_b = 1:subjspec_bodyset.getSize()-1
    
    curr_body = subjspec_bodyset.get(n_b);
    
    % updating the mass
    curr_body.setMass(coeff* curr_body.getMass);
    
    % updating the inertia matrix for the change in mass
    m = curr_body.get_inertia();
    
    % components of inertia
    xx = m.get(0)*coeff;
    yy = m.get(1)*coeff;
    zz = m.get(2)*coeff;
    xy = m.get(3)*coeff;
    xz = m.get(4)*coeff;
    yz = m.get(5)*coeff;
    upd_inertia = Inertia(xx , yy , zz , xy , xz , yz);
    
    % updating Inertia
    curr_body.setInertia(upd_inertia);
    
    clear m
end

end
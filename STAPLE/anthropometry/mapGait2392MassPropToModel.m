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
function osimModel = mapGait2392MassPropToModel(osimModel)

% import libraries
import org.opensim.modeling.*

N_bodies = osimModel.getBodySet.getSize();

for n_b = 0:N_bodies-1
    curr_body = osimModel.getBodySet.get(n_b);
    curr_body_name = char(curr_body.getName());
    % retried mass properties of gait2392
    massProp = gait2392MassProps(curr_body_name);
    % retrieve segment to update
    curr_body = osimModel.getBodySet.get(curr_body_name);
    % assign mass
    curr_body.setMass(massProp.mass);
    % build a matrix of inertia with the gait2392 values
    xx = massProp.inertia_xx;
    yy = massProp.inertia_yy;
    zz = massProp.inertia_zz;
    xy = 0.0;
    xz = 0.0;
    yz = 0.0;
    upd_inertia = Inertia(xx , yy , zz , xy , xz , yz);
    % set inertia
    curr_body.setInertia(upd_inertia);
    disp(['Updated inertia of body: ', char(curr_body_name)])
    clear m
end

end
    



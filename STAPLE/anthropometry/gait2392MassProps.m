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
function MP = gait2392MassProps(segment_name)
% Note that the Rajagopal model has the same lower limb inertial
% properties, which is why I added the patella from that model.
% torso differs because that model has arms.

if ~(strcmp(segment_name, 'pelvis') || strcmp(segment_name, 'torso'))
    % get rid of side
    segment_name = segment_name(1:end-2);
end
    
switch segment_name
    case 'pelvis'
        MP.mass=11.777;
        MP.mass_center=[ -0.0707 0 0];
        MP.inertia_xx=0.1028;
        MP.inertia_yy=0.0871;
        MP.inertia_zz=0.0579;
    case 'femur'
        MP.mass=9.3014;
        MP.mass_center= [0 -0.17 0];
        MP.inertia_xx=0.1339;
        MP.inertia_yy=0.0351;
        MP.inertia_zz=0.1412;
    case 'tibia'
        MP.mass=3.7075;
        MP.mass_center= [0 -0.1867 0];
        MP.inertia_xx=0.0504;
        MP.inertia_yy=0.0051;
        MP.inertia_zz=0.0511;
    case 'talus'
        MP.mass=0.1;
        MP.mass_center= [0 0 0];
        MP.inertia_xx=0.001;
        MP.inertia_yy=0.001;
        MP.inertia_zz=0.001;
    case 'calcn'
        MP.mass=1.25;
        MP.mass_center= [0.1 0.03 0];
        MP.inertia_xx=0.0014;
        MP.inertia_yy=0.0039;
        MP.inertia_zz=0.0041;
    case 'toes'
        MP.mass=0.2166;
        MP.mass_center= [0.0346 0.006 -0.0175];
        MP.inertia_xx=0.0001;
        MP.inertia_yy=0.0002;
        MP.inertia_zz=0.0001;
    case 'torso'
        MP.mass=34.2366;
        MP.mass_center= [-0.03 0.32 0];
        MP.inertia_xx=1.4745;
        MP.inertia_yy=0.7555;
        MP.inertia_zz=1.4314;
    case 'patella' % different from Rajagopal that has arms
        MP.mass=0.0862;
        MP.mass_center= [0.0018 0.0264 0];
        MP.inertia_xx=2.87e-006;
        MP.inertia_yy=1.311e-005;
        MP.inertia_zz=1.311e-005;
    otherwise
        error('Please specify a segment name among those included in the gait2392 model');
end

end
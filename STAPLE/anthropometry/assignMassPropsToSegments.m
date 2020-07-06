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
function osimModel = assignMassPropsToSegments(osimModel, JCS, subj_mass)

% A MESS WITH THE DIMENSIONS OF THE JCS.origin....TO FIX!
%---------------------------------------------
% compute COM positions
thigh_axis = JCS.femur_r.hip_r.Origin-JCS.femur_r.knee_r.Origin;
thigh_L = norm(thigh_axis);
shank_axis = JCS.femur_r.knee_r.Origin-JCS.talus_r.ankle_r.Origin';
shank_L = norm(shank_axis);
foot_axis = JCS.talus_r.ankle_r.Origin'-JCS.calcn_r.toes_r.Origin;
foot_L = norm(foot_axis);
%---------------------------------------------

% coefficients from Winter 2015 (book)
thigh_COM = thigh_L*0.567*thigh_axis/thigh_L+JCS.femur_r.knee_r.Origin;
shank_COM = shank_L*0.567*shank_axis/shank_L+JCS.talus_r.ankle_r.Origin';
calcn_COM = foot_L*0.5*foot_axis/foot_L+JCS.calcn_r.toes_r.Origin;
osimModel.getBodySet().get('femur_r').setMassCenter(osimVec3FromArray(thigh_COM/1000));
osimModel.getBodySet().get('tibia_r').setMassCenter(osimVec3FromArray(shank_COM/1000));
osimModel.getBodySet().get('calcn_r').setMassCenter(osimVec3FromArray(calcn_COM/1000));

% map gait2392 properties
osimModel = mapGait2392MassPropToModel(osimModel);

% opensim model total mass (consistent in gait2392 and Rajagopal)
% pelvis + 2*(fem+tibia+talus+foot+toes+patella)+torso    
gait2392_tot_mass = 11.777 + 2*(9.3014+3.7075+0.1+1.25+0.2166+0.0862)+34.2366;

% calculate mass ratio
coeff = subj_mass/gait2392_tot_mass;

% scaleBo
scaleMassProps(osimModel, coeff);

end

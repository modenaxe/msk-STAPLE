% ASSIGNMASSPROPSTOSEGMENTS Assign mass properties to the segments of an
% OpenSim model created automatically. Mass and inertia are scaled from the
% values used in the gait2392 model.
% NOTE: this function will be rewritten (prototype).
% 
%   osimModel = mapGait2392MassPropToModel(osimModel)
%
% Inputs:
%   osimModel - an OpenSim model generated automatically for which the mass
%       properties needs to be personalised.
%
%   JCS - a structure including the joint coordinate system computed from
%       the bone geometries. Required for computing the segment lengths and
%       identifying the COM positions.
%
%   subj_mass - the total mass of the individual of which we are building a
%       model, in Kg. Required for scaling the mass properties of the
%       generic gati2392 model.
% 
% Outputs:
%   osimModel - the OpenSim model with the personalised mass properties.
%
%
% See also MAPGAIT2392MASSPROPTOMODEL, SCALEMASSPROPS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function osimModel = assignMassPropsToSegments(osimModel, JCS, subj_mass)

% MADE A MESS WITH THE DIMENSIONS OF THE JCS.origin....TO FIX!
%---------------------------------------------
% compute lengths of segments from the bones
thigh_axis = JCS.femur_r.hip_r.Origin-JCS.femur_r.knee_r.Origin;
thigh_L = norm(thigh_axis);
shank_axis = JCS.femur_r.knee_r.Origin-JCS.talus_r.ankle_r.Origin';
shank_L = norm(shank_axis);
foot_axis = JCS.talus_r.ankle_r.Origin'-JCS.calcn_r.toes_r.Origin;
foot_L = norm(foot_axis);
%---------------------------------------------

% compute COM positions using coefficients from Winter 2015 (book)
thigh_COM = thigh_L*0.567*thigh_axis/thigh_L+JCS.femur_r.knee_r.Origin;
shank_COM = shank_L*0.567*shank_axis/shank_L+JCS.talus_r.ankle_r.Origin';
calcn_COM = foot_L*0.5*foot_axis/foot_L+JCS.calcn_r.toes_r.Origin;
osimModel.getBodySet().get('femur_r').setMassCenter(osimVec3FromArray(thigh_COM/1000));
osimModel.getBodySet().get('tibia_r').setMassCenter(osimVec3FromArray(shank_COM/1000));
osimModel.getBodySet().get('calcn_r').setMassCenter(osimVec3FromArray(calcn_COM/1000));

% map gait2392 properties to the model segments as an initial value
osimModel = mapGait2392MassPropToModel(osimModel);

% opensim model total mass (consistent in gait2392 and Rajagopal)
% This is: pelvis + 2*(fem+tibia+talus+foot+toes+patella)+torso    
gait2392_tot_mass = 11.777 + 2*(9.3014+3.7075+0.1+1.25+0.2166+0.0862)+34.2366;

% calculate mass ratio of subject mass and gait2392 mass
coeff = subj_mass/gait2392_tot_mass;

% scale gait2392 mass properties to the individual subject
scaleMassProps(osimModel, coeff);

end

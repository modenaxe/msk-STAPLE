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
%   side_raw - generic string identifying a body side. 'right', 'r', 'left'
%       and 'l' are accepted inputs, both lower and upper cases.
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


function osimModel = assignMassPropsToSegments(osimModel, JCS, subj_mass, side_raw)

% opensim libraries
import org.opensim.modeling.*

av_bodies = fields(JCS);

% TODO: rewrite in a more clever way
% setting defaults
if nargin<4
    side = inferBodySideFromAnatomicStruct(JCS);
else
    % get sign correspondent to body side
    [~, side] = bodySide2Sign(side_raw);
end

femur_name = ['femur_', side];
tibia_name = ['tibia_', side];
talus_name = ['talus_', side];
calcn_name = ['calcn_', side];
hip_name   = ['hip_',side];
knee_name  = ['knee_',side];
ankle_name = ['ankle_', side];
toes_name  = ['mtp_',side];

disp('------------------------');
disp('  UPDATING MASS PROPS   ')
disp('------------------------');

% compute lengths of segments from the bones and COM positions using 
% coefficients from Winter 2015 (book)
% badly written!

% Keep in mind that all Origin fields have [3x1] dimensions
disp('Updating centre of mass position (Winter 2015)...')
if isfield(JCS, femur_name)
    % compute thigh length
    thigh_axis = JCS.(femur_name).(hip_name).Origin-JCS.(femur_name).(knee_name).Origin;
    thigh_L = norm(thigh_axis);
    thigh_COM = thigh_L*0.567 * (thigh_axis/thigh_L) + JCS.(femur_name).(knee_name).Origin;
    % assign  thigh COM
    osimModel.getBodySet().get(femur_name).setMassCenter(ArrayDouble.createVec3(thigh_COM/1000));
    
    % shank
    if isfield(JCS, talus_name)
        % compute shank length
        shank_axis = JCS.(femur_name).(knee_name).Origin-JCS.(talus_name).(ankle_name).Origin;
        shank_L = norm(shank_axis);
        shank_COM = shank_L*0.567 * (shank_axis/shank_L) + JCS.(talus_name).(ankle_name).Origin;
        % assign shank COM
        osimModel.getBodySet().get(tibia_name).setMassCenter(ArrayDouble.createVec3(shank_COM/1000));
        
        % foot
        if isfield(JCS, calcn_name)
            % compute foot length
            foot_axis = JCS.(talus_name).(ankle_name).Origin-JCS.(calcn_name).(toes_name).Origin;
            foot_L = norm(foot_axis);
            calcn_COM = foot_L*0.5*foot_axis/foot_L      + JCS.(calcn_name).(toes_name).Origin;
            % assign foot COM
            osimModel.getBodySet().get(calcn_name).setMassCenter(ArrayDouble.createVec3(calcn_COM/1000));
        end
    end
end
%---------------------------------------------

% map gait2392 properties to the model segments as an initial value
disp('Mapping segment masses and inertias from gait2392 model.')
osimModel = mapGait2392MassPropToModel(osimModel);

% opensim model total mass (consistent in gait2392 and Rajagopal)
MP = gait2392MassProps('full_body');
gait2392_tot_mass = MP.mass;

% calculate mass ratio of subject mass and gait2392 mass
coeff = subj_mass/gait2392_tot_mass;

% scale gait2392 mass properties to the individual subject
disp('Scaling inertial properties to assigned body weight...')
scaleMassProps(osimModel, coeff);

disp('Done.')
end

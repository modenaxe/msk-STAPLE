% GAIT2392MASSPROPS Return the mass and inertia of the body segments of
% model gait2392, which for the lower limb are the same as Rajagopal's
% model. The script saves from reading the OpenSim model directly. Note
% that side does not need to be specified as mass properties are the same
% on both.
% 
%   MassProps = gait2392MassProps(segment_name)
%
% Inputs:
%   segment_name - a string with the name of an OpenSim body included in
%       the gait2392 model. i.e. 'pelvis', 'femur', 'tibia', 'talus',
%       'calcn', 'toes', 'patella' and 'torso'.
%
% Outputs:
%   MP - a structure with fields 'mass', 'mass_center', 'inertia_xx',
%       'inertia_yy', 'inertia_zz'.
%
% See also MAPGAIT2392MASSPROPTOMODEL.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function MP = gait2392MassProps(segment_name)
% Note that the Rajagopal model has the same lower limb inertial
% properties, which is why I added the patella from that model.
% torso differs because that model has arms.

if ~(strcmp(segment_name, 'pelvis') || strcmp(segment_name, 'torso') || strcmp(segment_name, 'full_body'))
    % get rid of side
    segment_name = segment_name(1:end-2);
end
    
switch segment_name
    case 'full_body'
        % This is: pelvis + 2*(fem+tibia+talus+foot+toes+patella)+torso 
        MP.mass = 11.777 + 2*(9.3014+3.7075+0.1+1.25+0.2166+0.0862)+34.2366;
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
    case 'torso'% different from Rajagopal that has arms
        MP.mass=34.2366;
        MP.mass_center= [-0.03 0.32 0];
        MP.inertia_xx=1.4745;
        MP.inertia_yy=0.7555;
        MP.inertia_zz=1.4314;
    case 'patella' 
        MP.mass=0.0862;
        MP.mass_center= [0.0018 0.0264 0];
        MP.inertia_xx=2.87e-006;
        MP.inertia_yy=1.311e-005;
        MP.inertia_zz=1.311e-005;
    otherwise
        error('Please specify a segment name among those included in the gait2392 model');
end

end
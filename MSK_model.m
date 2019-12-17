%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  % 
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% trying to create a knee joint
% TODO: scale geometries
% TODO: transform them to ascii for OpenSim visualization

clearvars; close all
% add useful scripts
addpath(genpath('GIBOK-toolbox'));
addpath('autoMSK_functions');

%--------------------------------
% SETTINGS
%--------------------------------
addpath(genpath('GIBOK-toolbox'));
bone_geom_folder = './test_geometries';
ACs_folder = './ACs';
test_case = 'LHDL';
osim_folder = './opensim_models';
%--------------------------------

% OpenSim libraries
import org.opensim.modeling.*

% create the model
osimModel = Model();

% setting the model
osimModel.setName([test_case,'_auto']);

% set gravity
osimModel.setGravity(Vec3(0, -9.8081, 0));

% vector of zeros for convenience
zeroVec3 = ArrayDouble.createVec3(0);

% bodies
ground = osimModel.getGroundBody();

% TODO need to personalize masses from volumes or regress eq 
% TODO model needs to link to geometries for display
% TODO model needs to have appropriate rotation sequence
% TODO add ankle complex
% TODO add patello-femoral
pelvis = Body(); pelvis.setName('pelvis'); pelvis.setMass(10); pelvis.setMassCenter(zeroVec3); pelvis.addDisplayGeometry(fullfile(bone_geom_folder, 'pelvis_remeshed_10_m.stl' ))
femur_r = Body(); femur_r.setName('femur_r'); femur_r.setMass(10);femur_r.setMassCenter(zeroVec3);femur_r.addDisplayGeometry(fullfile(bone_geom_folder, 'femur_r_LHDL_remeshed8_m.stl' ))
tibia_r = Body(); tibia_r.setName('tibia_r'); tibia_r.setMass(10); tibia_r.setMassCenter(zeroVec3); tibia_r.addDisplayGeometry(fullfile(bone_geom_folder, 'tibia_r_LHDL_remeshed8_m.stl' ))

% building bodyset
MSK_BodySet = BodySet();
MSK_BodySet.cloneAndAppend(ground);
MSK_BodySet.cloneAndAppend(pelvis);
MSK_BodySet.cloneAndAppend(femur_r);
MSK_BodySet.cloneAndAppend(tibia_r);

% joint parameters
% load('LHDL_ACSsResults.mat'); 
load(fullfile(ACs_folder, [test_case,'_ACSsResults.mat'])); 

% ground_pelvis
load(fullfile(ACs_folder,'PelvisRS'));
% [XPelvAngle, YPelvAngle, ZPelvAngle] = FIXED_ROT_XYZ(PelvisRS.V , 'Glob2Loc');
% pelvis_orientation = [ZPelvAngle, YPelvAngle, XPelvAngle];
pelvis_location = PelvisRS.Origin/1000;

%XYZ fixed frame: https://en.wikipedia.org/wiki/Euler_angles
R1 = PelvisRS.V;
beta = asin( R1(1,3));
alpha = asin(-R1(2,3)/ cos(beta) );
gamma = acos(R1(1,1)/ cos(beta) );
disp([alpha beta gamma])
 %this goes in the osim file as <xyz_body_rotation>
pelvis_orientation = [  alpha  beta  gamma]; 

Rot  =R1
beta2  = atan2(Rot(1,3),                   sqrt(Rot(1,1)^2.0+Rot(1,2)^2.0));
alpha2 = atan2(-Rot(2,3)/cos(beta),        Rot(3,3)/cos(beta));
gamma2 = atan2(-Rot(1, 2)/cos(beta),       Rot(1,1)/cos(beta));
disp([alpha2 beta2 gamma2])
pelvis_orientation = [  alpha2  beta2  gamma2];

nj = 1;
JointParams(nj).name                = 'ground_pelvis';
JointParams(nj).parent              = 'ground';
JointParams(nj).child               = 'pelvis';
JointParams(nj).parent_location     = [0.0000	0.0000	0.0000];
JointParams(nj).parent_orientation  = [0.0000	0.0000	0.0000];
JointParams(nj).child_location      = pelvis_location;
JointParams(nj).child_orientation   = pelvis_orientation;
JointParams(nj).coordsNames         = {'pelvis_tilt','pelvis_list','pelvis_rotation', 'pelvis_tx','pelvis_ty', 'pelvis_tz'};
JointParams(nj).coordsTypes         = {'rotational', 'rotational', 'rotational', 'translational', 'translational','translational'};
JointParams(nj).rotationAxes        = 'zxy'; 

% hip parameters
% transforming to ISB ref system
ISB2GB = [1  0  0
          0  0 -1
          0  1 0];
GB2Glob = FemACSsResults.PCC.V;
FX = GB2Glob*ISB2GB*[1 0 0]';
FY = GB2Glob*ISB2GB*[0 1 0]';
FZ = GB2Glob*ISB2GB*[0 0 1]';
F.V = [FX, FY, FZ];

% %XYZ fixed frame
% R2 = F.V;%(FemACSsResults.PCC.V*ISB2GB)';
%   beta = asin( R2(1,3));
%  alpha = acos(R2(1,1)/ cos(beta) );
%  gamma = asin(-R2(2,3)/ cos(beta) );
%  %this goes in the osim file as <xyz_body_rotation>
% femur_orientation = [  gamma  beta alpha ]; 

Rot  = F.V;
beta2  = atan2(Rot(1,3),                   sqrt(Rot(1,1)^2.0+Rot(1,2)^2.0));
alpha2 = atan2(-Rot(2,3)/cos(beta),        Rot(3,3)/cos(beta));
gamma2 = atan2(-Rot(1, 2)/cos(beta),       Rot(1,1)/cos(beta));
disp([alpha2 beta2 gamma2])
femur_orientation = [  alpha2  beta2  gamma2];

% [XFemAngle, YFemAngle, ZFemAngle] = FIXED_ROT_XYZ(R2, 'Glob2Loc');
% femur_orientation = [ZFemAngle, YFemAngle, XFemAngle];


HJC_location = FemACSsResults.CenterFH/1000;

% hip joint
nj = nj + 1;
JointParams(nj).name                = 'hip_r';
JointParams(nj).parent              = 'pelvis';
JointParams(nj).child               = 'femur_r';
JointParams(nj).parent_location     = HJC_location;
JointParams(nj).parent_orientation  = pelvis_orientation;
JointParams(nj).child_location      = HJC_location;
JointParams(nj).child_orientation   = femur_orientation;
JointParams(nj).coordsNames         = {'hip_flexion_r','hip_adduction_r','hip_rotation_r'};
JointParams(nj).coordsTypes         = {'rotational', 'rotational', 'rotational'};
JointParams(nj).rotationAxes        = 'zxy'; 

% knee parameters
knee_location_in_parent = FemACSsResults.PCC.Origin/1000;
knee_child_location = (FemACSsResults.PCC.Origin-TibACSsResults.PIAASL.Origin)/1000;
rotation_axes = 'zxy';
% transforming to ISB ref system
ISB2GB = [1  0  0
          0  0 -1
          0  1 0];
GB2Glob = TibACSsResults.PIAASL.V;
FX = GB2Glob*ISB2GB*[1 0 0]';
FY = GB2Glob*ISB2GB*[0 1 0]';
FZ = GB2Glob*ISB2GB*[0 0 1]';
F.V = [FX, FY, FZ];
Rot  = F.V;
beta2  = atan2(Rot(1,3),                   sqrt(Rot(1,1)^2.0+Rot(1,2)^2.0));
alpha2 = atan2(-Rot(2,3)/cos(beta),        Rot(3,3)/cos(beta));
gamma2 = atan2(-Rot(1, 2)/cos(beta),       Rot(1,1)/cos(beta));
disp([alpha2 beta2 gamma2])
tibia_orientation = [  alpha2  beta2  gamma2];

% knee
nj = nj + 1;
JointParams(nj).name               = 'knee_r';
JointParams(nj).parent             = 'femur_r';
JointParams(nj).child              = 'tibia_r';
JointParams(nj).parent_location    = knee_location_in_parent;
JointParams(nj).parent_orientation = femur_orientation;
JointParams(nj).child_location     = knee_location_in_parent;
JointParams(nj).child_orientation  = tibia_orientation;
JointParams(nj).coordsNames        = {'knee_angle_r'};
JointParams(nj).coordsTypes        = {'rotational'};
JointParams(nj).rotationAxes       = rotation_axes;
% JointParams(nj).rotationAxes       = [0.0488	-0.0463	-0.9977];

updJointSet = createJointSet(JointParams, MSK_BodySet);

% BodySet
BodySet_to_upd = osimModel.updBodySet;
BodySet_to_upd.assign(MSK_BodySet);
% JointSet
JointSet_to_upd = osimModel.updJointSet;
JointSet_to_upd.assign(updJointSet);

osimModel.disownAllComponents();
if ~isdir(osim_folder); mkdir(osim_folder); end
osimModel.print(fullfile(osim_folder, [test_case, '.osim']));

% remove paths
rmpath(genpath('GIBOK-toolbox'));
rmpath('autoMSK_functions');
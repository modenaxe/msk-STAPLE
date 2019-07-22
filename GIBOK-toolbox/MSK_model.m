% trying to create a knee joint
% TODO: scale geometries
% TODO: transform them to ascii
clearvars; close all

addpath(genpath(strcat(pwd,'/SubFunctions')));
addpath('autobuildfunc');
bone_geom_folder = '../test_geom_full';

% OpenSim libraries
import org.opensim.modeling.*

% create the model
osimModel = Model();

% setting the model
osimModel.setName('LHDL_auto');
osimModel.setGravity(Vec3(0, -9.8081, 0));

zeroVec3 = ArrayDouble.createVec3(0);

% bodies
ground = osimModel.getGroundBody();
pelvis = Body(); pelvis.setName('pelvis'); pelvis.setMass(10); pelvis.setMassCenter(zeroVec3); pelvis.addDisplayGeometry(fullfile(bone_geom_folder, 'pelvis_remeshed_10_m.stl' ))
femur_r = Body(); femur_r.setName('femur_r'); femur_r.setMass(10);femur_r.setMassCenter(zeroVec3);femur_r.addDisplayGeometry(fullfile(bone_geom_folder, 'femur_r_LHDL_remeshed8_m.stl' ))
tibia_r = Body(); tibia_r.setName('tibia_r'); tibia_r.setMass(10); tibia_r.setMassCenter(zeroVec3); tibia_r.addDisplayGeometry(fullfile(bone_geom_folder, 'tibia_r_LHDL_remeshed8_m.stl' ))

MSK_BodySet = BodySet();
MSK_BodySet.cloneAndAppend(ground);
MSK_BodySet.cloneAndAppend(pelvis);
MSK_BodySet.cloneAndAppend(femur_r);
MSK_BodySet.cloneAndAppend(tibia_r);

% joint parameters
load('LHDL_ACSsResults.mat'); 

% ground_pelvis
load('PelvisRS')
[ZPelvAngle, YPelvAngle, XPelvAngle] = FIXED_ROT_ZXY(PelvisRS.V , 'Glob2Loc');
pelvis_orientation = [ZPelvAngle, YPelvAngle, XPelvAngle];
pelvis_location = PelvisRS.Origin/1000;

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
[ZFemAngle, YFemAngle, XFemAngle] = FIXED_ROT_ZXY(FemACSsResults.PCC.V , 'Glob2Loc');
femur_orientation = [ZFemAngle, YFemAngle, XFemAngle];
HJC_location = FemACSsResults.CenterFH/1000;

% hip joint
nj = nj + 1;
JointParams(nj).name                = 'hip_r';
JointParams(nj).parent              = 'pelvis';
JointParams(nj).child               = 'femur_r';
JointParams(nj).parent_location     = HJC_location;
JointParams(nj).parent_orientation  = [0.0000	0.0000	0.0000];
JointParams(nj).child_location      = HJC_location;
JointParams(nj).child_orientation   = femur_orientation;
JointParams(nj).coordsNames         = {'hip_flexion_r','hip_adduction_r','hip_rotation_r'};
JointParams(nj).coordsTypes         = {'rotational', 'rotational', 'rotational'};
JointParams(nj).rotationAxes        = 'zxy'; 

% knee parameters
knee_location_in_parent = FemACSsResults.PCC.Origin/1000;
knee_child_location = (FemACSsResults.PCC.Origin-TibACSsResults.PIAASL.Origin)/1000;
rotation_axes = 'zxy';

% knee
nj = nj + 1;
JointParams(nj).name               = 'knee_r';
JointParams(nj).parent             = 'femur_r';
JointParams(nj).child              = 'tibia_r';
JointParams(nj).parent_location    = knee_location_in_parent;
JointParams(nj).parent_orientation = [0.0000	0.0000	0.0000];
JointParams(nj).child_location     = knee_location_in_parent;
JointParams(nj).child_orientation  = [0.0000	0.0000	0.0000];
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
osimModel.print('test.osim');

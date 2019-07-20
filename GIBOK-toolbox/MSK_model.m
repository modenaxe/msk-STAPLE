% trying to create a knee joint
% TODO: scale geometries
% TODO: transform them to ascii
clearvars 
close all

% OpenSim libraries
import org.opensim.modeling.*

addpath(genpath(strcat(pwd,'/SubFunctions')));
bone_geom_folder = '../test_geom_full';

load('LHDL_ACSsResults.mat'); 

[ZFemAngle, YFemAngle, XFemAngle] = FIXED_ROT_ZXY(FemACSsResults.PCC.V , 'Glob2Loc');
fem_ref_syst = ArrayDouble.createVec3([ZFemAngle, YFemAngle, XFemAngle]);

zeroVec3 = ArrayDouble.createVec3(0);
% create model
osimModel = Model();
osimModel.setName('auto_knee')
osimModel.setGravity(zeroVec3);

% ground
ground = osimModel.getGroundBody();

% pelvis
pelvis = Body();
pelvis.setName('pelvis');
pelvis.setMass(10); % placehjolder for now
pelvis.setMassCenter(zeroVec3);
% add femur geometry in mm
pelvis.addDisplayGeometry(fullfile(bone_geom_folder, 'pelvis_remeshed_10_m.stl' ))
% location in parent should be the same as the femoral reference system 
orientation_in_parent = zeroVec3;
HJC_location = ArrayDouble.createVec3(FemACSsResults.CenterFH/1000);
orientation_in_femur = zeroVec3;
FreeJoint('ground_pelvis', ground, orientation_in_parent, zeroVec3, pelvis, HJC_location, orientation_in_femur );
osimModel.addBody(pelvis);

% femur
femur = Body();
femur.setName('femur_r');
femur.setMass(10); % placehjolder for now
femur.setMassCenter(zeroVec3);
% add femur geometry in mm
femur.addDisplayGeometry(fullfile(bone_geom_folder, 'femur_r_LHDL_remeshed8_m.stl' ))
% location in parent should be the same as the femoral reference system 
orientation_in_parent = zeroVec3;
HJC_location = ArrayDouble.createVec3(FemACSsResults.CenterFH/1000);
orientation_in_femur = zeroVec3;
FreeJoint('hip_r', ground, orientation_in_parent, zeroVec3, femur, HJC_location, orientation_in_femur );
osimModel.addBody(femur);
% tibia
tibia = Body();
tibia.setName('tibia_r');
tibia.setMass(10); % placehjolder for now
tibia.setMassCenter(zeroVec3);
tibia.addDisplayGeometry(fullfile(bone_geom_folder, 'tibia_r_LHDL_remeshed8_m.stl' ))
% tibia.addDisplayGeometry(fullfile(bone_geom_folder, 'ProxTib_S1_05_m.stl' ))

location_in_parent = ArrayDouble.createVec3(FemACSsResults.PCC.Origin/1000);
location_knee = ArrayDouble.createVec3((FemACSsResults.PCC.Origin-TibACSsResults.PIAASL.Origin)/1000);
knee_r = BallJoint('knee_r', femur, location_in_parent, zeroVec3, tibia, location_in_parent, zeroVec3 );
osimModel.addBody(tibia);
osimModel.disownAllComponents();
osimModel.print('test.osim');

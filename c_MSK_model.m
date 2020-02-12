%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  % 
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% trying to create a knee joint
% TODO: scale geometries
% TODO: transform them to ascii for OpenSim visualization

clearvars; clear all
close all
% add useful scripts
addpath(genpath('GIBOK-toolbox'));
addpath(genpath('autoMSK_functions'));

% OpenSim libraries
import org.opensim.modeling.*

%--------------------------------
% SETTINGS
%--------------------------------
bone_geom_folder = './test_geometries';
ACs_folder = './ACs';
test_case = 'LHDL';
osim_folder = './opensim_models';
bone_density = 0.000001420;%kg/mm3
in_mm = 1;
%--------------------------------
% TODO need to personalize masses from volumes or regress eq 
% e.g. [mass, CoM, Inertias] = Anthropometry(H, M, 'method')

% bone geometries
pelvis_mat_mesh = './test_geometries/P0_MRI_smooth_tri/pelvis_no_sacrum.mat';
% pelvis_mesh = './test_geometries/P0_MRI_smooth/pelvis_no_sacrum.stl';
pelvis_mesh_vtp = 'F:\MATLAB\auto-msk-model-git\test_geometries\P0_MRI_smooth_vtp\pelvis_no_sacrum.vtp';


% check folder existance
if ~isdir(osim_folder); mkdir(osim_folder); end
% create the model
osimModel = Model();
% setting the model
osimModel.setName([test_case,'_auto']);
% set gravity
osimModel.setGravity(Vec3(0, -9.8081, 0));
% vector of zeros for convenience
zeroVec3 = ArrayDouble.createVec3(0);
% ground
ground = osimModel.getGround();


%============== just the mesh is given in input =========================
% load mesh
geom = load(pelvis_mat_mesh); 
geom = geom.triang_geom;
% compute mass properties
PelvisInfo = calcMassInfo_Mirtich1996(geom.Points, geom.ConnectivityList, bone_density);
% create opensim body
pelvis = Body(); 
pelvis.setName('pelvis'); 
pelvis.setMass(PelvisInfo.mass); 
pelvis.setMassCenter(ArrayDouble.createVec3(PelvisInfo.COM/1000)); 
exp_inertia = Inertia(PelvisInfo.Ivec(1), PelvisInfo.Ivec(2), PelvisInfo.Ivec(3),...
                      PelvisInfo.Ivec(4), PelvisInfo.Ivec(5), PelvisInfo.Ivec(6));
pelvis.setInertia(exp_inertia);
% add body
osimModel.addBody(pelvis);
pelvis.attachGeometry(Mesh(pelvis_mesh_vtp));
%========================================================================

% solve reference system
PelvisRS = PelvisFun(geom);

% compute angles
Rot = PelvisRS.ISB.V;
% pelvis_location = ArrayDouble.createVec3(PelvisRS.ISB.Origin/1000);
pelvis_location = PelvisRS.ISB.Origin/1000;
beta2  = atan2(Rot(1,3),                   sqrt(Rot(1,1)^2.0+Rot(1,2)^2.0));
alpha2 = atan2(-Rot(2,3)/cos(beta2),        Rot(3,3)/cos(beta2));
gamma2 = atan2(-Rot(1, 2)/cos(beta2),       Rot(1,1)/cos(beta2));
disp([alpha2 beta2 gamma2])
% pelvis_orientation = ArrayDouble.createVec3([  alpha2  beta2  gamma2]);
pelvis_orientation = [  alpha2  beta2  gamma2];

% % this is basically what addOffsetToFrame does already
% pelvis_ofs = PhysicalOffsetFrame();
% pelvis_ofs.setName('pelvis_ISB');
% pelvis_ofs.setParentFrame(pelvis);
% pelvis_ofs.set_translation(pelvis_location);
% pelvis_ofs.set_orientation(pelvis_orientation);

% [osimModel, offset_ground] = addOffsetToFrame(osimModel, ground, 'ground_offset', zeroVec3, zeroVec3);
% [osimModel, offset_pelvis] = addOffsetToFrame(osimModel, pelvis, 'pelvis_offset', pelvis_location, pelvis_orientation);

% % Add the frames and Geometry (used in addOffsetToFrame
% osimModel.addComponent(offset_ground);
% osimModel.addComponent(offset_pelvis);

% % option 1: the safe one. Works
% joint = FreeJoint('pelvis_ground', ...
%                    ground, zeroVec3, zeroVec3, ...
%                    pelvis, zeroVec3, zeroVec3);
% osimModel.addJoint(joint);
% % option 2: NOT WORKING BECAYSE OF GROUND
% [model, joint] = connectBodyWithJoint(osimModel, ground, offset_pelvis, 'pelvis_ground', 'FreeJoint');
% osimModel.addJoint(joint);
% % % option 3: not working
% [model, joint] = connectBodyWithJoint(osimModel, offset_ground, offset_pelvis, 'pelvis_ground', 'FreeJoint');
% osimModel.addJoint(joint);
% % option 4: working (although geometry appears far away
% joint = FreeJoint('pelvis_ground',offset_ground, offset_pelvis );
% osimModel.addJoint(joint);

% % Set bounds on the 6 coordinates of the Free Joint.
% angleRange 	  = [-pi/2, pi/2];
% positionRange = [-1, 1];
% for i=0:2, joint.upd_coordinates(i).setRange(angleRange); end
% for i=3:5, joint.upd_coordinates(i).setRange(positionRange); end


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

% create the joint
pelvis_ground_joint = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(pelvis_ground_joint);

osimModel.finalizeConnections()
osimModel.print('2_pelvis_model.osim');

% % joint parameters
% % load('LHDL_ACSsResults.mat'); 
% load(fullfile(ACs_folder, [test_case,'_ACSsResults.mat'])); 

% FROM HERE DOWN IT USED TO WORK IN OPENSIM 3.3
% % ground_pelvis
% load(fullfile(ACs_folder,'PelvisRS'));
% % [XPelvAngle, YPelvAngle, ZPelvAngle] = FIXED_ROT_XYZ(PelvisRS.V , 'Glob2Loc');
% % pelvis_orientation = [ZPelvAngle, YPelvAngle, XPelvAngle];
% pelvis_location = PelvisRS.Origin/1000;
% 
% %XYZ fixed frame: https://en.wikipedia.org/wiki/Euler_angles
% R1 = PelvisRS.V;
% beta = asin( R1(1,3));
% alpha = asin(-R1(2,3)/ cos(beta) );
% gamma = acos(R1(1,1)/ cos(beta) );
% disp([alpha beta gamma])
%  %this goes in the osim file as <xyz_body_rotation>
% pelvis_orientation = [  alpha  beta  gamma]; 
% 
% Rot  =R1
% beta2  = atan2(Rot(1,3),                   sqrt(Rot(1,1)^2.0+Rot(1,2)^2.0));
% alpha2 = atan2(-Rot(2,3)/cos(beta),        Rot(3,3)/cos(beta));
% gamma2 = atan2(-Rot(1, 2)/cos(beta),       Rot(1,1)/cos(beta));
% disp([alpha2 beta2 gamma2])
% pelvis_orientation = [  alpha2  beta2  gamma2];
% 
% nj = 1;
% JointParams(nj).name                = 'ground_pelvis';
% JointParams(nj).parent              = 'ground';
% JointParams(nj).child               = 'pelvis';
% JointParams(nj).parent_location     = [0.0000	0.0000	0.0000];
% JointParams(nj).parent_orientation  = [0.0000	0.0000	0.0000];
% JointParams(nj).child_location      = pelvis_location;
% JointParams(nj).child_orientation   = pelvis_orientation;
% JointParams(nj).coordsNames         = {'pelvis_tilt','pelvis_list','pelvis_rotation', 'pelvis_tx','pelvis_ty', 'pelvis_tz'};
% JointParams(nj).coordsTypes         = {'rotational', 'rotational', 'rotational', 'translational', 'translational','translational'};
% JointParams(nj).rotationAxes        = 'zxy'; 
% 
% 
% updJointSet = createJointSet(JointParams, osimModel.getBodySet)
% 
% % hip parameters
% % transforming to ISB ref system
% ISB2GB = [1  0  0
%           0  0 -1
%           0  1 0];
% GB2Glob = FemACSsResults.PCC.V;
% FX = GB2Glob*ISB2GB*[1 0 0]';
% FY = GB2Glob*ISB2GB*[0 1 0]';
% FZ = GB2Glob*ISB2GB*[0 0 1]';
% F.V = [FX, FY, FZ];
% 
% % %XYZ fixed frame
% % R2 = F.V;%(FemACSsResults.PCC.V*ISB2GB)';
% %   beta = asin( R2(1,3));
% %  alpha = acos(R2(1,1)/ cos(beta) );
% %  gamma = asin(-R2(2,3)/ cos(beta) );
% %  %this goes in the osim file as <xyz_body_rotation>
% % femur_orientation = [  gamma  beta alpha ]; 
% 
% Rot  = F.V;
% beta2  = atan2(Rot(1,3),                   sqrt(Rot(1,1)^2.0+Rot(1,2)^2.0));
% alpha2 = atan2(-Rot(2,3)/cos(beta),        Rot(3,3)/cos(beta));
% gamma2 = atan2(-Rot(1, 2)/cos(beta),       Rot(1,1)/cos(beta));
% disp([alpha2 beta2 gamma2])
% femur_orientation = [  alpha2  beta2  gamma2];
% 
% % [XFemAngle, YFemAngle, ZFemAngle] = FIXED_ROT_XYZ(R2, 'Glob2Loc');
% % femur_orientation = [ZFemAngle, YFemAngle, XFemAngle];
% 
% 
% HJC_location = FemACSsResults.CenterFH/1000;
% 
% % hip joint
% nj = nj + 1;
% JointParams(nj).name                = 'hip_r';
% JointParams(nj).parent              = 'pelvis';
% JointParams(nj).child               = 'femur_r';
% JointParams(nj).parent_location     = HJC_location;
% JointParams(nj).parent_orientation  = pelvis_orientation;
% JointParams(nj).child_location      = HJC_location;
% JointParams(nj).child_orientation   = femur_orientation;
% JointParams(nj).coordsNames         = {'hip_flexion_r','hip_adduction_r','hip_rotation_r'};
% JointParams(nj).coordsTypes         = {'rotational', 'rotational', 'rotational'};
% JointParams(nj).rotationAxes        = 'zxy'; 
% 
% 
% 
% % % knee parameters
% % knee_location_in_parent = FemACSsResults.PCC.Origin/1000;
% % knee_child_location = (FemACSsResults.PCC.Origin-TibACSsResults.PIAASL.Origin)/1000;
% % rotation_axes = 'zxy';
% % % transforming to ISB ref system
% % ISB2GB = [1  0  0
% %           0  0 -1
% %           0  1 0];
% % GB2Glob = TibACSsResults.PIAASL.V;
% % FX = GB2Glob*ISB2GB*[1 0 0]';
% % FY = GB2Glob*ISB2GB*[0 1 0]';
% % FZ = GB2Glob*ISB2GB*[0 0 1]';
% % F.V = [FX, FY, FZ];
% % Rot  = F.V;
% % beta2  = atan2(Rot(1,3),                   sqrt(Rot(1,1)^2.0+Rot(1,2)^2.0));
% % alpha2 = atan2(-Rot(2,3)/cos(beta),        Rot(3,3)/cos(beta));
% % gamma2 = atan2(-Rot(1, 2)/cos(beta),       Rot(1,1)/cos(beta));
% % disp([alpha2 beta2 gamma2])
% % tibia_orientation = [  alpha2  beta2  gamma2];
% % 
% % % knee
% % nj = nj + 1;
% % JointParams(nj).name               = 'knee_r';
% % JointParams(nj).parent             = 'femur_r';
% % JointParams(nj).child              = 'tibia_r';
% % JointParams(nj).parent_location    = knee_location_in_parent;
% % JointParams(nj).parent_orientation = femur_orientation;
% % JointParams(nj).child_location     = knee_location_in_parent;
% % JointParams(nj).child_orientation  = tibia_orientation;
% % JointParams(nj).coordsNames        = {'knee_angle_r'};
% % JointParams(nj).coordsTypes        = {'rotational'};
% % JointParams(nj).rotationAxes       = rotation_axes;
% % % JointParams(nj).rotationAxes       = [0.0488	-0.0463	-0.9977];
% % 
% % updJointSet = createJointSet(JointParams, MSK_BodySet);
% % 
% % % BodySet
% % BodySet_to_upd = osimModel.updBodySet;
% % BodySet_to_upd.assign(MSK_BodySet);
% % BodySet_to_upd.print('check_bodyset_v4.xml')
% % osimModel.print('check1_model_v4.xml')
% % % MISSING GROUND
% % 
% % % JointSet
% % JointSet_to_upd = osimModel.updJointSet;
% % JointSet_to_upd.assign(updJointSet);
% % 
% % osimModel.disownAllComponents();
% % 
% % if ~isdir(osim_folder); mkdir(osim_folder); end
% % osimModel.print(fullfile(osim_folder, [test_case, '.osim']));
% 
% % remove paths
% rmpath(genpath('GIBOK-toolbox'));
% rmpath('autoMSK_functions');
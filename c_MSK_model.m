%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  % 
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
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
in_mm = 1;
%--------------------------------
% TODO need to personalize masses from volumes or regress eq 
% e.g. [mass, CoM, Inertias] = Anthropometry(H, M, 'method')

% bone geometries
pelvis_mat_mesh = './test_geometries/P0_MRI_smooth_tri/pelvis_no_sacrum.mat';
femur_r_mat_mesh = './test_geometries/P0_MRI_smooth_tri/femur_r.mat';
tibia_r_mat_mesh = './test_geometries/P0_MRI_smooth_tri/tibia_r.mat';
talus_r_mat_mesh = './test_geometries/P0_MRI_smooth_tri/talus_r.mat';
% pelvis_mesh = './test_geometries/P0_MRI_smooth/pelvis_no_sacrum.stl';
pelvis_mesh_vtp = 'test_geometries\P0_MRI_smooth_vtp\pelvis.vtp';
femur_r_mesh_vtp = 'test_geometries\P0_MRI_smooth_vtp\femur_r.vtp';
tibia_r_mesh_vtp = 'test_geometries/P0_MRI_smooth_vtp/tibia_r.vtp';
talus_r_mesh_vtp = 'test_geometries/P0_MRI_smooth_vtp/talus_r.vtp';


% adjust dimensional factors based on mm / m scales
if in_mm == 1
    dim_fact = 0.001;
    bone_density = 0.000001420;%kg/mm3
else
    % assumed in metres
    dim_fact = 1;
    bone_density = 1420;%kg/m3
end

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
boneMassProps = calcMassInfo_Mirtich1996(geom.Points, geom.ConnectivityList);
% create opensim body
pelvis = Body(); 
pelvis.setName('pelvis'); 
pelvis.setMass(boneMassProps.mass*bone_density); 
pelvis.setMassCenter(ArrayDouble.createVec3(boneMassProps.COM/1000)); 
exp_inertia = Inertia(boneMassProps.Ivec(1), boneMassProps.Ivec(2), boneMassProps.Ivec(3),...
                      boneMassProps.Ivec(4), boneMassProps.Ivec(5), boneMassProps.Ivec(6));
pelvis.setInertia(exp_inertia);
% add body
osimModel.addBody(pelvis);
vis_geom = Mesh(pelvis_mesh_vtp);
vis_geom.set_scale_factors(Vec3(0.001));
pelvis.attachGeometry(vis_geom);
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
disp([alpha2 beta2 gamma2]);
% pelvis_orientation = ArrayDouble.createVec3([  alpha2  beta2  gamma2]);
pelvis_orientation = [  alpha2  beta2  gamma2];

% %XYZ fixed frame: https://en.wikipedia.org/wiki/Euler_angles
% R1 = PelvisRS.V;
% beta = asin( R1(1,3));
% alpha = asin(-R1(2,3)/ cos(beta) );
% gamma = acos(R1(1,1)/ cos(beta) );
% disp([alpha beta gamma])
%  %this goes in the osim file as <xyz_body_rotation>
% pelvis_orientation = [  alpha  beta  gamma]; 

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
osimModel.print('2_auto_model.osim');


%============== just the mesh is given in input =========================

%--------------------------
% load mesh
geom = load(femur_r_mat_mesh); 
geom = geom.triang_geom;
bone_name = 'femur_r';
vis_mesh_file = femur_r_mesh_vtp;
%--------------------------

%  function addBodyFromTriangGeom(osimModel, body_name, Tr, density, in_mm)

% compute geometrical mass properties from segmentation
boneMassProps= calcMassInfo_Mirtich1996(geom.Points, geom.ConnectivityList);
bone_mass    = boneMassProps.mass * bone_density;
bone_COP     = boneMassProps.COM  * dim_fact;
bone_inertia = boneMassProps.Ivec * bone_density * dim_fact^2.0; 
% create opensim body
osim_body    =  Body( bone_name,...
                bone_mass,... 
                ArrayDouble.createVec3(bone_COP),...
                Inertia(bone_inertia(1), bone_inertia(2), bone_inertia(3),...
                        bone_inertia(4), bone_inertia(5), bone_inertia(6))...
               );

% add body to model
osimModel.addBody(osim_body);

% add visualization
% I could write the mat file as stl
vis_geom = Mesh(vis_mesh_file);
vis_geom.set_scale_factors(Vec3(dim_fact));
osim_body.attachGeometry(vis_geom);
%========================================================================

% solve reference system
CS = computeFemurISBCoordSyst_Kai2014(geom);

% debug plots
quickPlotTriang(geom)
quickPlotRefSystem(CS)


HJC_location = CS.CenterFH_Kai/1000;

Rot  = CS.V;
beta2  = atan2(Rot(1,3),                   sqrt(Rot(1,1)^2.0+Rot(1,2)^2.0));
alpha2 = atan2(-Rot(2,3)/cos(beta2),        Rot(3,3)/cos(beta2));
gamma2 = atan2(-Rot(1, 2)/cos(beta2),       Rot(1,1)/cos(beta2));
disp([alpha2 beta2 gamma2])
femur_orientation = [  alpha2  beta2  gamma2];

% % hip joint
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


% create the joint
hip_r = createCustomJointFromStruct(osimModel, JointParams(nj));
osimModel.addJoint(hip_r);

osimModel.finalizeConnections()
osimModel.print('3_auto_model.osim');


% % knee parameters
%--------------------------
% load mesh
geom = load(tibia_r_mat_mesh); 
geom = geom.triang_geom;
bone_name = 'tibia_r';
vis_mesh_file = tibia_r_mesh_vtp;
%--------------------------

%  function addBodyFromTriangGeom(osimModel, body_name, Tr, density, in_mm)

% compute geometrical mass properties from segmentation
boneMassProps= calcMassInfo_Mirtich1996(geom.Points, geom.ConnectivityList);
bone_mass    = boneMassProps.mass * bone_density;
bone_COP     = boneMassProps.COM  * dim_fact;
bone_inertia = boneMassProps.Ivec * bone_density * dim_fact^2.0; 
% create opensim body
osim_body    =  Body( bone_name,...
                bone_mass,... 
                ArrayDouble.createVec3(bone_COP),...
                Inertia(bone_inertia(1), bone_inertia(2), bone_inertia(3),...
                        bone_inertia(4), bone_inertia(5), bone_inertia(6))...
               );

% add body to model
osimModel.addBody(osim_body);

% add visualization
% I could write the mat file as stl
vis_geom = Mesh(vis_mesh_file);
vis_geom.set_scale_factors(Vec3(dim_fact));
osim_body.attachGeometry(vis_geom);
%========================================================================

% knee centre in femur
knee_location_in_parent = (CS.Center1+CS.Center2)/2.0*dim_fact;

% defines the axis for the tibia
 CS = computeTibiaISBCoordSystKai2014(geom);
 quickPlotRefSystem(CS)
 
% knee_location_in_parent = CS.Origin/1000;
% knee_child_location = (FemACSsResults.PCC.Origin-TibACSsResults.PIAASL.Origin)/1000;
Rot  = CS.V;
beta2  = atan2(Rot(1,3),                   sqrt(Rot(1,1)^2.0+Rot(1,2)^2.0));
alpha2 = atan2(-Rot(2,3)/cos(beta2),        Rot(3,3)/cos(beta2));
gamma2 = atan2(-Rot(1, 2)/cos(beta2),       Rot(1,1)/cos(beta2));
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
JointParams(nj).rotationAxes       = 'zxy';

% create the joint
knee_r = createCustomJointFromStruct(osimModel, JointParams(nj));
osimModel.addJoint(knee_r);

osimModel.finalizeConnections()
osimModel.print('4_auto_model.osim');



%============== just the mesh is given in input =========================
% load mesh
geom = load(talus_r_mat_mesh); 
geom = geom.triang_geom;
% compute mass properties
boneMassProps = calcMassInfo_Mirtich1996(geom.Points, geom.ConnectivityList);
% create opensim body
talus_r = Body(); 
talus_r.setName('talus_r'); 
talus_r.setMass(boneMassProps.mass*bone_density); 
talus_r.setMassCenter(ArrayDouble.createVec3(boneMassProps.COM/1000)); 
exp_inertia = Inertia(boneMassProps.Ivec(1), boneMassProps.Ivec(2), boneMassProps.Ivec(3),...
                      boneMassProps.Ivec(4), boneMassProps.Ivec(5), boneMassProps.Ivec(6));
talus_r.setInertia(exp_inertia);
% add body
osimModel.addBody(talus_r);
vis_geom = Mesh(talus_r_mesh_vtp);
vis_geom.set_scale_factors(Vec3(0.001));
talus_r.attachGeometry(vis_geom);
%========================================================================


CS = computeAnkleISBCoordSyst(geom);
% quickPlotRefSystem(CS)

ankle_location = CS.Origin* dim_fact;

Rot  = CS.V;
beta2  = atan2(Rot(1,3),                   sqrt(Rot(1,1)^2.0+Rot(1,2)^2.0));
alpha2 = atan2(-Rot(2,3)/cos(beta2),        Rot(3,3)/cos(beta2));
gamma2 = atan2(-Rot(1, 2)/cos(beta2),       Rot(1,1)/cos(beta2));
talus_orientation = [  alpha2  beta2  gamma2];


% tibiotalar
nj = nj + 1;
JointParams(nj).name               = 'ankle_r';
JointParams(nj).parent             = 'tibia_r';
JointParams(nj).child              = 'talus_r';
JointParams(nj).parent_location    = ankle_location;
JointParams(nj).parent_orientation = tibia_orientation;
JointParams(nj).child_location     = ankle_location;
JointParams(nj).child_orientation  = talus_orientation;
JointParams(nj).coordsNames        = {'ankle_angle_r'};
JointParams(nj).coordsTypes        = {'rotational'};
JointParams(nj).rotationAxes       = 'zxy';

% create the joint
ankle_r = createCustomJointFromStruct(osimModel, JointParams(nj));
osimModel.addJoint(ankle_r);

osimModel.finalizeConnections()
osimModel.print('5_auto_model.osim');



% % print
% osimModel.print(fullfile(osim_folder, [test_case, '.osim']));
% osimModel.disownAllComponents();

% remove paths
rmpath(genpath('GIBOK-toolbox'));
rmpath('autoMSK_functions');
%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  % 
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% TODO: transform them to ascii for OpenSim visualization

clearvars; 
clear all
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


%TODO:
% % Set bounds on the 6 coordinates of the Free Joint.
% angleRange 	  = [-pi/2, pi/2];
% positionRange = [-1, 1];
% for i=0:2, joint.upd_coordinates(i).setRange(angleRange); end
% for i=3:5, joint.upd_coordinates(i).setRange(positionRange); end

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


% add bodies
% body_list = {'pelvis','femur_r','tibia_r','talus_r'};
% geom_file_list = {};
% vis_file_list = {};
% for nb = 1:length(body_list)
%     cur_body_name = body_list{nb};
%     cur_geom_file = ;
%     cur_vis_file = ;
%     addTriangGeomBody(osimModel, cur_body_name, cur_geom_file, cur_vis_file);
% end

%============== just the mesh is given in input =========================
%--------------------------
% load mesh
geom_file = pelvis_mat_mesh; 
bone_name = 'pelvis';
vis_mesh_file = pelvis_mesh_vtp;
%--------------------------
% load mesh
geom = load_mesh(geom_file);
% create pelvis bone
pelvis = createBodyFromTriGeom(geom, bone_name, bone_density, in_mm);
% add body to model
osimModel.addBody(pelvis);
% attach geom
vis_geom = Mesh(vis_mesh_file);
vis_geom.set_scale_factors(Vec3(dim_fact));
pelvis.attachGeometry(vis_geom);
%========================================================================

% solve reference system from geometry
PelvisRS = PelvisFun(geom);

% compute joint params
pelvis_location = PelvisRS.ISB.Origin/1000;
pelvis_orientation = computeZXYAngleSeq(PelvisRS.ISB.V);

% joint
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
geom_file = femur_r_mat_mesh; 
bone_name = 'femur_r';
vis_mesh_file = femur_r_mesh_vtp;
%--------------------------
% load mesh
geom = load_mesh(geom_file);
% create pelvis bone
osim_body = createBodyFromTriGeom(geom, bone_name, bone_density, in_mm);

% add body to model
osimModel.addBody(osim_body);

% add visualization
% I could write the mat file as stl
vis_geom = Mesh(vis_mesh_file);
vis_geom.set_scale_factors(Vec3(dim_fact));
osim_body.attachGeometry(vis_geom);
%========================================================================

% solve reference system
FemurCS = computeFemurISBCoordSyst_Kai2014(geom);

% debug plots
quickPlotTriang(geom)
quickPlotRefSystem(FemurCS)

HJC_location = FemurCS.CenterFH_Kai/1000;
femur_orientation = computeZXYAngleSeq(FemurCS.V);

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



%--------------------------
% load mesh
geom_file = tibia_r_mat_mesh; 
bone_name = 'tibia_r';
vis_mesh_file = tibia_r_mesh_vtp;
%--------------------------
% load mesh
geom = load_mesh(geom_file);
% create pelvis bone
osim_body = createBodyFromTriGeom(geom, bone_name, bone_density, in_mm);

% add body to model
osimModel.addBody(osim_body);

% add visualization
% I could write the mat file as stl
vis_geom = Mesh(vis_mesh_file);
vis_geom.set_scale_factors(Vec3(dim_fact));
osim_body.attachGeometry(vis_geom);
%========================================================================

% defines the axis for the tibia
CS = computeTibiaISBCoordSystKai2014(geom);
quickPlotRefSystem(CS)
 
% knee joint
% joint centre in femur
knee_location_in_parent = (FemurCS.Center1+FemurCS.Center2)/2.0*dim_fact;
tibia_orientation = computeZXYAngleSeq(CS.V);

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


%--------------------------
% load mesh
geom_file = talus_r_mat_mesh; 
bone_name = 'talus_r';
vis_mesh_file = talus_r_mesh_vtp;
%--------------------------
% load mesh
geom = load_mesh(geom_file);
% create pelvis bone
osim_body = createBodyFromTriGeom(geom, bone_name, bone_density, in_mm);

% add body to model
osimModel.addBody(osim_body);

% add visualization
% I could write the mat file as stl
vis_geom = Mesh(vis_mesh_file);
vis_geom.set_scale_factors(Vec3(dim_fact));
osim_body.attachGeometry(vis_geom);
%========================================================================

CS = computeAnkleISBCoordSyst(geom);

ankle_location = CS.Origin* dim_fact;
talus_orientation = computeZXYAngleSeq(CS.V);

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
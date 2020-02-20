%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clearvars;  close all

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
osim_folder = './opensim_models';
in_mm = 1;
nd = 1;
%--------------------------------

% TODO need to personalize masses from volumes or regress eq
% e.g. [mass, CoM, Inertias] = Anthropometry(H, M, 'method')

%TODO:set bounds on the coordinates of the CustomJoints.

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

% add to osim model all bodies
dataset_set = {'LHDL_CT', 'P0_MRI', 'JIA_CSm6'};
dataset = dataset_set{nd};
tri_dir    = fullfile(bone_geom_folder,dataset,'tri');
visual_dir = fullfile(bone_geom_folder,dataset,'vtp');
body_list = {'tibia_r'};%{'pelvis','femur_r','tibia_r','talus_r', 'calcn_r', 'patella_r'};
triGeom_file_list = {'tibia_r'};%{'pelvis_no_sacrum','femur_r','tibia_r','talus_r', 'calcn_r','patella_r'};
visual_file_list = triGeom_file_list;
type_mesh = '.vtp';

% create the model
osimModel = Model();
% setting the model
osimModel.setName([dataset,'_auto']);
% set gravity
osimModel.setGravity(Vec3(0, -9.8081, 0));

for nb = 1:length(body_list)
    % update variables
    cur_body_name = body_list{nb};
    cur_geom_file = fullfile(tri_dir, triGeom_file_list{nb});
    cur_vis_file = fullfile(visual_dir, [visual_file_list{nb},type_mesh]);    
    % load mesh
    cur_geom = load_mesh(cur_geom_file);
    % create and add the body
    addTriGeomBody(osimModel, cur_body_name, cur_geom, bone_density, in_mm, cur_vis_file);
    geom_set.(cur_body_name) = cur_geom;
end

% %---- PELVIS -----
% % solve reference system from geometry
% [PelvisRS, PelvisBL]  = PelvisFun(geom_set.pelvis);
% addMarkersFromStruct(osimModel, 'pelvis', PelvisBL, in_mm)
% 
% % compute joint params
% pelvis_location = PelvisRS.ISB.Origin*dim_fact;
% pelvis_orientation = computeZXYAngleSeq(PelvisRS.ISB.V);
% 
% % ground_pelvis
% JointParams = getJointParams('ground_pelvis');
% JointParams.parent_location     = [0.0000	0.0000	0.0000];
% JointParams.parent_orientation  = [0.0000	0.0000	0.0000];
% JointParams.child_location      = pelvis_location;
% JointParams.child_orientation   = pelvis_orientation;
% 
% % create the joint
% pelvis_ground_joint = createCustomJointFromStruct(osimModel, JointParams);
% osimModel.addJoint(pelvis_ground_joint);
% 
% %---- FEMUR -----
% FemurCS = computeFemurISBCoordSyst_Kai2014(geom_set.femur_r);
% [ FemurCSs, TrObjects ] = GIBOK_femur(geom_set.femur_r);
% 
% HJC_location = FemurCS.CenterFH_Kai*dim_fact;
% femur_orientation = computeZXYAngleSeq(FemurCS.V);
% 
% % % hip joint
% JointParams = getJointParams('hip_r');
% JointParams.parent_location     = HJC_location;
% JointParams.parent_orientation  = pelvis_orientation;
% JointParams.child_location      = HJC_location;
% JointParams.child_orientation   = femur_orientation;
% 
% % create the joint
% hip_r = createCustomJointFromStruct(osimModel, JointParams);
% osimModel.addJoint(hip_r);

%---- TIBIA -----
% defines the axis for the tibia
% CS = computeTibiaISBCoordSystKai2014(geom_set.tibia_r);

[CSs, TrObjects] = GIBOK_tibia(geom_set.tibia_r)

TTB = autoLandmarkTibia(geom_set.tibia_r, CS, 1);

% knee joint
% joint centre in femur
knee_location_in_parent = (FemurCS.Center1+FemurCS.Center2)/2.0*dim_fact;
tibia_orientation = computeZXYAngleSeq(CS.V);

% knee
JointParams = getJointParams('knee_r');
JointParams.parent_location    = knee_location_in_parent;
JointParams.parent_orientation = femur_orientation;
JointParams.child_location     = knee_location_in_parent;
JointParams.child_orientation  = tibia_orientation;

% create the joint
knee_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(knee_r);

%---- PATELLA -----

[ CSs, TrObjects ] = computePatellaISBCoordSyst_Renault2018(geom_set.patella_r);
% PatellaRS = computePatellaISBCoordSyst_Rainbow2013(geom_set.patella_r);

% patello-femoral joint
patfemjoint_location_in_parent = CSs.VR.Origin*dim_fact;
patfemjoint_location_in_child = CSs.VR.Origin*dim_fact;
patella_orientation = computeZXYAngleSeq(CSs.VR.V);

% joint
JointParams = getJointParams('patellofemoral_r');
JointParams.parent_location     = patfemjoint_location_in_parent;
JointParams.parent_orientation  = femur_orientation;
JointParams.child_location      = patfemjoint_location_in_child;
JointParams.child_orientation   = patella_orientation;

% create the joint
patfem_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(patfem_r);

% add patellofemoral constraint
addPatFemJointCoordCouplerConstraint(osimModel, 'r');

%---- TALUS -----
% not working for JIA
CS = computeAnkleISBCoordSyst(geom_set.talus_r);

JointParams = getJointParams('ankle_r');
ankle_location = CS.Origin* dim_fact;
talus_orientation = computeZXYAngleSeq(CS.V);

% tibiotalar
JointParams.parent_location    = ankle_location;
JointParams.parent_orientation = tibia_orientation;
JointParams.child_location     = ankle_location;
JointParams.child_orientation  = talus_orientation;

% create the joint
ankle_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(ankle_r);

%---- TALUS - SUBTALAR -----
SubCS = computeSubtalarISBCoordSyst(geom_set.talus_r);
subtalar_orientation = computeZXYAngleSeq(SubCS.V);
subtalar_location = SubCS.Origin * dim_fact;
% subtalar
JointParams = getJointParams('subtalar_r');
JointParams.parent_location    = subtalar_location;
JointParams.parent_orientation = subtalar_orientation;
JointParams.child_location     = subtalar_location;
JointParams.child_orientation  = subtalar_orientation;
% create the joint
subtalar_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(subtalar_r);

% finali
osimModel.finalizeConnections()

% print
osimModel.print('5_auto_model.osim');
% osimModel.print(fullfile(osim_folder, [test_case, '.osim']));
% CS = computeCalcnISBCoordSyst(geom);

osimModel.disownAllComponents();

% remove paths
rmpath(genpath('GIBOK-toolbox'));
rmpath('autoMSK_functions');
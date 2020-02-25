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
tic
%--------------------------------
% SETTINGS
%--------------------------------
bone_geom_folder = 'test_geometries';
ACs_folder = './ACs';
osim_folder = './opensim_models';
in_mm = 1;
nd = 3;
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
body_list = {'pelvis','femur_r','tibia_r','talus_r', 'calcn_r', 'patella_r'};
triGeom_file_list = {'pelvis_no_sacrum','femur_r','tibia_r','talus_r', 'calcn_r','patella_r'};
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

% [ PatellaCSs, TrObjects ] = GIBOK_patella(geom_set.patella_r);

% CalcaneusCS = GIBOK_calcn(geom_set.calcn_r);
% quickPlotTriang(geom_set.femur_r)

%---- PELVIS -----
% solve reference system from geometry
[PelvisRS, PelvisBL]  = GIBOK_pelvis(geom_set.pelvis);
% ground_pelvis joint
JointParams = getJointParams('ground_pelvis', [], PelvisRS);
% create the joint
pelvis_ground_joint = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(pelvis_ground_joint);
%-----------------

% %---- FEMUR -----
FemurCS = MSK_femur_Kai2014(geom_set.femur_r);
[ FemurCSs, TrObjects ] = GIBOK_femur(geom_set.femur_r);

% % hip joint
JointParams = getJointParams('hip_r', PelvisRS, FemurCS);
% JointParams.parent_location     = HJC_location;
% JointParams.parent_orientation  = pelvis_orientation;
% JointParams.child_location      = HJC_location;
% JointParams.child_orientation   = femur_orientation;

% create the joint
hip_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(hip_r);

%---- TIBIA -----
% defines the axis for the tibia
TibiaRCS = MSK_tibia_Kai2014(geom_set.tibia_r);
[TibiaCSs, TrObjects] = GIBOK_tibia(geom_set.tibia_r);

% knee joint
% joint centre in femur
knee_location_in_parent = (FemurCS.Center1+FemurCS.Center2)/2.0*dim_fact;
tibia_orientation = computeZXYAngleSeq(TibiaRCS.V);

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

[ PatellaCSs, TrObjects ] = GIBOK_patella(geom_set.patella_r);
% PatellaRS = MSK_patella_Rainbow2013(geom_set.patella_r);

% patello-femoral joint (OpenSim way)
patfemjoint_location_in_parent = FemurCSs.PatGr.Origin*dim_fact;
patfemjoint_location_in_child = FemurCSs.PatGr.Origin*dim_fact;
patella_orientation = computeZXYAngleSeq(FemurCSs.PatGr.V);

% % patello-femoral joint (OpenSim way)
% patfemjoint_location_in_parent = PatellaCSs.VR.Origin*dim_fact;
% patfemjoint_location_in_child = PatellaCSs.VR.Origin*dim_fact;
% patella_orientation = computeZXYAngleSeq(PatellaCSs.VR.V);

% joint
JointParams = getJointParams('patellofemoral_r');
JointParams.parent_location     = patfemjoint_location_in_parent;
JointParams.parent_orientation  = femur_orientation;
JointParams.child_location      = patfemjoint_location_in_child;
JointParams.child_orientation   = patella_orientation;

% create the joint
patfem_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(patfem_r);


%---- TALUS -----
[AnkleCS, SubtalarCS] = GIBOK_talus(geom_set.talus_r);

JointParams = getJointParams('ankle_r');
ankle_location = AnkleCS.Origin* dim_fact;
talus_orientation = computeZXYAngleSeq(AnkleCS.V);

% tibiotalar
JointParams.parent_location    = ankle_location;
JointParams.parent_orientation = tibia_orientation;
JointParams.child_location     = ankle_location;
JointParams.child_orientation  = talus_orientation;

% create the joint
ankle_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(ankle_r);

%---- TALUS - SUBTALAR -----
subtalar_orientation = computeZXYAngleSeq(SubtalarCS.V);
subtalar_location = SubtalarCS.Origin * dim_fact;
% subtalar
JointParams = getJointParams('subtalar_r');
JointParams.parent_location    = subtalar_location;
JointParams.parent_orientation = subtalar_orientation;
JointParams.child_location     = subtalar_location;
JointParams.child_orientation  = subtalar_orientation;

% create the joint
subtalar_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(subtalar_r);

% landmarking
close all
% quickPlotTriang(geom_set.femur_r);hold on
% quickPlotRefSystem(FemurCS);
FemurRBL = LandmarkGeom(geom_set.femur_r, FemurCS, 'femur_r');
TibiaRBL = LandmarkGeom(geom_set.tibia_r, TibiaRCS, 'tibia_r');
PatellaRBL = LandmarkGeom(geom_set.patella_r, PatellaCSs.VR, 'patella_r');
CalcnBL = LandmarkGeom(geom_set.calcn_r, CalcaneusCS, 'calcn_r');
% add markers to model
addMarkersFromStruct(osimModel, 'pelvis' , PelvisBL, in_mm)
addMarkersFromStruct(osimModel, 'femur_r', FemurRBL, in_mm)
addMarkersFromStruct(osimModel, 'tibia_r', TibiaRBL, in_mm)
addMarkersFromStruct(osimModel, 'patella_r', PatellaRBL, in_mm)
addMarkersFromStruct(osimModel, 'calcn_r', CalcnBL,  in_mm)

% add patellofemoral constraint
% add patello-femoral joint

% addPatFemJointCoordCouplerConstraint(osimModel, 'r');
ptf = ConstantDistanceConstraint(osimModel.get_BodySet().get('tibia_r'),...
                                 Vec3(TibiaRBL.RTTB(1)*dim_fact, TibiaRBL.RTTB(2)*dim_fact, TibiaRBL.RTTB(3)*dim_fact),...
                                 osimModel.get_BodySet().get('patella_r'),...
                                 Vec3(PatellaRBL.RLOW(1)*dim_fact, PatellaRBL.RLOW(2)*dim_fact, PatellaRBL.RLOW(3)*dim_fact),...
                                 norm(TibiaRBL.RTTB-PatellaRBL.RLOW)*dim_fact);
addConstraint(osimModel, ptf)                                

osimModel.finalizeConnections();

% print
osimModel.print('5_auto_model.osim');
% osimModel.print(fullfile(osim_folder, [test_case, '.osim']));
% CS = computeCalcnISBCoordSyst(geom);

osimModel.disownAllComponents();
toc
% remove paths
rmpath(genpath('GIBOK-toolbox'));
rmpath('autoMSK_functions');
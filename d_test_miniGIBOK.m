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


%--------------------------------
% SETTINGS
%--------------------------------
bone_geom_folder = 'test_geometries';
ACs_folder = './ACs';
osim_folder = './opensim_models';
in_mm = 1;
nd = 1;
%--------------------------------

% add to osim model all bodies
dataset_set = {'LHDL_CT', 'P0_MRI', 'JIA_CSm6'};
dataset = dataset_set{nd};
tri_dir    = fullfile(bone_geom_folder,dataset,'tri');
body_list = {'pelvis','femur_r','tibia_r','talus_r', 'calcn_r', 'patella_r'};
triGeom_file_list = {'pelvis_no_sacrum','femur_r','tibia_r','talus_r', 'calcn_r','patella_r'};

for nb = 1:length(body_list)
    % update variables
    cur_body_name = body_list{nb};
    cur_geom_file = fullfile(tri_dir, triGeom_file_list{nb});
    geom_set.(cur_body_name) = load_mesh(cur_geom_file);
end

%---- PELVIS -----
% solve reference system from geometry
% [PelvisRS, JCS, PelvisBL]  = GIBOK_pelvis(geom_set.pelvis);

% %---- FEMUR -----
% % testing all options
% FemurCS  = CS_femur_Kai2014(geom_set.femur_r);
% FemurCSs = GIBOK_femur(geom_set.femur_r);
% FemurCSs = GIBOK_femur(geom_set.femur_r, [], 'spheres');
% FemurCSs = GIBOK_femur(geom_set.femur_r, [], 'ellipsoids');
% FemurCSs = GIBOK_femur(geom_set.femur_r, [], 'cylinder');



%---- TIBIA -----
% defines the axis for the tibia
TibiaCS = CS_tibia_Kai2014(geom_set.tibia_r);
TibiaCSs = GIBOK_tibia(geom_set.tibia_r);
%-----------------

%---- TALUS/ANKLE -----
TalusCS = GIBOK_talus(geom_set.talus_r);
% ankle joint
%-----------------

%---- CALCANEUS/SUBTALAR -----
CalcaneusCS = GIBOK_calcn(geom_set.calcn_r);
% subtalar joint
JointParams = getJointParams('subtalar_r', TalusCS, CalcaneusCS);
subtalar_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(subtalar_r);
%-----------------

%---- PATELLA -----
[ PatellaCS, TrObjects ] = GIBOK_patella(geom_set.patella_r);
% PatellaRS = MSK_patella_Rainbow2013(geom_set.patella_r);
PatellaCS = assemblePatellofemoralParentOrientation(FemurCSs, PatellaCS);
% patellofemoral joint
JointParams = getJointParams('patellofemoral_r', FemurCSs, PatellaCS);
patfem_r = createCustomJointFromStruct(osimModel, JointParams);
osimModel.addJoint(patfem_r);
%-----------------

% %---- LANDMARKING -----
% close all
% FemurRBL   = LandmarkGeom(geom_set.femur_r  , FemurCS,      'femur_r');
% TibiaRBL   = LandmarkGeom(geom_set.tibia_r  , TibiaCS,     'tibia_r');
% PatellaRBL = LandmarkGeom(geom_set.patella_r, PatellaCS, 'patella_r');
% CalcnBL    = LandmarkGeom(geom_set.calcn_r  , CalcaneusCS,  'calcn_r');
% 
% % add markers to model
% addMarkersFromStruct(osimModel, 'pelvis' ,   PelvisBL, in_mm);
% addMarkersFromStruct(osimModel, 'femur_r',   FemurRBL, in_mm);
% addMarkersFromStruct(osimModel, 'tibia_r',   TibiaRBL, in_mm);
% addMarkersFromStruct(osimModel, 'patella_r', PatellaRBL, in_mm);
% addMarkersFromStruct(osimModel, 'calcn_r',   CalcnBL,  in_mm);                           
% %-----------------

% add patellofemoral constraint
addPatellarTendonConstraint(osimModel, TibiaRBL, PatellaRBL, 'r')

% finalize
osimModel.finalizeConnections();

% print
osimModel.print('5_auto_model.osim');
% osimModel.print(fullfile(osim_folder, [test_case, '.osim']));

osimModel.disownAllComponents();
toc
% remove paths
rmpath(genpath('GIBOK-toolbox'));
rmpath('autoMSK_functions');
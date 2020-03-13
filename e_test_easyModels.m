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
% add OpenSim libraries
import org.opensim.modeling.*

%--------------------------------
% SETTINGS
%--------------------------------
bone_geom_folder = 'test_geometries';
ACs_folder = './ACs';
osim_folder = '';
dataset_set = {'LHDL_CT', 'P0_MRI', 'JIA_CSm6'};
body_list = {'pelvis','femur_r','tibia_r','talus_r', 'calcn_r', 'patella_r'};
triGeom_file_list = {'pelvis_no_sacrum','femur_r','tibia_r','talus_r', 'calcn_r','patella_r'};
in_mm = 1;
%--------------------------------

for nd = 1:3
% AIM IS TO HAVE A FUNCTION LIKE THIS
% osimModel = createOsimModelFromBoneGeometries(geom_set);

% adjust dimensional factors based on mm / m scales
if in_mm == 1;     dim_fact = 0.001;     bone_density = 0.000001420;%kg/mm3
else; dim_fact = 1;     bone_density = 1420;%kg/m3 
end

dataset = dataset_set{nd};
tri_dir    = fullfile(bone_geom_folder,dataset,'tri');
visual_dir = fullfile(bone_geom_folder,dataset,'vtp');
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

%---- PELVIS -----
[PelvisRS, JCS.pelvis, PelvisBL]  = GIBOK_pelvis(geom_set.pelvis);
%---- FEMUR -----
[FemurCS, JCS.femur_r]  = CS_femur_Kai2014(geom_set.femur_r);
% [FemurCS, JCS2] = GIBOK_femur(geom_set.femur_r);
% [FemurCS, JCS3] = GIBOK_femur(geom_set.femur_r, [], 'spheres');
% [FemurCS, JCS4] = GIBOK_femur(geom_set.femur_r, [], 'ellipsoids');
% [FemurCS, JCS5] = GIBOK_femur(geom_set.femur_r, [], 'cylinder');

%---- TIBIA -----
[TibiaCS, JCS.tibia_r] = CS_tibia_Kai2014(geom_set.tibia_r);
% [TibiaCS, JCS7] = GIBOK_tibia(geom_set.tibia_r, [], 'plateau');
% [TibiaCS, JCS8] = GIBOK_tibia(geom_set.tibia_r, [], 'ellipse');
% [TibiaCS, JCS9] = GIBOK_tibia(geom_set.tibia_r, [], 'centroids');
%---- TALUS/ANKLE -----
[TalusCS, JCS.talus_r] = GIBOK_talus(geom_set.talus_r);
%---- CALCANEUS/SUBTALAR -----
JCS.calcn_r = GIBOK_calcn(geom_set.calcn_r);
% subtalar joint
createLowerLimbJoints(osimModel, JCS)
%-----------------

%---- LANDMARKING -----
FemurRBL   = LandmarkGeom(geom_set.femur_r  , FemurCS,     'femur_r');
TibiaRBL   = LandmarkGeom(geom_set.tibia_r  , TibiaCS,     'tibia_r');
CalcnBL    = LandmarkGeom(geom_set.calcn_r  , JCS.calcn_r, 'calcn_r');
% add markers to model
addMarkersFromStruct(osimModel, 'pelvis' ,   PelvisBL, in_mm);
addMarkersFromStruct(osimModel, 'femur_r',   FemurRBL, in_mm);
addMarkersFromStruct(osimModel, 'tibia_r',   TibiaRBL, in_mm);
addMarkersFromStruct(osimModel, 'calcn_r',   CalcnBL,  in_mm);                           
%-----------------

% finalize connections
osimModel.finalizeConnections();
% print
osimModel.print(fullfile(osim_folder, [str2num(nd), dataset, '.osim']));
osimModel.disownAllComponents();
clear JCS
end
% remove paths
rmpath(genpath('GIBOK-toolbox'));
rmpath('autoMSK_functions');
clear; clc; close all
tic
% add useful scripts
addpath(genpath('GIBOK-toolbox'));
addpath('autoMSK_functions');
addpath(genpath('FemPatTibACS/KneeACS/Tools'));

%--------------------------------------
dataset_set = {'LHDL_CT', 'P0_MRI', 'JIA_CSm6', 'TLEM2_CT', 'TLEM2_MRI','VAKHUM_S6_CT'};
% dataset_set = {'TLEM2'};
body_list = {'pelvis_no_sacrum','femur_r','tibia_r','talus_r', 'calcn_r'};
in_mm = 1;
n_d = 3;
%--------------------------------------

% setup folders
model_name = dataset_set{n_d};
main_ds_folder =  ['test_geometries',filesep,dataset_set{n_d}];
tri_folder = fullfile(main_ds_folder,'tri');
vis_geom_folder=fullfile(main_ds_folder,'vtp');

for nb = 1:numel(body_list)
    cur_body_name = body_list{nb};
    cur_geom_file = fullfile(tri_folder, cur_body_name);
    if exist([cur_geom_file,'.mat'],'file')~=2; disp([cur_body_name,' geometry not available.']);continue; end
    geom_set.(cur_body_name) = load_mesh(cur_geom_file);
end

% create bodies
osimModel = createBodiesFromBoneGeometries(geom_set, vis_geom_folder);

% process bone geometries (compute joint parameters and identify markers)
[JCS, BL, CS] = analyzeBoneGeometries(geom_set);

% create joints
createLowerLimbJoints(osimModel, JCS);

% add markers to
addBoneLandmarksAsMarkers(osimModel, BL);

% finalize connections
osimModel.finalizeConnections();

% print
osimModel.setName([dataset_set{n_d},'_auto']);
osimModel.print([num2str(n_d),'_',model_name, '_auto.osim']);
osimModel.disownAllComponents();

disp(['Model generated in ', num2str(toc)]);

% remove paths
rmpath(genpath('GIBOK-toolbox'));
rmpath('autoMSK_functions');



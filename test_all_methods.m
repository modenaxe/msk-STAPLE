
%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% 
%          SCRIPT USED TO TEST THAT ALL METHODS ARE WORKING
%
% ----------------------------------------------------------------------- %
clear; clc; close all
tic
% add useful scripts
addpath(genpath('GIBOC-toolbox'));
addpath(genpath('autoMSK_functions'));
addpath(genpath('FemPatTibACS/KneeACS/Tools'));

%--------------------------------------
auto_models_folder = './validation/opensim_models';
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI', 'JIA_MRI'};
body_list = {'pelvis_no_sacrum','femur_r','tibia_r','patella_r','talus_r', 'calcn_r'};
in_mm = 1;
% method = 'Modenese2018';%
method = 'auto2020';
%--------------------------------------

% create model folder if required
if ~isfolder(auto_models_folder); mkdir(auto_models_folder); end

for n_d = 1
    % setup folders
    model_name = dataset_set{n_d};
    main_ds_folder =  ['test_geometries',filesep,dataset_set{n_d}];
    % tri_folder = fullfile(main_ds_folder,'stl');
    tri_folder = fullfile(main_ds_folder,'tri');
    vis_geom_folder=fullfile(main_ds_folder,'vtp');
    for nb = 1:numel(body_list)
        cur_body_name = body_list{nb};
        cur_geom_file = fullfile(tri_folder, cur_body_name);
        geom_set.(cur_body_name) = load_mesh(cur_geom_file);
    end
    %     [JCS, BL, CS] = analyzeBoneGeometries(geom_set);
    
    %---- PELVIS -----
    [PelvisRS, JCS.pelvis, PelvisBL]  = GIBOK_pelvis(geom_set.pelvis_no_sacrum,1,0);
%     [PelvisRS, JCS.pelvis, PelvisBL2]  = CS_pelvis_Kai2014(geom_set.pelvis_no_sacrum);
%     axis off
    
%     %---- FEMUR -----
%     [FemurCS0, JCS0] = Miranda2010_buildfACS(geom_set.femur_r);
%     [CS] = Miranda2010_femur(geom_set.femur_r);
%     [FemurCS1, JCS1] = CS_femur_Kai2014(geom_set.femur_r);
%     [FemurCS2, JCS2] = GIBOK_femur(geom_set.femur_r, [], 'spheres');
%     [FemurCS3, JCS3] = GIBOK_femur(geom_set.femur_r, [], 'ellipsoids');
    [FemurCS4, JCS4] = GIBOK_femur(geom_set.femur_r, [], 'cylinder');
%     %
%     %---- TIBIA -----
%     [TibiaCS0, JCS0] = Miranda2010_buildtACS(geom_set.tibia_r);
%     [TibiaCS1, JCS5] = CS_tibia_Kai2014(geom_set.tibia_r);
%     [TibiaCS2, JCS6] = GIBOK_tibia(geom_set.tibia_r, [], 'plateau');
%     [TibiaCS3, JCS7] = GIBOK_tibia(geom_set.tibia_r, [], 'ellipse');
%     [TibiaCS4, JCS8] = GIBOK_tibia(geom_set.tibia_r, [], 'centroids');

%---- PATELLA -----
% [CS.patella_r, JCS.patella_r, BL.patella_r] = Rainbow2013_buildpACS();
% [CS.patella_r, JCS.patella_r, BL.patella_r] = GIBOK_patella(geom_set.patella_r, 'volume-ridge');
% [CS.patella_r, JCS.patella_r, BL.patella_r] = GIBOK_patella(geom_set.patella_r, 'ridge-line');
% [CS.patella_r, JCS.patella_r, BL.patella_r] = GIBOK_patella(geom_set.patella_r, 'artic-surf');

%     %---- TALUS/ANKLE -----
%     [TalusCS, JCS.talus_r] = GIBOK_talus(geom_set.talus_r);
%     
%     %---- CALCANEUS/SUBTALAR -----
    JCS.calcn_r = GIBOK_calcn(geom_set.calcn_r, 0, 1);
    %-----------------
    clear JCS
%     close all
end

% remove paths
rmpath(genpath('GIBOK-toolbox'));
rmpath(genpath('FemPatTibACS/KneeACS/Tools'));
rmpath('autoMSK_functions');
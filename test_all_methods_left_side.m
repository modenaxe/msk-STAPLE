
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
addpath(genpath('STAPLE'));

%--------------------------------------
bone_geometries_folder = 'test_geometries';
dataset_set = {'TLEM2_CT'};
bones_list = {'pelvis_no_sacrum','femur_l','tibia_l','patella_l','talus_l', 'calcn_l'};
in_mm = 1;
%--------------------------------------


for n_d = 1:numel(dataset_set)
    % setup folders
    model_name = dataset_set{n_d};
    main_ds_folder =  fullfile(bone_geometries_folder,dataset_set{n_d});
    % tri_folder = fullfile(main_ds_folder,'stl');
    tri_folder = fullfile(main_ds_folder,'tri');

    % create geometry set structure for the entire dataset
    geom_set = createTriGeomSet(bones_list, tri_folder);
    
    % mirror
    
    %     [JCS, BL, CS] = analyzeBoneGeometries(geom_set);
    
    %---- PELVIS -----
%     [PelvisRS, JCS.pelvis, PelvisBL]  = STAPLE_pelvis(geom_set.pelvis_no_sacrum,1);
%     [PelvisRS, JCS.pelvis, PelvisBL2] = Kai2014_pelvis(geom_set.pelvis_no_sacrum);
    
%     %---- FEMUR -----
%     [FemurCS0, JCS0] = Miranda2010_buildfACS(geom_set.femur_l);
%     [FemurCS1, JCS1] = Kai2014_femur(geom_set.femur_l, [],1, 1);
%     [FemurCS2, JCS2] = GIBOC_femur(geom_set.femur_l, [], 'spheres');
%     [FemurCS3, JCS3] = GIBOC_femur(geom_set.femur_l, [], 'ellipsoids');
%     [FemurCS4, JCS4] = GIBOC_femur(geom_set.femur_l, [], 'cylinder');
%     %
%     %---- TIBIA -----
%     [TibiaCS0, JCS0] = Miranda2010_buildtACS(geom_set.tibia_l);
%     [TibiaCS1, JCS5] = Kai2014_tibia(geom_set.tibia_l);
%     [TibiaCS2, JCS6] = GIBOC_tibia(geom_set.tibia_l, [], 'plateau');
%     [TibiaCS3, JCS7] = GIBOC_tibia(geom_set.tibia_l, [], 'ellipse');
%     [TibiaCS4, JCS8] = GIBOC_tibia(geom_set.tibia_l, [], 'centroids');

%---- PATELLA -----
% [CS.patella_r, JCS.patella_r, BL.patella_r] = Rainbow2013_buildpACS();
% [CS.patella_r, JCS.patella_r, BL.patella_r] = GIBOC_patella(geom_set.patella_r, 'volume-ridge');
% [CS.patella_r, JCS.patella_r, BL.patella_r] = GIBOC_patella(geom_set.patella_r, 'ridge-line');
% [CS.patella_r, JCS.patella_r, BL.patella_r] = GIBOC_patella(geom_set.patella_r, 'artic-surf');

    %---- TALUS/ANKLE -----
    [TalusCS, JCS.talus_r] = STAPLE_talus(geom_set.talus_l);
    
    %---- CALCANEUS/SUBTALAR -----
    JCS.calcn_r = STAPLE_foot(geom_set.calcn_l, 1, 0);
    %-----------------
    clear JCS
%     close all
end

% remove paths
addpath(genpath('STAPLE'));
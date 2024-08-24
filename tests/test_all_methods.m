%-------------------------------------------------------------------------%
% Copyright (c) 2021 Modenese L.                                          %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
%
%          SCRIPT USED TO TEST THAT ALL METHODS ARE WORKING
%
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('../STAPLE'));

%--------------------------------------
bone_geometries_folder = '../bone_datasets';

% testing on one good and one bad quality dataset, bilaterally and
% monolaterally.
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI', 'JIA_MRI', 'VAKHUM_CT',};

sides = {'r', 'l'};
in_mm = 1;
%--------------------------------------
for n_side = 1:2
    side = sides{n_side};
    % bone names
    femur_name = ['femur_', side];     tibia_name = ['tibia_', side];
    patella_name=['patella_', side];     talus_name = ['talus_', side];
    calcn_name = ['calcn_', side];
    % bone list
    bones_list = {'pelvis_no_sacrum', femur_name, tibia_name,...
                  patella_name, talus_name, calcn_name};
    
    for n_d = 1:numel(dataset_set)
        
        % setup folders
        model_name = dataset_set{n_d};
        main_ds_folder =  fullfile(bone_geometries_folder,dataset_set{n_d});
        
        % geometry datasets
        tri_folder = fullfile(main_ds_folder,'tri');
        
        % create geometry set structure for the entire dataset
        geom_set = createTriGeomSet(bones_list, tri_folder);
        
%         % process all geometries at once
%         [JCS, BL, CS] = processTriGeomBoneSet(geom_set);
        
        %---- PELVIS -----
        if isfield(geom_set, 'pelvis_no_sacrum')
            [PelvisRS1, PelvisJCS1, PelvisBL1] = STAPLE_pelvis (geom_set.pelvis_no_sacrum, side);
            [PelvisRS2, PelvisJCS2, PelvisBL2] = Kai2014_pelvis(geom_set.pelvis_no_sacrum, side);
        end
        
        %---- FEMUR -----
        if isfield(geom_set, femur_name)
            %     [FemurCS0, JCS0] = Miranda2010_buildfACS(geom_set.(femur_name));
            [FemurCS1, FemurJCS1, FemurBL1] = Kai2014_femur(geom_set.(femur_name), side);
            [FemurCS2, FemurJCS2, FemurBL2] = GIBOC_femur(geom_set.(femur_name), side, 'spheres');
            [FemurCS3, FemurJCS3, FemurBL3] = GIBOC_femur(geom_set.(femur_name), side, 'ellipsoids');
            [FemurCS4, FemurJCS4, FemurBL4] = GIBOC_femur(geom_set.(femur_name), side, 'cylinder');
        end
        
        %---- TIBIA -----
        if isfield(geom_set, tibia_name)
            %     [TibiaCS0, JCS0] = Miranda2010_buildtACS(geom_set.(tibia_name));
            [TibiaCS1, TibiaJCS1, TibiaBL1] = Kai2014_tibia(geom_set.(tibia_name), side);
            [TibiaCS2, TibiaJCS2, TibiaBL2] = GIBOC_tibia(geom_set.(tibia_name), side, 'plateau');
            [TibiaCS3, TibiaJCS3, TibiaBL3] = GIBOC_tibia(geom_set.(tibia_name), side, 'ellipse');
            [TibiaCS4, TibiaJCS4, TibiaBL4] = GIBOC_tibia(geom_set.(tibia_name), side, 'centroids');
        end
        
        % %---- PATELLA -----
%         if isfield(geom_set, patella_name)
%             [PatellaCS1, PatellaJCS1, BL1] = Rainbow2013_buildpACS();
%             [PatellaCS2, PatellaJCS2, BL2] = GIBOC_patella(geom_set.(patella_name), 'volume-ridge');
%             [PatellaCS3, PatellaJCS3, BL3] = GIBOC_patella(geom_set.(patella_name), 'ridge-line');
%             [PatellaCS4, PatellaJCS4, BL4] = GIBOC_patella(geom_set.(patella_name), 'artic-surf');
%         end
        
%         %---- TALUS/ANKLE -----
        if isfield(geom_set, talus_name)
            [TalusCS, TalusJCS] = STAPLE_talus(geom_set.(talus_name), side);
        end
%         
%         %---- CALCANEUS/SUBTALAR -----
        if isfield(geom_set, calcn_name)
            [FootCS, FootJCS, FootBL] = STAPLE_foot(geom_set.(calcn_name), side);
        end
        
        %     close all
    end
    
end
% remove paths
addpath(genpath('../STAPLE'));
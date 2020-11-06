%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% Please note how the identification of the articular surfaces returns
% better results when applied to better quality meshes.
% 
% The exportable articular surfaces are available on the GIBOC_tibia and
% GIBOC_femur functions where the ArtSurf variable is defined.
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('STAPLE'));

%--------------------------------------
bone_geometries_folder = 'test_geometries';
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI'};
bones_list = {'pelvis_no_sacrum','femur_r','tibia_r','patella_r','talus_r', 'calcn_r'};
artic_surf_folder = './Articular_surfaces';
in_mm = 1;
%--------------------------------------

for n_d = 1:numel(dataset_set)
    % setup folders
    dataset_name = dataset_set{n_d};
    main_ds_folder =  fullfile(bone_geometries_folder,dataset_set{n_d});
    % tri_folder = fullfile(main_ds_folder,'stl');
    tri_folder = fullfile(main_ds_folder,'tri');

    % create geometry set structure for the entire dataset
    geom_set = createTriGeomSet(bones_list, tri_folder);
    
    % extract femoral tibiofemoral articular surfaces
    [FemurCS3, TibiaJCS3, ~, ArtSurfFem] = GIBOC_femur(geom_set.femur_r, 'R', [], 0);
    % extract articular surface in the tibia
    [TibiaCS, TibiaJCS, ~, ArtSurfTib] = GIBOC_tibia(geom_set.tibia_r, 'R', [], 0);
    
    % plot the articular surfaces and nearby bone
    figure('Name', dataset_name)
    % femur
    subplot(1, 2, 1)
    quickPlotTriang(ArtSurfFem.epiphysis);
    quickPlotTriang(ArtSurfFem.condyles, 'b');
    title('Distal femur with condyles')
    % tibia
    subplot(1,2,2)
    quickPlotTriang(ArtSurfTib.epi_tibia);
    quickPlotTriang(ArtSurfTib.tib_plateau, 'r');
    title('Proximal tibia with plateau')
    
    % save the triangulations as STL files
    % create folder
    curr_artic_surf_folder = fullfile(artic_surf_folder, dataset_name);
    if ~isfolder(curr_artic_surf_folder); mkdir(curr_artic_surf_folder); end
    % export femoral surfaces
    fem_str_fields = fields(ArtSurfFem);
    for n = 1:length(fem_str_fields)
        stl_path = fullfile(curr_artic_surf_folder, [fem_str_fields{n},'.stl']);
        stlwrite(ArtSurfFem.(fem_str_fields{n}), stl_path)
    end
    % export tibial surfaces
    tib_str_fields = fields(ArtSurfTib);
    for n = 1:length(tib_str_fields)
        stl_path = fullfile(curr_artic_surf_folder, [tib_str_fields{n},'.stl']);
        stlwrite(ArtSurfTib.(tib_str_fields{n}), stl_path)
    end
end

% remove paths
addpath(genpath('STAPLE'));
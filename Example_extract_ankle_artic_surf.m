%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% Example demonstrating how to exatract the articular surfaces of the
% talocrural and subtalar joints automatically from a set of tibial and 
% talar geometries through a batch processing using the GIBOC algorithms
% available in the STAPLE toolbox.
%
% This functionality can be useful for definition of advanced joint models 
% with contact.
%
% Please note how the identification of the articular surfaces returns
% better results when applied to better quality meshes, as expected.
% 
% The exportable articular surfaces are available on the GIBOC_tibia and
% STAPLE_talus functions where the ArtSurf variable is defined.
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('STAPLE'));

%----------%
% SETTINGS %
%----------%
% folders where the bone geometries are stored
datasets_folder = 'bone_datasets';

% name of the datasets to process
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI'};

% names of the bones to process with STAPLE
bones_list = {'tibia_r', 'talus_r'};

% folder where the articulalar surfaces will be stored
output_artic_surf_folder = './articular_surfaces/example_ankle';
%--------------------------------------

for n_d = 1:numel(dataset_set)
    
    % setup folders
    dataset_name = dataset_set{n_d};
    
    % folder of the bone geometries in MATLAB format ('tri'/'stl')
    tri_folder = fullfile(datasets_folder, dataset_set{n_d},'tri');

    % create geometry set structure for the entire dataset
    geom_set = createTriGeomSet(bones_list, tri_folder);
    
    % infer body side from TriGeomSet
    side = inferBodySideFromAnatomicStruct(geom_set);
    
    % extract tibial articular surfaces for tibio-femoral joint.
    % NB: *) fit_method not important here - there is no fitting to do
    %     *) no need to plot fitting results
    [TibiaCS, TibiaJCS, ~, ArtSurfTib] = GIBOC_tibia(geom_set.tibia_r, side, 'ellipse', 0);
    
    % extract talocrural articular surf. Not showing fitting result from
    % STAPLE function.
    [TalusCS, TalusJCS, ArtSurfTalus] = STAPLE_talus(geom_set.talus_r, side, 0);
    
    % NOTE: all articular surfaces are extracted from the bones of
    % interest. By commenting the fields in the GIBOC_femur.m and 
    % GIBOC_tibia.m the exported triangulations can be customized.
    
    % plot the articular surfaces and nearby bone
    figure('Name', dataset_name, 'Position', [626 502 1175 459])
    
    % talocrural art surf on tibial side
    subplot(1,2,1)
    quickPlotTriang(ArtSurfTib.(['dist_tibia_',side]));
    quickPlotTriang(ArtSurfTib.(['tibiotalar_', side]), 'g');
    title({'Talocrural joint: Distal tibia'})
    
    % talocrural art surf on ankle side
    subplot(1, 2, 2)
    quickPlotTriang(geom_set.(['talus_',side]));
    quickPlotTriang(ArtSurfTalus.(['talar_trochlea_',side]), 'b');
    quickPlotTriang(ArtSurfTalus.(['talo_calcn',side]), 'r');
    quickPlotTriang(ArtSurfTalus.(['talo_navic',side]), 'g');
    title({'Ankle Complex'; 'talar trochlea (blue); talar-calcn (red) - talonav (green)'})
    
    % save the triangulations as binary STL files
    % create folder
    curr_artic_surf_folder = fullfile(output_artic_surf_folder, dataset_name);
    if ~isfolder(curr_artic_surf_folder); mkdir(curr_artic_surf_folder); end
    
    %----------------------------------------------------------------------
    % NOTE that writing stl files relies on stlwrite, available on MATLAB
    % 2018b or more recent. If your MATLAB is older, then you can use 
    % stlWrite from GIBOC-core/SubFunctions/MeshReadFun/stlTools.
    % e.g. > stlWrite(stl_path, triObj.ConnectivityList, triObj.Points)
    %----------------------------------------------------------------------
    
    % export talar surfaces
    talus_str_fields = fields(ArtSurfTalus);
    for n = 1:length(talus_str_fields)
        stl_path = fullfile(curr_artic_surf_folder, [talus_str_fields{n},'.stl']);
        stlwrite(ArtSurfTalus.(talus_str_fields{n}), stl_path)
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
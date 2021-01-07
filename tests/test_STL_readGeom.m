%-------------------------------------------------------------------------%
% Copyright (c) 2021 Modenese L.                                          %
%    Author:   Luca Modenese, April 2018                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('../STAPLE'));
addpath('./support');
%----------
% SETTINGS 
%----------
output_models_folder = 'models_from_tests';

% datasets that you would like to process
dataset_set = {'TLEM2'};

% cell array with the bone geometries that you would like to process
bone_geometries_folder = '../bone_datasets';
bones_list = {'pelvis','femur_r','tibia_r','talus_r', 'calcn_r'};
in_mm = 1;

% visualization geometry format
vis_geom_format = 'obj'; % options: 'stl'/'obj'

% choose the definition of the joint coordinate systems (see documentation)
modelling_method = 'Modenese2020';
%--------------------------------------

tic

% create model folder if required
if ~isfolder(output_models_folder); mkdir(output_models_folder); end

for n_d = 1
    
    % setup folders
    cur_dataset = dataset_set{n_d};
    main_ds_folder =  fullfile(bone_geometries_folder, cur_dataset);
    
    % model and model file naming
    model_name = 'test_STL_readGeom';
    model_file_name = [model_name, '.osim'];
    
    % options to read stl or mat(tri) files
    tri_folder = fullfile(main_ds_folder,'stl');
%     tri_folder = fullfile(main_ds_folder,'tri');
    
    % create geometry set structure for all 3D bone geometries in the dataset
    triGeom_set = createTriGeomSet(bones_list, tri_folder);
    
    % create bone geometry folder for visualization
    geometry_folder_name = 'test_STL_readGeom';
    geometry_folder_path = fullfile(output_models_folder,geometry_folder_name);
    
    % convert geometries in chosen format (30% of faces for faster visualization)
    writeModelGeometriesFolder(triGeom_set, geometry_folder_path, vis_geom_format,0.3);
    
    % initialize OpenSim model
    osimModel = initializeOpenSimModel(model_name);
    
    % create bodies
    osimModel = addBodiesFromTriGeomBoneSet(osimModel, triGeom_set, geometry_folder_name, vis_geom_format);
    
    % process bone geometries (compute joint parameters and identify markers)
    [JCS, BL, CS] = processTriGeomBoneSet(triGeom_set);
    
    % create joints
%     createLowerLimbJoints(osimModel, JCS, modelling_method);
    
    % add markers to the bones
    addBoneLandmarksAsMarkers(osimModel, BL);
    
    % finalize connections
    osimModel.finalizeConnections();
    
    % print
    osimModel.print(fullfile(output_models_folder, model_file_name));
    
    % inform the user about time employed to create the model
    disp('-------------------------')
    disp(['Model generated in ', num2str(toc)]);
    disp('-------------------------')
end

% remove paths
rmpath(genpath('../STAPLE'));
rmpath('./support');
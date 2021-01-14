%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% This example demonstrates how to setup a STAPLE workflow to 
% automatically generate a complete model of the left legs of the TLEM_CT
% and TLEM2_MRI datasets included in the bone_datasets folder.
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('STAPLE'));

%----------%
% SETTINGS %
%----------%
output_models_folder = 'opensim_models_examples';

% folder where the various datasets (and their geometries) are located.
datasets_folder = 'bone_datasets';

% datasets that you would like to process
dataset_set = {'TLEM2_CT', 'TLEM2_MRI'};

% estimated mass of specimen
mass = 45; % [kg] 

% cell array with the bone geometries that you would like to process
bones_list = {'pelvis_no_sacrum','femur_l','tibia_l','talus_l', 'calcn_l'};

% visualization geometry format (options: 'stl' or 'obj')
vis_geom_format = 'obj';

% choose the definition of the joint coordinate systems (see documentation)
% options: 'Modenese2018' or 'auto2020'
workflow = 'Modenese2018';
%--------------------------------------

tic

% create model folder if required
if ~isfolder(output_models_folder); mkdir(output_models_folder); end

for n_d = 1:numel(dataset_set)
    
    % current dataset being processed
    cur_dataset = dataset_set{n_d};
    
    % folder from which triangulations will be read
    tri_folder = fullfile(datasets_folder, cur_dataset,'tri');
    
    % create geometry set structure for all 3D bone geometries in the dataset
    triGeom_set = createTriGeomSet(bones_list, tri_folder);
    
    % get the body side (can also be specified by user as input to funcs)
    side = inferBodySideFromAnatomicStruct(triGeom_set);
    
    % model and model file naming
    cur_model_name = ['auto_',dataset_set{n_d},'_',upper(side)];
    model_file_name = [cur_model_name, '.osim'];
    
    % log printout
    log_file = fullfile(output_models_folder, [cur_model_name, '.log']);
    logConsolePrintout('on', log_file);
    
    % create bone geometry folder for visualization
    geometry_folder_name = [cur_model_name, '_Geometry'];
    geometry_folder_path = fullfile(output_models_folder,geometry_folder_name);
    
    % convert geometries in chosen format (30% of faces for faster visualization)
    writeModelGeometriesFolder(triGeom_set, geometry_folder_path, vis_geom_format,0.3);
    
    % initialize OpenSim model
    osimModel = initializeOpenSimModel(cur_model_name);
    
    % create bodies
    osimModel = addBodiesFromTriGeomBoneSet(osimModel, triGeom_set, geometry_folder_name, vis_geom_format);
    
    % process bone geometries (compute joint parameters and identify markers)
    [JCS, BL, CS] = processTriGeomBoneSet(triGeom_set, side);
    
    % create joints
    createOpenSimModelJoints(osimModel, JCS, workflow);
    
    % update mass properties to those estimated using a scale version of
    % gait2392 with COM based on Winters's book.
    osimModel = assignMassPropsToSegments(osimModel, JCS, mass);
    
    % add markers to the bones
    addBoneLandmarksAsMarkers(osimModel, BL);
    
    % finalize connections
    osimModel.finalizeConnections();
    
    % print
    osimModel.print(fullfile(output_models_folder, model_file_name));
    
    % inform the user about time employed to create the model
    disp('-------------------------')
    disp(['Model generated in ', sprintf('%.1f', toc), ' s']);
    disp(['Saved as ', fullfile(output_models_folder, model_file_name),'.']);
    disp(['Model geometries saved in folder: ', geometry_folder_path,'.'])
    disp('-------------------------')
    logConsolePrintout('off');
end

% remove paths
rmpath(genpath('STAPLE'));
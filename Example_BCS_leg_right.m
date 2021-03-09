%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% This example demonstrates how to setup a STAPLE workflow to 
% automatically generate a complete of the right leg of 
% the TLEM2_CT anatomical dataset.
% NOTE: all bones and objects are in local reference system
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
datasets = {'TLEM2_CT'};

% estimated mass of specimen
mass = 45; % [kg] 

% body sides
cur_side = 'r';

% cell array with the bone geometries that you would like to process
bones_list = {'pelvis_no_sacrum',  ['femur_', cur_side],...
              ['tibia_', cur_side],['talus_', cur_side],...
              ['calcn_', cur_side],['toes_', cur_side]};

% visualization geometry format (options: 'stl' or 'obj')
vis_geom_format = 'obj';

% choose the definition of the joint coordinate systems (see documentation)
% options: 'Modenese2018' or 'auto2020'
workflow = 'Modenese2018';
%--------------------------------------

tic

% create model folder if required
if ~isfolder(output_models_folder); mkdir(output_models_folder); end

for n_d = 1:numel(datasets)
    
    % current dataset being processed
    cur_dataset = datasets{n_d};
    
    % folder from which triangulations will be read
    tri_folder = fullfile(datasets_folder, cur_dataset, 'tri');
    
    % create geometry set structure for all 3D bone geometries in the dataset
    triGeom_set = createTriGeomSet(bones_list, tri_folder);
    
    % get the body side (can also be specified by user as input to funcs)
    side = inferBodySideFromAnatomicStruct(triGeom_set);
    
    % model and model file naming
    model_name = ['auto_',datasets{n_d},'_',upper(side)];
    model_file_name = [model_name, '.osim'];
    
    % log printout
    log_file = fullfile(output_models_folder, [model_name, '.log']);
    logConsolePrintout('on', log_file);
    
    % create bone geometry folder for visualization
    geometry_folder_name = [model_name, '_Geometry'];
    geometry_folder_path = fullfile(output_models_folder,geometry_folder_name);
    
    % run morphological analysis
    [JCS, BL, BCS] = processTriGeomBoneSet(triGeom_set, side);  
    
    % create complete opensim joints structure
    osim_JCS = finalizeJointStruct(JCS, workflow);
    
    % move everything to BCS
    [updTriBoneGeom, jointStruct, landmarkStruct] = transformToBodyCS(BCS, triGeom_set, osim_JCS, BL);
    
    % write geometried in BCS
    writeModelGeometriesFolder(updTriBoneGeom, geometry_folder_path, vis_geom_format,0.3);
    
    % initialize OpenSim model
    osimModel = initializeOpenSimModel(model_name);
    
    % create bodies
    osimModel = addBodiesFromTriGeomBoneSet(osimModel, updTriBoneGeom, geometry_folder_name, vis_geom_format);
    
    % add joints to osimModel
    osimModel = addJointsFromStruct(osimModel, jointStruct);

    % update mass properties to those estimated using a scale version of
    % gait2392 with COM based on Winters's book.
    osimModel = assignMassPropsToSegments(osimModel, jointStruct, mass);
    
    % add markers to the bones
    addBoneLandmarksAsMarkers(osimModel, landmarkStruct);
    
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
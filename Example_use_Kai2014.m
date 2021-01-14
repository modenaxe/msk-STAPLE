%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% This example demonstrates how to setup a STAPLE workflow including 
% morphological analyses performed with the algorithms published by Kai et
% al. JBiomech (2014).
% In our experience these algorithms are more robust with low-quality
% bone geometries. The MC22 anatomical dataset presents the worst quality
% geometries among the provided datasets.
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('./STAPLE'));

%----------%
% SETTINGS %
%----------%
output_models_folder = 'opensim_models_examples';

% folder where the various datasets (and their geometries) are located.
datasets_folder = 'bone_datasets';

% datasets that you would like to process
dataset_set = {'MC22'};

% anthropometrics
H = 160; %cm
subj_mass = 66.3; %kg

% cell array with the bone geometries that you would like to process
% no foot or ankle here, as foot is a unique geometry including everything
% below tibia and cannot be processed at the moment.
bones_list = {'pelvis_no_sacrum','femur_r','tibia_r'};

% visualization geometry format (options: 'stl' or 'obj')
vis_geom_format = 'obj';

% choose the definition of the joint coordinate systems (see documentation)
% options: 'Modenese2018' or 'auto2020'
workflow = 'auto2020';
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
    model_name = ['auto_',dataset_set{n_d},'_',upper(side)];
    model_file_name = [model_name, '.osim'];
    
    % log printout
    log_file = fullfile(output_models_folder, [model_name, '.log']);
    logConsolePrintout('on', log_file);
    
    % create bone geometry folder for visualization
    geometry_folder_name = [model_name, '_Geometry'];
    geometry_folder_path = fullfile(output_models_folder,geometry_folder_name);
    
    % convert geometries in chosen format (30% of faces for faster visualization)
    writeModelGeometriesFolder(triGeom_set, geometry_folder_path, vis_geom_format,0.3);
    
    % initialize OpenSim model
    osimModel = initializeOpenSimModel(model_name);
    
    % create bodies
    osimModel = addBodiesFromTriGeomBoneSet(osimModel, triGeom_set, geometry_folder_name, vis_geom_format);
    
    % process bone geometries (compute joint parameters and identify markers)
    %                                                         pelvis    femur     tibia 
    [JCS, BL, CS] = processTriGeomBoneSet(triGeom_set, side, 'Kai2014','Kai2014','Kai2014');
    
    % create joints
    createOpenSimModelJoints(osimModel, JCS, workflow);

    % update mass properties to those estimated using a scale version of
    % gait2392 with COM based on Winters's book.
    osimModel = assignMassPropsToSegments(osimModel, JCS, subj_mass);
    
    % add markers to the bones
    addBoneLandmarksAsMarkers(osimModel, BL);
    
    % finalize connections
    osimModel.finalizeConnections();
    
    % print
    osimModel.print(fullfile(output_models_folder, model_file_name));
    
    % inform the user about time employed to create the model
    disp('-------------------------')
    disp(['Model generated in ', num2str(toc)]);
    disp(['Saved as ', fullfile(output_models_folder, model_file_name),'.']);
    disp('-------------------------')
    logConsolePrintout('off');
end

% remove paths
rmpath(genpath('STAPLE'));
%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('STAPLE'));

%----------%
% SETTINGS %
%----------%
% set output folder
output_models_folder = 'opensim_models_examples';

% folder where the various datasets (and their geometries) are located.
datasets_folder = 'bone_datasets';

% datasets that you would like to process
dataset_set = {'ICL_MRI'};
body_mass = 87; %kg

% cell array with the name of the bone geometries to process
bones_list = {'femur_r', 'tibia_r'};

% format of visualization geometry (obj preferred - smaller files)
vis_geom_format = 'obj'; 

% choose the definition of the joint coordinate systems (see documentation)
joint_defs = 'auto2020';

%--------------------------------------

% create model folder if required
if ~isfolder(output_models_folder); mkdir(output_models_folder); end

for n_d = 1:numel(dataset_set)
    
    % setup folders
    cur_dataset = dataset_set{n_d};
    
    % infer body side
    cur_side = inferBodySideFromAnatomicStruct(bones_list);
    
    % model name
    cur_model_name = ['example_', joint_defs,'_knee_', upper(cur_side)];
    
    % set output model name
    output_model_file_name = [cur_model_name,'.osim'];
    
    % log printout
    log_file = fullfile(output_models_folder, [cur_model_name, '.log']);
    logConsolePrintout('on', log_file);
    
    % folder including the bone geometries in MATLAB format (triangulations)
    tri_folder = fullfile(datasets_folder, cur_dataset,'tri');
    
    % create geometry set structure for the entire dataset
    geom_set = createTriGeomSet(bones_list, tri_folder);
    
    % create bone geometry folder for visualization
    geometry_folder_name = [cur_model_name, '_Geometry'];
    geometry_folder_path = fullfile(output_models_folder,geometry_folder_name);
    writeModelGeometriesFolder(geom_set, geometry_folder_path, vis_geom_format);
    
    % initialize OpenSim model
    osimModel = initializeOpenSimModel(cur_model_name);
    
    % create bodies
    osimModel = addBodiesFromTriGeomBoneSet(osimModel, geom_set, geometry_folder_name, vis_geom_format);
    
    % process bone geometries (compute joint parameters and identify markers)
    [JCS, BL, CS] = processTriGeomBoneSet(geom_set);
    
    % create joints
    createOpenSimModelJoints(osimModel, JCS, joint_defs);

    
    % add patella to tibia (this will be replaced by a proper joint and
    % dealt with the other joints in the future).
    side = inferBodySideFromAnatomicStruct(geom_set);

    % temporary approach to improve
    attachPatellaGeom(osimModel, side, tri_folder, geometry_folder_path, geometry_folder_name, vis_geom_format)
    
    % update mass properties to those estimated using a scale version of
    % gait2392 with COM based on Winters's book.
    osimModel = assignMassPropsToSegments(osimModel, JCS, body_mass);
    
    % add markers to the bones
    addBoneLandmarksAsMarkers(osimModel, BL);
    
    % finalize connections
    osimModel.finalizeConnections();
    
    % print OpenSim model
    osimModel.print(fullfile(output_models_folder, output_model_file_name));
    
    % inform the user about time employed to create the model
    disp('-------------------------')
    disp(['Model generated in ', sprintf('%.1f', toc), ' s']);
    disp(['Saved as ', fullfile(output_models_folder, output_model_file_name),'.']);
    disp(['Model geometries saved in folder: ', geometry_folder_path,'.'])
    disp('-------------------------')
    logConsolePrintout('off');
end

% remove paths
rmpath(genpath('msk-STAPLE/STAPLE'));
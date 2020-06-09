%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('STAPLE'));

%----------
% SETTINGS 
%----------
output_models_folder = 'Opensim_models';
output_model_file_name = 'example_knee_joint_model.osim';

% datasets that you would like to process
dataset_set = {'ICL_MRI'};

% cell array with the bone geometries that you would like to process
bone_geometries_folder = 'test_geometries';
bones_list = {'femur_r', 'tibia_r'};
in_mm = 1;

% visualization geometry format
vis_geom_format = 'obj'; % options: 'stl'/'obj'

% choose the definition of the joint coordinate systems (see documentation)
method = 'auto2020';
%--------------------------------------


% create model folder if required
if ~isfolder(output_models_folder); mkdir(output_models_folder); end

for n_d = 1:numel(dataset_set)
    
    % setup folders
    cur_dataset = dataset_set{n_d};
    main_ds_folder =  fullfile(bone_geometries_folder, cur_dataset);
    
    % model and model file naming
    model_name = [dataset_set{n_d},'_auto'];
    
    % options to read stl or mat(tri) files
    % tri_folder = fullfile(main_ds_folder,'stl');
    tri_folder = fullfile(main_ds_folder,'tri');
    
    % create geometry set structure for the entire dataset
    geom_set = createTriGeomSet(bones_list, tri_folder);
    
    % create bone geometry folder for visualization
    geometry_folder_name = [cur_dataset, '_Geometry'];
    geometry_folder_path = fullfile(output_models_folder,geometry_folder_name);
    writeModelGeometriesFolder(geom_set, geometry_folder_path, vis_geom_format);
    
    % initialize OpenSim model
    osimModel = initializeOpenSimModel(model_name);
    
    % create bodies
    osimModel = addBodiesFromTriGeomBoneSet(osimModel, geom_set, geometry_folder_name, vis_geom_format);
    
    % process bone geometries (compute joint parameters and identify markers)
    [JCS, BL, CS] = processTriGeomBoneSet(geom_set);
    
    %----------------------------------
    % SPECIAL PART FOR PARTIAL MODELS
    %----------------------------------
    % creating an ad hoc body and joint for connecting with ground
    % femur will be aligned with ground using its proximal JCS
    JCS.proxbody.free_to_ground.child = 'femur_r';
    JCS.proxbody.free_to_ground.child_location = JCS.femur_r.hip_r.Origin/1000; %in m
    JCS.proxbody.free_to_ground.child_orientation = computeXYZAngleSeq(JCS.femur_r.hip_r.V);
    %----------------------------------------------------------------------
    
    % create joints
    createLowerLimbJoints(osimModel, JCS, method);
    
    % add markers to the bones
    addBoneLandmarksAsMarkers(osimModel, BL);
    
    % finalize connections
    osimModel.finalizeConnections();
    
    % print OpenSim model
    osimModel.print(fullfile(output_models_folder, output_model_file_name));
    
    % inform the user about time employed to create the model
    disp('-------------------------')
    disp(['Model generated in ', num2str(toc)]);
    disp('-------------------------')
end

% remove paths
rmpath(genpath('msk-STAPLE/STAPLE'));
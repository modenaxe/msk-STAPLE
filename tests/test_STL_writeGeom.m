%-------------------------------------------------------------------------%
% Copyright (c) 2021 Modenese L.                                          %
%    Author:   Luca Modenese, April 2018                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('../STAPLE'));

%----------
% SETTINGS 
%----------
output_models_folder = 'models_from_tests';

% datasets that you would like to process
dataset_set = {'JIA_ANKLE_MRI'};

% cell array with the bone geometries that you would like to process
bone_geometries_folder = '../bone_datasets';
bones_list = {'tibia_r','talus_r','calcn_r'};
in_mm = 1;

% visualization geometry format
vis_geom_format = 'stl'; % options: 'stl'/'obj'

% choose the definition of the joint coordinate systems (see documentation)
joint_defs = 'auto2020';
%--------------------------------------


% create model folder if required
if ~isfolder(output_models_folder); mkdir(output_models_folder); end

for n_d = 1:numel(dataset_set)
    
    % setup folders
    cur_dataset = dataset_set{n_d};
    main_ds_folder =  fullfile(bone_geometries_folder, cur_dataset);
    
    % model and model file naming
    model_name = 'test_STL_writeGeom';
    output_model_file_name = [model_name,'.osim'];
    % options to read stl or mat(tri) files
    % tri_folder = fullfile(main_ds_folder,'stl');
    tri_folder = fullfile(main_ds_folder,'tri');
    
    % create geometry set structure for the entire dataset
    geom_set = createTriGeomSet(bones_list, tri_folder);
    
    % create bone geometry folder for visualization
    geometry_folder_name = 'test_STL_writeGeom';
    geometry_folder_path = fullfile(output_models_folder,geometry_folder_name);
    writeModelGeometriesFolder(geom_set, geometry_folder_path, vis_geom_format);
    
    % initialize OpenSim model
    osimModel = initializeOpenSimModel(model_name);
    
    % create bodies
    osimModel = addBodiesFromTriGeomBoneSet(osimModel, geom_set, geometry_folder_name, vis_geom_format);
    
    % process bone geometries (compute joint parameters and identify markers)
    [JCS, BL, CS] = processTriGeomBoneSet(geom_set);
    
    %-----------------------------------
    % SPECIAL SECTION FOR PARTIAL MODELS
    %-----------------------------------
    % Using Kai2014 on the proximal tibia identifies the largest section
    % near the ankle joint. Importantly, the reference system is aligned
    % with the principal components of the geometry, so roughly with the
    % section of the tibial stem available. Being the largest section of
    % tibia distal, the Y axis points downwards, and needs to be inverted.
    JCS.tibia_r.knee_r.V(:,2) = -JCS.tibia_r.knee_r.V(:,2);
    % Z axis is ok, as based on the detection of fibula.
    % X axis needs to be inverted
    JCS.tibia_r.knee_r.V(:,1) = normalizeV(cross(JCS.tibia_r.knee_r.V(:,2), JCS.tibia_r.knee_r.V(:,3)));
    % creating an ad hoc body and joint for connecting with ground
    JCS.proxbody.free_to_ground.child = 'tibia_r';
    JCS.proxbody.free_to_ground.child_location = CS.tibia_r.Origin/1000; %in m
    JCS.proxbody.free_to_ground.child_orientation = computeXYZAngleSeq(JCS.tibia_r.knee_r.V);
    %----------------------------------------------------------------------
    
    % create joints
    createOpenSimModelJoints(osimModel, JCS, joint_defs);
    
    %----------------------------------
    % SPECIAL PART FOR PARTIAL MODELS
    %----------------------------------
    % remove markers found by Kai2014 at the tibia, as they will be
    % incorrect.
    BL = rmfield(BL,'tibia_r');
    % add markers to the bones
    addBoneLandmarksAsMarkers(osimModel, BL);
    %-----------------------------------

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
end

% remove paths
rmpath(genpath('../STAPLE'));
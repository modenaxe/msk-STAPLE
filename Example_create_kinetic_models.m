%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% This script automatically creates the kinetic models used for analysis 
% in the manuscript:
% Modenese, Luca, and Jean-Baptiste Renault. "Automatic Generation of 
% Personalised Skeletal Models of the Lower Limb from Three-Dimensional 
% Bone Geometries." bioRxiv (2020).
% https://www.biorxiv.org/content/10.1101/2020.06.23.162727v2
% from the available datasets using a STAPLE workflow that uses the joint
% definitions of Modenese et al. J.Biomech. (2018).
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('STAPLE'));

%----------%
% SETTINGS %
%----------%
output_models_folder = 'opensim_models_JBiomech';

% folder where the various datasets (and their geometries) are located.
datasets_folder = 'bone_datasets';

% datasets that you would like to process
dataset_set  = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI', 'JIA_MRI'};

% mass of individuals required for segment estimation
subj_mass_set = [  64,         45,        87,        76.5];

% cell array with the bone geometries that you would like to process
bones_list = {'pelvis_no_sacrum','femur_r','tibia_r','talus_r', 'calcn_r'};

% visualization geometry format
vis_geom_format = 'obj'; % options: 'stl'/'obj'

% choose the definition of the joint coordinate systems (see documentation)
joint_defs = 'Modenese2018';
%--------------------------------------

% create model folder if required
if ~isfolder(output_models_folder); mkdir(output_models_folder); end

for n_d = 1:numel(dataset_set)
    
    % current dataset being processed
    cur_dataset = dataset_set{n_d};
    
    % folder from which triangulations will be read
    tri_folder = fullfile(datasets_folder, cur_dataset,'tri');
    
    % create geometry set structure for all 3D bone geometries in the dataset
    triGeom_set = createTriGeomSet(bones_list, tri_folder);
    
    % infer the body side (can also be specified by user as input to funcs)
    side = inferBodySideFromAnatomicStruct(triGeom_set);
    
    % model and model file naming
    cur_model_name = ['automatic_',dataset_set{n_d}];
    model_file_name = [cur_model_name, '.osim'];
    
    % log printout
    log_file = fullfile(output_models_folder, [cur_model_name, '.log']);
    logConsolePrintout('on', log_file);
    
    % create bone geometry folder for visualization
    geometry_folder_name = [cur_model_name, '_Geometries'];
    geometry_folder_path = fullfile(output_models_folder,geometry_folder_name);
    
    % convert geometries in chosen format (30% of faces for faster visualization)
    writeModelGeometriesFolder(triGeom_set, geometry_folder_path, vis_geom_format,0.3);
      
    % initialize OpenSim model
    osimModel = initializeOpenSimModel(cur_model_name);
    
    % create bodies
    osimModel = addBodiesFromTriGeomBoneSet(osimModel, triGeom_set, geometry_folder_name, vis_geom_format);
    
    % add patella to tibia (this will be replaced by a proper joint and
    % dealt with the other joints in the future).
    attachPatellaGeom(osimModel, side, tri_folder, geometry_folder_path, geometry_folder_name, vis_geom_format)
    
    % process bone geometries (compute joint parameters and identify markers)
    [JCS, BL, CS] = processTriGeomBoneSet(triGeom_set, side);
    
    % create joints
    createOpenSimModelJoints(osimModel, JCS, joint_defs);
    
    % update mass properties to those estimated using a scale version of
    % gait2392 with COM based on Winters's book.
    osimModel = assignMassPropsToSegments(osimModel, JCS, subj_mass_set(n_d));
    
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
    close all
    logConsolePrintout('off');
end

% remove paths
rmpath(genpath('STAPLE'));
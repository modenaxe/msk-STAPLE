%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear; clc; close all
tic
% add useful scripts
% addpath(genpath('GIBOC-toolbox'));
% addpath(genpath('autoMSK_functions'));
% addpath(genpath('FemPatTibACS/KneeACS/Tools'));

%--------------------------------------
auto_models_folder = './validation/opensim_models';
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI', 'JIA_MRI'};
body_list = {'pelvis_no_sacrum','femur_r','tibia_r','talus_r', 'calcn_r'};
in_mm = 1;
method = 'Modenese2018';
% method = 'auto2020';
%--------------------------------------

% create model folder if required
if ~isfolder(auto_models_folder); mkdir(auto_models_folder); end

for n_d = 1:4
    % setup folders
    model_name = dataset_set{n_d};
    main_ds_folder =  ['test_geometries',filesep,dataset_set{n_d}];
    % tri_folder = fullfile(main_ds_folder,'stl');
    tri_folder = fullfile(main_ds_folder,'tri');
    vis_geom_folder=fullfile(main_ds_folder,'vtp');
    
    tic
    geom_set = createTriGeomSet(body_list, tri_folder);
    disp(['Geometries imported in ', num2str(toc), ' s']);
    
    % create bodies
    osimModel = createBodiesFromTriGeomBoneSet(geom_set, vis_geom_folder);
    
    % process bone geometries (compute joint parameters and identify markers)
    [JCS, BL, CS] = processTriGeomBoneSet(geom_set);
    
    % create joints
    createLowerLimbJoints(osimModel, JCS, method);
    
    % add markers to
    addBoneLandmarksAsMarkers(osimModel, BL);
    
    % finalize connections
    osimModel.finalizeConnections();
    
    % print
    osimModel.set_credits('Luca Modenese, Jean-Baptist Renault - Toolbox to generate MSK models automatically.')
    osimModel.setName([dataset_set{n_d},'_auto']);
%     osimModel.print(fullfile(auto_models_folder, [method,'_',model_name, '.osim']));
%     osimModel.print(fullfile([method,'_',model_name, '.osim']));
    osimModel.disownAllComponents();
    
    disp(['Model generated in ', num2str(toc)]);
    
end

% remove paths
rmpath(genpath('GIBOC-toolbox'));
rmpath('autoMSK_functions');



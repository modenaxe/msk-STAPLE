%-------------------------------------------------------------------------%
% Copyright (c) 2022 MCM Fischer.                                         %
%    Author:   MCM Fischer,  2022                                         %
% ----------------------------------------------------------------------- %
% This example demonstrates how to setup a STAPLE workflow to
% automatically generate a complete kinematic model of the lower
% extremities using the anatomical VSDFullBodyBoneModels datasets.
% ----------------------------------------------------------------------- %
clear; clc; close all

% STAPLE library
addpath(genpath('STAPLE'));
% Additional libraries
addpath(genpath('C:\dev\matGeom')) % https://github.com/mattools/matGeom

%% SETTINGS ------------------------------------------------------------- %
output_models_folder = 'opensim_models_examples';
% folder where the various datasets (and their geometries) are located.
datasets_folder = 'bone_datasets';

% format of input geometries
input_geom_format = 'tri';
% visualization geometry format (options: 'stl' or 'obj')
vis_geom_format = 'obj';
% body sides
sides = {'r', 'l'};
% choose the definition of the joint coordinate systems (see documentation)
joint_defs = 'Modenese2018';
% ----------------------------------------------------------------------- %

%% VSDFullBodyBoneModels
% Clone example data
if ~exist('VSD', 'dir')
    try
    !git clone https://github.com/MCM-Fischer/VSDFullBodyBoneModels VSD
    rmdir('VSD/.git', 's')
    catch
        warning([newline 'Clone (or copy) the example data from: ' ...
            'https://github.com/MCM-Fischer/VSDFullBodyBoneModels' newline 'to: ' ...
            fileparts([mfilename('fullpath'), '.m']) '\VSD' ...
            ' and try again!' newline])
        return
    end
end

%% Convert VSD to STAPLE format
vsdSubjects = readtable(fullfile('VSD\MATLAB\res\', 'VSD_Subjects.xlsx'));
% Remove subjects with incomplete skeletal anatomy
vsdSubjects = vsdSubjects(cellfun(@(x) isempty(strfind(x,'cut off')), vsdSubjects.Comment),:); %#ok<STREMP>

% Select subjects to be processed
subs = 1;%1:size(vsdSubjects,1);

for n_sub = subs
    load(fullfile('VSD', 'Bones', [vsdSubjects.ID{n_sub} '.mat']),'B','M')
    subFolder = fullfile(datasets_folder, ['VSD_' vsdSubjects.ID{n_sub}] , input_geom_format);
    if ~isfolder(subFolder)
        mkdir(subFolder)
        disp(['Created: ' datasets_folder '\' subFolder])
    end
    % Create 'pelvis_no_sacrum.mat'
    trPath = fullfile(subFolder, 'pelvis_no_sacrum.mat');
    if ~isfile(trPath)
        TR = concatenateMeshes(B(ismember({B.name},'Hip_R')).mesh,B(ismember({B.name},'Hip_L')).mesh);
        TR = triangulation(TR.faces, TR.vertices);
        save(trPath,'TR')
    end
    % Create legs
    for n_side = 1:length(sides)
        % Create 'femur_*.mat'
        trPath = fullfile(subFolder, ['femur_' sides{n_side}]);
        if ~isfile(trPath)
            TR = splitMesh(B(ismember({B.name},['Femur_' upper(sides{n_side})])).mesh,'maxBoundingBox');
            TR = triangulation(TR.faces, TR.vertices);
            save(trPath,'TR')
        end
        % Create 'tibia_*.mat'
        trPath = fullfile(subFolder, ['tibia_' sides{n_side}]);
        if ~isfile(trPath)
            TR = concatenateMeshes(...
                B(ismember({B.name},['Tibia_' upper(sides{n_side})])).mesh,...
                B(ismember({B.name},['Fibula_' upper(sides{n_side})])).mesh);
            TR = triangulation(TR.faces, TR.vertices);
            save(trPath,'TR')
        end
        % Create 'talus_*.mat'
        trPath = fullfile(subFolder, ['talus_' sides{n_side}]);
        if ~isfile(trPath)
            TR = splitMesh(B(ismember({B.name},['Talus_' upper(sides{n_side})])).mesh,'maxBoundingBox');
            TR = triangulation(TR.faces, TR.vertices);
            save(trPath,'TR')
        end
        % Create 'calcn_*.mat'
        trPath = fullfile(subFolder, ['calcn_' sides{n_side}]);
        if ~isfile(trPath)
            TR = splitMesh(B(ismember({B.name},['Calcaneus_' upper(sides{n_side})])).mesh,'maxBoundingBox');
            TR = concatenateMeshes(TR,...
                B(ismember({B.name},['Tarsals_' upper(sides{n_side})])).mesh,...
                B(ismember({B.name},['Metatarsals_' upper(sides{n_side})])).mesh);
            TR = triangulation(TR.faces, TR.vertices);
            save(trPath,'TR')
        end
        % Create 'toes_*.mat'
        trPath = fullfile(subFolder, ['toes_' sides{n_side}]);
        if ~isfile(trPath)
            TR = B(ismember({B.name},['Phalanges_' upper(sides{n_side})])).mesh;
            TR = triangulation(TR.faces, TR.vertices);
            save(trPath,'TR')
        end
    end
end

%% STAPLE
% datasets that are processed
datasets = strcat('VSD_',vsdSubjects.ID');
% masses for models
subj_mass_set = vsdSubjects.Weight'; %kg

tic

% create model folder if required
if ~isfolder(output_models_folder); mkdir(output_models_folder); end

for n_d = subs
    
    % current dataset being processed
    cur_dataset = datasets{n_d};
    
    % folder from which triangulations will be read
    tri_folder = fullfile(datasets_folder, cur_dataset, input_geom_format);
    
    % log printout
    log_file = fullfile(output_models_folder, [cur_dataset,'_bilateral.log']);
    logConsolePrintout('on', log_file);
    
    for n_side = 1:2
        
        % get current body side
        [sign_side , cur_side] = bodySide2Sign(sides{n_side});
        
        % cell array with the bone geometries that you would like to process
        bones_list = {...
            'pelvis_no_sacrum',  ...
            ['femur_', cur_side],...
            ['tibia_', cur_side], ...
            ['talus_', cur_side],...
            ['calcn_', cur_side]};

        % model and model file naming
        cur_model_name = ['auto_',datasets{n_d},'_',upper(cur_side)];
        model_file_name = [cur_model_name, '.osim'];
        
        % create geometry set structure for all 3D bone geometries in the dataset
        triGeom_set = createTriGeomSet(bones_list, tri_folder);
        
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
        [JCS, BL, CS] = processTriGeomBoneSet(triGeom_set, cur_side, [],'Kai2014');
        
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
        osim_model_file = fullfile(output_models_folder, model_file_name);
        osimModel.print(osim_model_file);
        
        % inform the user about time employed to create the model
        disp('-------------------------')
        disp(['Model generated in ', sprintf('%.1f', toc), ' s']);
        disp(['Saved as ', osim_model_file,'.']);
        disp(['Model geometries saved in folder: ', geometry_folder_path,'.'])
        disp('-------------------------')
        clear triGeom_set JCS BL CS
        
        % store model file (with path) for merging
        osim_model_set(n_side) = {osim_model_file}; %#ok<SAGROW>
    end
    % merge the two sides
    merged_model_file = fullfile(output_models_folder,[cur_dataset,'_bilateral.osim']);
    mergeOpenSimModels(osim_model_set{1}, osim_model_set{2}, merged_model_file);
    
    % stop logger
    logConsolePrintout('off');
end
% remove paths
rmpath(genpath('STAPLE'));
%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% This example demonstrates how to setup a simple STAPLE workflow to 
% automatically create a model of the ankle joint from the JIA-MRI-ANKLE
% dataset included in the bone_datasets folder.
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('STAPLE'));

%----------%
% SETTINGS %
%----------%
% set output folder
output_models_folder = 'opensim_models';

% set output model name
output_model_file_name = 'example_ankle_joint.osim';

% folder where the various datasets (and their geometries) are located.
datasets_folder = 'bone_datasets';

% dataset(s) that you would like to process specified as cell array. 
% If you add multiple datasets they will be batched processed but you will
% have to adapt the folder and file namings below.
dataset_set = {'JIA_ANKLE_MRI'};

% cell array with the name of the bone geometries to process
bones_list = {'tibia_r','talus_r','calcn_r'};

% format of visualization geometry (obj preferred - smaller files)
vis_geom_format = 'obj';

% choose the definition of the joint coordinate systems (see documentation)
method = 'auto';
%--------------------------------------


% create model folder if required
if ~isfolder(output_models_folder); mkdir(output_models_folder); end

% setup for batch processing
for n_d = 1:numel(dataset_set)
    
    % dataset id used to name OpenSim model and setup folders
    cur_dataset = dataset_set{n_d};
    
    % model name
    model_name = [dataset_set{n_d},'_auto'];
    
    % folder including the bone geometries in MATLAB format (triangulations)
    tri_folder = fullfile(datasets_folder, cur_dataset,'tri');
    
    % create TriGeomSet structure for the specified geometries
    geom_set = createTriGeomSet(bones_list, tri_folder);
    
    % create bone geometry folder for visualization
    % geometry_folder_name = [cur_dataset, '_Geometry'];
    geometry_folder_name = 'example_ankle_joint_Geometry';
    geometry_folder_path = fullfile(output_models_folder,geometry_folder_name);
    writeModelGeometriesFolder(geom_set, geometry_folder_path, vis_geom_format);
    
    % initialize OpenSim model
    osimModel = initializeOpenSimModel(model_name);
    
    % create bodies
    osimModel = addBodiesFromTriGeomBoneSet(osimModel, geom_set, geometry_folder_name, vis_geom_format);
    
    % process bone geometries (compute joint parameters and identify markers)
    [JCS, BL, CS] = processTriGeomBoneSet(geom_set, 'r');
    
    %-----------------------------------
    % SPECIAL SECTION FOR PARTIAL MODELS
    %-----------------------------------
    % Using Kai2014 on the proximal tibia identifies the largest section
    % (near the ankle joint). Importantly, the reference system is aligned
    % with the principal components of the geometry, so roughly with the
    % section of the tibial shaft available. Being the largest section of
    % tibia distal, the Y axis points downwards, and needs to be inverted.
    % You can read the description of Kai_tibia algorithm in:
    % Kai, Shin, et al. Journal of biomechanics 47.5 (2014): 1229-1233.
    % https://doi.org/10.1016/j.jbiomech.2013.12.013
    JCS.tibia_r.knee_r.V(:,2) = -JCS.tibia_r.knee_r.V(:,2);
    % Z axis is ok, as based on the detection of fibula.
    % X axis needs to be inverted
    JCS.tibia_r.knee_r.V(:,1) = normalizeV(cross(JCS.tibia_r.knee_r.V(:,2), JCS.tibia_r.knee_r.V(:,3)));
    % creating an ad hoc body and joint for connecting with ground
    JCS.proxbody.free_to_ground.child = 'tibia_r';
    % bone geometries are in mm, but model parameters will be in m
    JCS.proxbody.free_to_ground.child_location = CS.tibia_r.Origin/1000;
    % using computeXYZAngleSeq to transform the rotation matrix in OpenSim
    % joint orientation.
    JCS.proxbody.free_to_ground.child_orientation = computeXYZAngleSeq(JCS.tibia_r.knee_r.V);
    %----------------------------------------------------------------------
    
    % create joints
    createLowerLimbJoints(osimModel, JCS, method);
    
    %----------------------------------
    % SPECIAL PART FOR PARTIAL MODELS
    %----------------------------------
    % remove markers found by Kai2014 at the tibia, as they will be
    % incorrect.
    BL = rmfield(BL,'tibia_r');
    % add markers to the bones.
    %---------
    % WARNING
    %---------
    % Please note that due to the scan position of the foot, the
    % landmarking in this example is below standard quality.
    % The markers are added nevertheless to demonstrate the procedure.
    addBoneLandmarksAsMarkers(osimModel, BL);
    %-----------------------------------

    % finalize connections
    osimModel.finalizeConnections();
    
    % print OpenSim model
    osimModel.print(fullfile(output_models_folder, output_model_file_name));
    
    % inform the user about time employed to create the model
    disp('-------------------------')
    disp(['Model generated in ', num2str(toc)]);
    disp(['Model file save as: ', fullfile(output_models_folder, output_model_file_name),'.']);
    disp(['Model geometries saved in folder: ', geometry_folder_path,'.'])
    disp('-------------------------')
end

% remove paths
rmpath(genpath('msk-STAPLE/STAPLE'));
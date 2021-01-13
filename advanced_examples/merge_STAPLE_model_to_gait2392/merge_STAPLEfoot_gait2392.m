%-------------------------------------------------------------------------%
%    Author:   Luca Modenese,  2021                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
%    Copyright (c) 2020 Modenese L.                                       %
% ----------------------------------------------------------------------- %
% DESCRIPTION
% This script demonstrates how to merge a partial STAPLE model with a 
% generic lower limb model, in this case the popular gait2392.osim model.
% The script joins the models using a CustomJoint to allow for manual
% adjustment, but other joints, e.g. a WeldJoint, can be easily used.
% ----------------------------------------------------------------------- %
clear; clc

% import libraries
import org.opensim.modeling.*
addpath(genpath('../../STAPLE'))

%----------%
% SETTINGS %
%----------%
% generic model to use as baseline model
generic_osimModel_file = 'gait2392_scaled_0.82.osim';
% STAPLE generated modelthat we want to merge with the generic baseline
MRI_osimModel_file = 'example_auto2020_ankle_R.osim';
%-----------------------------------------------

% let's copy the geometries (avoids duplicate geometries in the repository)
geom_folder = '../../bone_datasets/JIA_ANKLE_MRI/tri';
geom_set =  {'tibia_r', 'calcn_r', 'talus_r', 'toes_r'};
ankle_geom_folder = 'example_auto2020_ankle_R_Geometry';
if ~isfolder(ankle_geom_folder); mkdir(ankle_geom_folder);end
for nt = 1:length(geom_set)
    % load triangulation
    load(fullfile(geom_folder, geom_set{nt}))
    % write obj file
    writeOBJfile(reduceTriObjGeometry(triang_geom, 0.3),...
                 fullfile(ankle_geom_folder, [geom_set{nt},'.obj']));
    clear triang_geom
end

% setup a log
logConsolePrintout('on', 'merge_example.log');

% reading the models
generic_osimModel = Model(generic_osimModel_file);
STAPLE_osimModel  = Model(MRI_osimModel_file);

% there would be two segments named tibia_r if we were merging the models:
% let's rename the tibia segment on the STAPLE model
renameBodyAndAdjustOpenSimModel(STAPLE_osimModel, 'tibia_r', 'tibia_MRI_r');

% The ankle parent frame of the generic model will be the parent frame of 
% the joint connecting the two models.
generic_ankle_parent_frame = generic_osimModel.getJointSet().get('ankle_r').get_frames(0);

% read the STAPLE model JointSet
STAPLE_jointSet = STAPLE_osimModel.getJointSet();
% the MRI/STAPLE model will attach to the generic ankle joint parent using:
% the location of the ankle joint in the STAPLE model (ankle parent frame)
MRI_ankle_child_frame = STAPLE_jointSet.get('ankle_r').get_frames(0);
% the orientation of the child frame of the partial tibia, which is aligned
% with the inertial axis (ground_tibia child frame)
MRI_weld_child_frame = STAPLE_jointSet.get('ground_tibia_r').get_frames(1);

% definition of a CustomJoint for merging the two models
JointParamsStruct.jointName          = 'merge_joint';
JointParamsStruct.parentName         = 'tibia_r';
JointParamsStruct.childName          = 'tibia_MRI_r';
JointParamsStruct.coordsNames        = {'merge_adj_transY', 'merge_adj_rotZ'};
JointParamsStruct.coordsTypes        = {'translational', 'rotational'};
JointParamsStruct.rotationAxes       = 'zxy';
JointParamsStruct.translationAxes    = 'yxz';
JointParamsStruct.coordRanges        = {[-0.3 0.3], [-15 15]};
JointParamsStruct.parent_location    = osimVec3ToArray(generic_ankle_parent_frame.get_translation);
JointParamsStruct.parent_orientation = osimVec3ToArray(generic_ankle_parent_frame.get_orientation);
JointParamsStruct.child_location     = osimVec3ToArray(MRI_ankle_child_frame.get_translation);
JointParamsStruct.child_orientation  = osimVec3ToArray(MRI_weld_child_frame.get_orientation);

% Now we remove bodies from the models so that we can merge them and
% connect their multibody tree. Since we are altering the models, it was
% necessary to retrieve the information for building the CustomJoint before
% this step.

% remove everything below the ankle in the generic model
listOfBodiesToRemove = {'talus_r', 'calcn_r', 'toes_r'};
generic_osimModel = reduceOpenSimModel(generic_osimModel, listOfBodiesToRemove);

% remove references to ground from the MRI ankle model (ground_tibia_r joint)
listOfBodiesToRemove = {'ground'};
STAPLE_osimModel = reduceOpenSimModel(STAPLE_osimModel, listOfBodiesToRemove);

% merge the two existing models: note that the bodies tibia_r and tibia_MRI_r
% are NOT connected by a joint at this stage.
% Note that generic_model is now the merged model
mergeOpenSimModels(generic_osimModel, STAPLE_osimModel);

% create the CustomJoint defined above: tibia_r and tibia_MRI_r will be
% connected once we finaliseConnections()
createCustomJointFromStruct(generic_osimModel, JointParamsStruct);

% change name of the model
generic_osimModel.setName('merged_STAPLEfoot_gait2392');

% finalise connections and print
generic_osimModel.finalizeConnections();

% print model
generic_osimModel.print('output_STAPLEfoot+gait2392.osim');

% log off
logConsolePrintout('off')

rmpath(genpath('../../STAPLE'))
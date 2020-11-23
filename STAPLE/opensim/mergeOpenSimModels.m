% MERGEOSIMMODELS Merge two specified OpenSim models and print the
% resulting model in the specified file. The BodySets, JointSets and
% MarkerSets of the models are merged to generate the mergedOsimModel that
% will be printed.
%
% mergeOpenSimModels(baseOsimModel_file, osimModelToMerge_file, mergedOsimModel_file)
%
% Inputs:
%   baseOsimModel_file - name (including path) of the base model of the
%       merging operation. The model file will be read using the OpenSim API.
%
%   osimModelToMerge_file - name (including path) of the OpenSim model to 
%       merge with baseOsimModel. The model file will be read using the 
%       OpenSim API.
%
%   mergedOsimModel_file - name (including path) of the file in which the
%       merged OpenSim model will be saved.
%
% Outputs:
%   None - a merged model is printed.
%
% See also MERGEOPENSIMSETS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function mergeOpenSimModels(baseOsimModel_file, osimModelToMerge_file, mergedOsimModel_file)

% import libraries
import org.opensim.modeling.*

% read the model files
baseOsimModel    = Model(baseOsimModel_file);
osimModelToMerge = Model(osimModelToMerge_file);

% inform user
disp('---------------------');
disp('   MERGING MODELS    ');
disp('---------------------');
disp(['Base    model: ', baseOsimModel_file]);
disp(['Merging model: ', osimModelToMerge_file]);
disp('---------------------');

disp('Updating BodySet:')
baseBodySet = baseOsimModel.getBodySet();
mergeBodySet = osimModelToMerge.getBodySet();
mergeOpenSimSets(baseBodySet, mergeBodySet);

disp('Updating JointSet:')
baseJointSet = baseOsimModel.getJointSet();
mergeJointSet = osimModelToMerge.getJointSet();
mergeOpenSimSets(baseJointSet, mergeJointSet);

disp('Updating MarkerSet:')
baseMarkerSet = baseOsimModel.getMarkerSet();
mergeMarkerSet = osimModelToMerge.getMarkerSet();
mergeOpenSimSets(baseMarkerSet, mergeMarkerSet);
disp('Done.')

% write final model
baseOsimModel.print(mergedOsimModel_file);
disp('-------------------------')
disp(['Merged model saved as ', mergedOsimModel_file,'.']);
disp('-------------------------')
%% TEST: paper models
clearvars;  close all

% import opensim libraries
import org.opensim.modeling.*
addpath(genpath('../STAPLE'));
addpath(genpath('../STAPLE/sandbox'));


% set folders
models_folder = '../opensim_models_examples';
ref_models_folder = './ref_models/bilateral';

% compare models with reference ones
assert(compareModelsInFolders(models_folder, ref_models_folder, 0)==1)
disp('------------')
disp('Test passed.')

rmpath(genpath('../STAPLE'));

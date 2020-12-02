%% TEST: paper models
clearvars;  close all

% import opensim libraries
import org.opensim.modeling.*
addpath(genpath('../STAPLE'));
addpath(genpath('../STAPLE/sandbox'));

% create all partial models
run('../Example_hip_model.m');
run('../Example_knee_model.m');
run('../Example_ankle_model.m');

% set folders
models_folder = '../opensim_models';
ref_models_folder = './ref_models/partial';

% compare models with reference ones
compareModelsInFolders(models_folder, ref_models_folder, 0)

rmpath(genpath('../STAPLE'));

disp('------------')
disp('Test passed.')
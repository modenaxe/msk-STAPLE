%-------------------------------------------------------------------------%
% Copyright (c) 2021 Modenese L.                                          %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
%% TEST: paper models
clearvars;  close all

addpath('./support_funcs');

% create all partial models
% run('../Example_hip_model.m');
% run('../Example_knee_model.m');
% run('../Example_ankle_model.m');

% set folders
models_folder = '../opensim_models_examples';
ref_models_folder = './ref_models/partial';

% compare models with reference ones
tol = 0.000001; table_on = 0;
assert(compareModelsInFolders(models_folder, ref_models_folder, tol, table_on)==1)
disp('------------')
disp('Test passed.')

rmpath('./support_funcs');


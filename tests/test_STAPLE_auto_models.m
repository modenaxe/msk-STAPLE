%-------------------------------------------------------------------------%
% Copyright (c) 2021 Modenese L.                                          %
%    Author: Luca Modenese                                                %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
% Test that checks if the model built using the current version of STAPLE
% are identical, within a tolerance, to those created for the 2020 paper.
% the models are built using the Modenese2018 joints definition.
% ----------------------------------------------------------------------- %

%% TEST: paper models
clearvars;  close all
addpath('./support_funcs');

% create models as in the paper (assumes examples have not been run)
% run('../Example_create_kinetic_models.m');

% where the model created using the current version of STAPLE are (created
% with the previous run(../Example...)
models_folder = '../opensim_models_JBiomech';

% where the models created for the paper have been stored
ref_models_folder = 'ref_models/paper';

% compare models with reference ones
tol = 0.000001; table_on = 0;
assert(compareModelsInFolders(models_folder, ref_models_folder, tol, table_on)==1)
disp('------------')
disp('Test passed.')

rmpath('./support_funcs');
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
models_folder = '../opensim_models_bioRxiv';

% where the models created for the paper have been stored
ref_models_folder = 'ref_models/paper';

% compare models with reference ones
assert(compareModelsInFolders(models_folder, ref_models_folder, 0)==1)
disp('------------')
disp('Test passed.')

rmpath('./support_funcs');
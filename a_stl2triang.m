%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% This script should be run after a dataset of stl geometries has been
% refined and has the purposes of reducing the size of files for storage
% and distribution, e.g. in GitHub.
% ----------------------------------------------------------------------- %

clear; clc
addpath(genpath('./GIBOK-toolbox'))
%---------------- USER'S SETTINGS ------------------
% folder where to look for STL files
% stl_folder = './test_geometries/LHDL_CT';
% stl_folder = './test_geometries/TLEM2_CT';
% stl_folder = './test_geometries/P0_MRI';
% stl_folder = './test_geometries/TLEM2_MRI';
stl_folder = './test_geometries/LHDL_CT_iso';
stl_folder = './test_geometries/JIA_CSm6';
% stl_folder = './test_geometries/P0_MRI_smooth';
% folder where to store the resulting triangulations
triang_folder = '';
%---------------------------------------------------

% if triang_folder unspecified, then it is set to stl_folder plus '_tri'
if isempty(triang_folder) || strcmp(triang_folder,'')
    triang_folder = [stl_folder, '_tri'];
end

% check if triang folder exists, if it doesn't create it
if ~isdir(triang_folder);    mkdir(triang_folder);  end

% getting list of stl files from the specified folder
list_of_stl = dir([stl_folder, filesep, '*.stl']);

% number of trials N
N_stl = size(list_of_stl,1); 

% looping through all the stl files found in folder
for n = 1:N_stl
    
    % check if directory is empty
    if isempty(list_of_stl)==1
        error(['There are no stl geometry files in specified folder: ',stl_folder]);
    end
    
    % read in stl file
    curr_stl_name = list_of_stl(n).name;
    [~, name, ext] = fileparts(curr_stl_name);
    disp('-------------------')
    disp(['GEOMETRY ', curr_stl_name, ' (', num2str(n),'/',num2str(N_stl),')'])
    disp('-------------------')
    disp(['Processing file     : ', fullfile(stl_folder, curr_stl_name)]);
    
    % transform it in triangulation
    curr_triang = ReadMesh(fullfile(stl_folder, curr_stl_name));
    
    % save it as triangulation matlab file in specified folder
    curr_triang_name = [name, '.mat'];
    curr_triang_file = fullfile(triang_folder, curr_triang_name);
    disp(['Saving triangulation: ', fullfile(triang_folder, curr_triang_name)]);
    triang_geom = curr_triang;
    save(curr_triang_file,  'triang_geom')
end
% nice final print
disp('-------------------')
disp('DONE')
% remove paths
rmpath(genpath('./GIBOK-toolbox'));
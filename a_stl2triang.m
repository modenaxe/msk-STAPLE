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
addpath('./GIBOK-toolbox/SubFunctions')
%---------------- USER'S SETTINGS ------------------
% folder where to look for STL files
stl_folder = './test_geometries/MRI_P0';
% folder where to store the resulting traingulations
triang_folder = './test_geometries/MRI_P0_triang';
%---------------------------------------------------

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
    disp(['GEOMETRY ',num2str(n),'/',num2str(N_stl)])
    disp('-------------------')
    disp(['Processing file: ', curr_stl_name, ' in folder ', stl_folder]);
    
    % transform it in triangulation
    curr_triang = ReadMesh(fullfile(stl_folder, curr_stl_name));
    
    % save it as triangulation matlab file in specified folder
    curr_triang_name = [name, '.mat'];
    curr_triang_file = fullfile(triang_folder, curr_triang_name);
    disp(['Saving triangulation ', curr_triang_name, ' in folder ', triang_folder]);
    save(curr_triang_file,  'curr_triang')
end
disp('DONE')
% remove paths
rmpath('./GIBOK-toolbox/SubFunctions')
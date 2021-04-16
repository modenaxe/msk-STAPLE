%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% This script should be run when the bone geometries stored as MATLAB file
% are desired as STL files. It converts the triangulation objects stored as
% the .mat files (minimal size) as binary STL files (larger but usable in
% software like MeshLab or NMSBuilder).
% ----------------------------------------------------------------------- %
clear; clc
addpath(genpath('./STAPLE'))

%---------------- USER'S SETTINGS ------------------
% folder where to look for triangulation files
dataset_name = 'TLEM2_CT';

% main dataset folder for bone geometries
dataset_folder = ['./bone_datasets',filesep, dataset_name];

% folder where to store the resulting triangulations
stl_out_folder = [dataset_folder, filesep, 'stl'];
%---------------------------------------------------

% if triang_folder unspecified, then it is set to stl_folder plus '_tri'
if isempty(stl_out_folder) || strcmp(stl_out_folder,'')
    stl_out_folder = [dataset_folder, filesep, 'stl'];
end

% check if triang folder exists, if it doesn't then create it
if ~isfolder(stl_out_folder); mkdir(stl_out_folder);  end

% getting list of stl files from the specified folder
tri_input_folder = fullfile(dataset_folder, 'tri');
list_of_tri = dir([tri_input_folder, filesep, '*.mat']);

% total number of stl files
N_tri = size(list_of_tri,1); 

% looping through all the stl files found in folder
for n = 1:N_tri
    
    % check if directory is empty
    if isempty(list_of_tri)==1
        error(['There are no tri geometry files in specified folder: ',tri_input_folder]);
    end
    
    % read in stl file
    curr_tri_name = list_of_tri(n).name;
    [~, name, ext] = fileparts(curr_tri_name);
    disp('-------------------')
    disp(['GEOMETRY ', curr_tri_name, ' (', num2str(n),'/',num2str(N_tri),')'])
    disp('-------------------')
    disp(['Processing file     : ', fullfile(tri_input_folder, curr_tri_name)]);
    
    % read traingulation
    temp_tri = load(fullfile(tri_input_folder, curr_tri_name));
    
    % standardize name for triangulation
    tri_field_name = fields(temp_tri);
    triang_geom = temp_tri.(tri_field_name{1});
    
    % save it as triangulation matlab file in specified folder
    curr_stl_name = [name, '.stl'];
    curr_triang_file = fullfile(stl_out_folder, curr_stl_name);
    disp(['Saving triangulation as STL: ', fullfile(stl_out_folder, curr_stl_name)]);
    stlwrite(triang_geom, curr_triang_file)
end

% final print
disp('-------------------')
disp('DONE')

% remove paths
rmpath(genpath('./STAPLE'))

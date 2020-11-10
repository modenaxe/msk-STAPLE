%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
%
% Script that allows to specify scripts to apply to one or more meshes to
% be selected manually.
%
% =================== INSTRUCTIONS FROM MESHLABSERVER =====================
% using meshlab server
% Usage:
%     meshlabserver arg1 arg2 ...
% where args can be:
%  -i [filename...]  mesh(s) that has to be loaded
%  -o [filename...]  mesh(s) where to write the result(s)
%  -s filename                script to be applied
%  -d filename       dump on a text file a list of all the filtering fucntion
%  -l filename       the log of the filters is ouput on a file
%  -om options       data to save in the output files: vc -> vertex colors, vf ->
% vertex flags, vq -> vertex quality, vn-> vertex normals, vt -> vertex texture co
% ords,  fc -> face colors, ff -> face flags, fq -> face quality, fn-> face normal
% s,  wc -> wedge colors, wn-> wedge normals, wt -> wedge texture coords
% Example:
%         'meshlabserver -i input.obj -o output.ply -s meshclean.mlx -om vc fq wn'
%
%
% Notes:
%
% There can be multiple meshes loaded and the order they are listed matters because
% filters that use meshes as parameters choose the mesh based on the order.
% The number of output meshes must be either one or equal to the number of input meshes.
% If the number of output meshes is one then only the first mesh in the input list
%  is saved.
% The format of the output mesh is guessed by the used extension.
% Script is optional and must be in the format saved by MeshLab.
% =========================================================================
% first version 2015

clear
clc
% select one or more meshes to elaborate
[input_mesh_set, PATHNAME, FILTERINDEX] = uigetfile('.stl', 'Please select a mesh to process','MultiSelect','on');
% scripts specifying the filters to be applied to the loaded meshes
Meshlab_script_set = {  './MeshLab_scripts/Cleaning_Filters.mlx',...
                        './MeshLab_scripts/Poisson_Pass1.mlx',...
                        './MeshLab_scripts/Poisson_Pass2.mlx',...
                        './MeshLab_scripts/Poisson_Pass3.mlx'};
% names that will be associated to the meshes saved after applying the
% filters
Meshlab_script_names_set = {'clean','Poisson1','Poisson2','Poisson3'};

% another possibility for development: just choose a directory 
% [DIRECTORYNAME] = uigetdir('.', 'Please select a folder containing mesh to process');
% mesh_dir = dir([DIRECTORYNAME,'/*stl']);
% input_mesh_set = mesh_dir.name()

% calculating how many meshes will be processed
if iscell(input_mesh_set)
    N_proc = size(input_mesh_set,2);
else
    N_proc = 1;
end
% number of scripts to run
N_scripts = size(Meshlab_script_set,2);

for n_mesh = 1:N_proc
    
    % read name of current mesh
    if iscell(input_mesh_set)
        input_mesh = input_mesh_set{1,n_mesh};
    else
        input_mesh = input_mesh_set;
    end
    
    % get just name - no extension
    [~, input_mesh_name,~] = fileparts(input_mesh);
    display('     ');
    display('------------------------------------------')
    display(['Processing mesh: ',input_mesh_name])
    display('------------------------------------------')
    input_mesh = fullfile(PATHNAME, input_mesh);
    
    for n_script = 1:N_scripts
        % current script
        curr_script = Meshlab_script_set{n_script}; 
        % extension for mesh file saved after applying it
        curr_script_name = Meshlab_script_names_set{n_script};
        % current input mesh
        output_mesh = fullfile(PATHNAME,[input_mesh_name,'_',curr_script_name,'.stl']);
        % informing the user about the filter being applied
        display(['Applying script ', num2str(n_script),'/',num2str(N_scripts),': ',curr_script_name]);
        % run MeshLab server
        [status,cmdout] = runMeshLabScript(input_mesh, output_mesh, curr_script);
        % write log
        id = fopen(fullfile(PATHNAME,[input_mesh_name,'_',curr_script_name,'.log']),'w+');
        fprintf(id,'%s',id,cmdout);
        fclose(id);
        % updating the input mesh for consequential applications
        input_mesh = output_mesh;
    end
    
    % End message
    display(['Written final mesh: ',output_mesh,' in folder ',PATHNAME])
    %       plot
    %     [v, f, n, c, stltitle] = stlread(output_mesh);
    %     patch('Faces',f,'Vertices',v,'FaceVertexCData',c); axis equal, grid on; hold on
    
end


% LOAD_MESH Read a file, with specified or unspecified extension, as a
% three-dimensional surface mesh file. The script guesses the triangulation
% format when it is not specified, attempting to open the file as a 
% STL or MATLAB file.
%
%   tri_geom = LOAD_MESH(a_tri_mesh_file)
%
% Inputs:
%   a_tri_mesh_file - a file path to a surface mesh, with extension .STL,
%       .MAT or no extension.
%
% Outputs:
%   tri_geom - a MATLAB triangulation object.
%
%
% See also CREATETRIGEOMSET
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese, 2020
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
%
% TODO: add OBJ reading

function tri_geom = load_mesh(a_tri_mesh_file)

disp(['Attempting to read mesh file: ', a_tri_mesh_file]);

tri_geom = [];

% check if there is a file that could be opened adding extension
if ~(exist(a_tri_mesh_file,'file')==2 || exist([a_tri_mesh_file,'.mat'],'file')==2 || exist([a_tri_mesh_file,'.stl'],'file')==2)
    disp([a_tri_mesh_file,' geometry not available.']);
    return
end

if ischar(a_tri_mesh_file)
    % get extension
    [~,~,ext] = fileparts(a_tri_mesh_file);
    % if stl file just open it
    if strcmp(ext,'.stl')
        % NB: these two lines could be just stlread for MATLAB>R2018b
        [Nodes, Elmts] = stlRead(a_tri_mesh_file);
        tri_geom = triangulation(Elmts,Nodes);
        kwd = 'STL';
        % if matlab file just open it
    elseif strcmp(ext,'.mat')
        geom = load(a_tri_mesh_file);
        str_name = fields(geom);
        tri_geom = geom.(str_name{1});
        kwd = 'MATLAB';
    % if does not have extension try to open as MATLAB file
    elseif isempty(ext)
        try
            geom = load(a_tri_mesh_file);
            str_name = fields(geom);
            tri_geom = geom.(str_name{1});
            kwd = 'MATLAB';
        catch
            % if does not have extension try to open as stl file
            [Nodes, Elmts] = stlRead([a_tri_mesh_file,'.stl']);
            tri_geom = triangulation(Elmts,Nodes); 
            kwd = 'STL';
        end
    end
end

if isempty(tri_geom)
    error([a_tri_mesh_file, ' could not be read. Please double check inputs.'])
else
	disp(['...read as ', kwd, ' file.'])
end

end
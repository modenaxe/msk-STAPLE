%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% Script used to read a file, with specified or unspecified extension, as a
% three-dimensional mesh file. 
% The script tries to guess the triangulation format is not specified,
% trying to open the file as a STL or MATLAB file.
% ----------------------------------------------------------------------- %
function tri_geom = load_mesh(a_tri_mesh_file)

disp(['Attempting to read mesh file: ', a_tri_mesh_file]);

% check if there is a file that could be opened adding
if ~(exist(a_tri_mesh_file,'file')==2 || exist([a_tri_mesh_file,'.mat'],'file')==2 || exist([a_tri_mesh_file,'.stl'],'file')==2)
    disp([a_tri_mesh_file,' geometry not available.']);
    return
end

if ischar(a_tri_mesh_file)
    % get extension
    [~,~,ext] = fileparts(a_tri_mesh_file);
    % if stl file just open it
    if strcmp(ext,'.stl')
        % NB: these two lines could be just stlread for MATLAB>v2020
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

disp(['...read as ', kwd, ' file.'])
end
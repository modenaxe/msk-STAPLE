% CREATETRIGEOMSET Create a structure of triangulation objects from a list
% of files and the folder where those files are located
%
%   triGeomSet = createTriGeomSet(aTriGeomList, geom_file_folder)
%
% Inputs:
%   aTriGeomList - a cell array consisting of a list of names of
%       triangulated geometries that will be seeked in geom_file_folder.
%       The names set the name of the triangulated objects and should
%       correspond to the names of the bones to include in the OpenSim
%       models.
%
%   geom_file_folder - the folder where triangulated geometry files will be
%       seeked.
%
% Outputs:
%   triGeomSet - structure with as many fields as the triangulations that
%       could be loaded from the aTriGeomList from the geom_file_folder.
%       Each field correspond to a triangulated geometry.
%
% Example of use:
% tri_folder = 'test_geometries\dataset1\tri';
% bones_list = {'pelvis','femur_r','tibia_r','talus_r','calcn_r'};
% geom_set = createTriGeomSet(bones_list, tri_folder);
%
% See also LOAD_MESH
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function triGeomSet = createTriGeomSet(aTriGeomList, geom_file_folder)

disp('--------------------------------')
disp('Creating set of triangulations' )
disp('--------------------------------')

tic
disp(['Reading geometries from folder: ', geom_file_folder]);
triGeomSet = [];
for nb = 1:numel(aTriGeomList)
    cur_tri_name = aTriGeomList{nb};
    cur_tri_geom_file = fullfile(geom_file_folder, cur_tri_name);
    cur_tri_geom = load_mesh(cur_tri_geom_file);
    if isempty(cur_tri_geom)
        % skip building the field if there was no geometry
        continue
    else
        triGeomSet.(cur_tri_name) = cur_tri_geom;
    end
end
if isempty(triGeomSet)
    error('createTriGeomSet.m No triangulations were read in input.')
else
    % tell user all went well
    disp(['Set of triangulated geometries created in ', sprintf('%.1f', toc), ' s']);
end
end
%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% This script should be run after a dataset of stl geometries has been
% refined and has the purposes of reducing the size of files for storage
% and distribution, e.g. in GitHub.
% ----------------------------------------------------------------------- %
function osimModel = createBodiesFromBoneGeometries(geom_set, vis_geom_folder, vis_geom_format, bone_density, in_mm)

% add OpenSim libraries
import org.opensim.modeling.*

% adjust dimensional factors based on mm / m scales
if nargin<5;     in_mm = 1; end
% default geometry
if nargin<3; vis_geom_format = '.vtp';end
% default density values from Dumas et al 2005.
if nargin<4
    if in_mm==1
        bone_density = 0.000001420;%kg/mm3
    else
        bone_density = 1420;%kg/m3
    end
end

% create the model
osimModel = Model();

% set gravity
osimModel.setGravity(Vec3(0, -9.8081, 0));

% create the bodies
body_list = fields(geom_set);
Nb = numel(body_list);
for nb = 1:Nb
    % bone being processed
    cur_body_name = body_list{nb};
    % geometry file used for visualisation
    cur_vis_geom_file = fullfile(vis_geom_folder, [cur_body_name,vis_geom_format]);
    % triangulation used for computations
    cur_geom = geom_set.(cur_body_name);
    % correct names before naming the opensim model bodies
    if strcmp(cur_body_name,'pelvis_no_sacrum')
        cur_body_name = 'pelvis';
    end
    % creating the body and adding it to the OpenSim model
    addTriGeomBody(osimModel, cur_body_name, cur_geom, bone_density, in_mm, cur_vis_geom_file);
end

end

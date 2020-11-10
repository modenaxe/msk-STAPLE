% ADDBODIESFROMTRIGEOMBONESET Create a body for each triangulation
% object in the provided geom_set structure. These bodies are added to the  
% specified OpenSim model. A density for computing the mass properties and
% a details of the visualization folder can also be provided.
% NOTE: the added bodies are not yet connected by appropriate joints, so
% unless this function is used in a workflow including 
% createLowerLimbJoints or joint definition, the resulting OpenSim model
% will consist of bodies connected to ground.
%
%   osimModel = addBodiesFromTriGeomBoneSet(osimModel, geom_set,...
%                                           vis_geom_folder, vis_geom_format,...
%                                           body_density, in_mm)
%
% Inputs:
%   osimModel - an OpenSim model to which the bodies created from
%       triangulation objects will be added.
%
%   geom_set - a set of MATLAB triangulation objects, normally created
%       using the function createTriGeomSet. See that function for more
%       details.
%
%   vis_geom_folder - the folder where the geometry files used to
%       visualised the OpenSim model will be stored.
%
%   vis_geom_format - the format used to write the geometry files employed
%       by the OpenSim model for visualization.
%
%   body_density - (optional) the density assigned to the triangulation
%       objects when computing the mass properties. Default value is 1420
%       Kg/m^3, which is the density assigned to bone in Dumas et al. 
%       IEEE Transactions on Biomedical engineering (2005). In the
%       generation of automatic lower extremity models this value is
%       overwritten by mass properties estimated through regression
%       equations. The purpose of computing them is to provide a reasonable
%       first estimate
%       
%   in_mm - (optional) indicates if the provided geometries are given in mm
%       (value: 1) or m (value: 0). Please note that all tests and analyses
%       done so far were performed on geometries expressed in mm, so this
%       option is more a placeholder for future adjustments.
%
% Outputs:
%   osimModel - the OpenSim model provided as input updated to include the
%       bodies defined from the triangulation objects.
%
% See also ADDBODYFROMTRIGEOMOBJ, CREATETRIGEOMSET.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function osimModel = addBodiesFromTriGeomBoneSet(osimModel,...
                                                 geom_set,...
                                                 vis_geom_folder,...
                                                 vis_geom_format,...
                                                 body_density,...
                                                 in_mm)

% add OpenSim libraries
import org.opensim.modeling.*

% defaults and dimensional scales
if nargin<4; vis_geom_format = 'obj';end
if nargin<6; in_mm = 1; end
if in_mm == 1; dim_fact = 0.001; else; dim_fact = 1; end
if nargin<5; body_density = 1420*dim_fact;end % bone density by default (Dumas 2005)

% add the individual bodies to the model
body_list = fields(geom_set);
Nb = numel(body_list);

disp('-------------------------------------')
disp(['Adding ', num2str(Nb), ' bodies to the OpenSim model'])

for nb = 1:Nb
    % bone being processed
    cur_body_name = body_list{nb};
    % geometry file used for visualisation
    cur_vis_geom_file = fullfile(vis_geom_folder, [cur_body_name,'.',vis_geom_format]);
    % triangulation used for computations
    cur_geom = geom_set.(cur_body_name);
    % TODO: maybe call pelvis even the no_sacrum one?
    % correct pelvis name before naming the opensim model bodies
    if strcmp(cur_body_name,'pelvis_no_sacrum')
        cur_body_name = 'pelvis';
    end
    
    disp(['     ',num2str(nb),') ', cur_body_name])
    
    % creating the body and adding it to the OpenSim model
    addBodyFromTriGeomObj(osimModel, cur_geom, cur_body_name, cur_vis_geom_file, body_density, in_mm);
    disp('      ADDED')
    disp('      -----')
end

end

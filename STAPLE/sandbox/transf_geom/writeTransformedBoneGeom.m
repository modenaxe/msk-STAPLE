% WRITETRANFORMEDBONEGEOM Write a geometry set transforming the
% triangulated objects according to the provided reference systems. The
% transformed triangulations are then stored in a specified folder as STL
% files in binary or ASCII format.
%
%   WRITETRANFORMEDBONEGEOM(geom_set, CS, geometry_folder, stl_format)
%
% Inputs:
%   geom_set - .  
%
%   CS - . 
%
%   geometry_folder - 
%
%   stl_format - .
%
% Outputs:
%   none - files are printed. 
%
% See also CREATETRIGEOMSET, REDUCETRIOBJGEOMETRY.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese, 2020
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

% TODO: rewrite this function to make it consistent with the latest
% pipeline.
function writeTransformedBoneGeom(geom_set, CS, geometry_folder, stl_format)
% by default binary STL
if nargin<4; stl_format='binary';end

geom_names = fields(geom_set);
body_names = fields(CS);
Nf = numel(geom_names);
for nb = 1:Nf
    cur_tri = geom_set.(geom_names{nb});
    cur_CS  = CS.(body_names{nb});
    updtri = TriChangeCS(cur_tri, cur_CS.V, cur_CS.Origin);
    % requires version > R2018b
    try
        stlwrite(updtri, fullfile(geometry_folder, [body_names{nb},'.stl']), stl_format);
    catch
        error('requires ''stlwrite'' function available in MATLAB versions > R2018b');
    end
end
end
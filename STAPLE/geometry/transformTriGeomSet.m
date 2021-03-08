% TRANFORMTRIGEOMSET Write a geometry set transforming the
% triangulated objects according to the provided reference systems. The
% transformed triangulations are then stored in a specified folder as STL
% files in binary or ASCII format.
%
%   updTriGeomSet = TRANFORMTRIGEOMSET(triGeomSet, CoordSystSet)
%
% Inputs:
%   triGeomSet - MATLAB structures containing a triangulation object in
%       each field. The name of the field coincides with the name of a bone
%       in the standard use.
%
%   CoordSystSet - A structure collecting a set of coordinate systems. Each
%       coordinate system is itself a structure with 'Origin' and 'V'
%       fields, indicating the origin and the axis. In 'V', each column is
%       the normalise direction of an axis expressed in the global
%       reference system (CS.V = [x, y, z]).
%
% Outputs:
%   updTriGeomSet - same triangulation objects of triGeomSet transformed
%       according to the CoordSystSet reference systems.
%
% See also CREATETRIGEOMSET, REDUCETRIOBJGEOMETRY.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function updTriGeomSet = transformTriGeomSet(triGeomSet, BCS_set)

geom_names = fields(triGeomSet);
body_names = fields(BCS_set);

% check that the structures of bones and coord syst are compatible
if numel(geom_names)~=numel(body_names)
    error('transformTriGeomSet.m  Error - geometry and coordinate systems elements are not consistent.')
end

% update the triangulation objects
Nf = numel(geom_names);
for nb = 1:Nf
    cur_triGeomName = geom_names{nb};
    curr_body_name  = body_names{nb};
    cur_tri = triGeomSet.(cur_triGeomName);
    cur_CS  = BCS_set.(curr_body_name);
    if strncmp(curr_body_name, cur_triGeomName, length(curr_body_name))
        updTriGeomSet.(cur_triGeomName) = TriChangeCS(cur_tri, cur_CS.V, cur_CS.Origin);
    else
        warning(['Triangulation ',cur_triGeomName,' does not seem to correspond to body ', curr_body_name ]);
    end
end

end
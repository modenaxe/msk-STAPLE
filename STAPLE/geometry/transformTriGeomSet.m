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
%  Author:   Luca Modenese, 2020
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

% TODO: written in train, needs proper testing!

function updTriGeomSet = transformTriGeomSet(triGeomSet, CoordSystSet)

geom_names = fields(triGeomSet);
body_names = fields(CoordSystSet);

% check that the structures of bones and coord syst are compatible
if ~isequal(geom_names, body_names)
    error('transformTriGeomSet.m  Error - geometry and coordinate systems names are not consistent.')
end

% update the triangulation objects
Nf = numel(geom_names);
for nb = 1:Nf
    cur_triGeomName = geom_names{nb};
    cur_tri = triGeomSet.(cur_triGeomName);
    cur_CS  = CoordSystSet.(body_names{nb});
    updTriGeomSet.(cur_triGeomName) = TriChangeCS(cur_tri, cur_CS.V, cur_CS.Origin);
end

end
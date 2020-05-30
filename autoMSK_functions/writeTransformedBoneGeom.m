% write new geometries
function writeProcessedBoneGeom(geom_set, CS, geometry_folder, stl_format)
if nargin<4; stl_format='binary';end
geom_names = fields(geom_set);
body_names = fields(CS);
Nf = numel(geom_names);
for nb = 1:Nf
    cur_tri = geom_set.(geom_names{nb});
    cur_CS  = CS.(body_names{nb});
    updtri = TriChangeCS(cur_tri, cur_CS.V, cur_CS.Origin);
    stlwrite(updtri, fullfile(geometry_folder, [body_names{nb},'.stl']), stl_format);
end
end
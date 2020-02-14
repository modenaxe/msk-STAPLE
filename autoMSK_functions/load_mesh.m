function tri_geom = load_mesh(a_tri_mesh_file)


if ischar(a_tri_mesh_file)
    % try to open it as stl file
    tri_geom = stlRead(a_tri_mesh_file);
    
    if isempty(tri_geom)
        geom = load(a_tri_mesh_file);
        str_name = fields(geom);
        tri_geom = geom.(str_name{1});
    end
end
   

end
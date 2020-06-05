    function triGeomSet = createTriGeomSet(aTriGeomList, geom_file_folder)
    for nb = 1:numel(aTriGeomList)
        cur_tri_name = aTriGeomList{nb};
        cur_tri_geom_file = fullfile(geom_file_folder, cur_tri_name);
        triGeomSet.(cur_tri_name) = load_mesh(cur_tri_geom_file);
    end
    end
function osim_body = addTriGeomBody(osimModel, body_name, geom_file, vis_mesh_file)

% load mesh
geom = load_mesh(geom_file);

% create body using the triangulation for computing the mass properties
osim_body = createBodyFromTriangGeom(geom, body_name, bone_density, in_mm);

% add body to model
osimModel.addBody(osim_body);

% add visualization mesh
if nargin>3
    vis_geom = Mesh(vis_mesh_file);
    vis_geom.set_scale_factors(Vec3(dim_fact));
    osim_body.attachGeometry(vis_geom);
else
    error('Please specify a valid mesh file')
    % return?
    % write stlwrite the Triangulation to a selected folder
end

end
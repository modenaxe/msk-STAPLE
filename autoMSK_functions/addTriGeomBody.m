function osim_body = addTriGeomBody(osimModel, body_name, triGeom, density, in_mm, vis_mesh_file)

% OpenSim libraries
import org.opensim.modeling.*

if in_mm == 1
    dim_fact = 0.001;
else
    % assumed in metres
    dim_fact = 1;
end

% create body using the triangulation for computing the mass properties

% compute mass properties
boneMassProps= calcMassInfo_Mirtich1996(triGeom.Points, triGeom.ConnectivityList);
bone_mass    = boneMassProps.mass * density;
bone_COP     = boneMassProps.COM  * dim_fact;
bone_inertia = boneMassProps.Ivec * density * dim_fact^2.0; 

% create opensim body
osim_body    =  Body( body_name,...
                bone_mass,... 
                ArrayDouble.createVec3(bone_COP),...
                Inertia(bone_inertia(1), bone_inertia(2), bone_inertia(3),...
                        bone_inertia(4), bone_inertia(5), bone_inertia(6))...
               );

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
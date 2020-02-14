function osim_body = createBodyFromTriangGeom(TriGeom, body_name, density, in_mm)
% function assumes density will be provided externally, consistently with
% the dimension of the body and the tissue to represent.
% specifications of dimensions are required for scaling COP and inertia.

% OpenSim libraries
import org.opensim.modeling.*

if in_mm == 1
    dim_fact = 0.001;
else
    % assumed in metres
    dim_fact = 1;
end

% compute mass properties
boneMassProps= calcMassInfo_Mirtich1996(TriGeom.Points, TriGeom.ConnectivityList);
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

end
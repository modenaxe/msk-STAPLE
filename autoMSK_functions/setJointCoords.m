function OSJoint = setJointCoords(OSJoint, struct)

% OpenSim libraries
import org.opensim.modeling.*

% get coordinate set to update
updCoordinates = OSJoint.upd_CoordinateSet();

% creating coordinates
coordsNames = struct.coordsNames;
coordsTypes = struct.coordsTypes;

% number of coords
N = size(coordsNames,2);

for n_c = 1:N
    coord = Coordinate();
    curr_coord_name = coordsNames{n_c};
    coord.setName(curr_coord_name);
    curr_coord_type = coordsTypes{n_c};
    if strcmp(curr_coord_type,'rotational') || strcmp(curr_coord_type,'translational')
        coord.set_motion_type(curr_coord_type);
    else
        error([curr_coord_type,' must be ''rotational'' or ''translational''.']);
    end
    
    % updating the coordinate set
    updCoordinates.cloneAndAppend(coord);
end

end
function addMarkersFromStruct(osimModel, frame_name, MarkerStruct, in_mm)

% OpenSim libraries
import org.opensim.modeling.*

if in_mm == 1; dim_fact = 0.001; else; dim_fact = 1; end

markers_names = fields(MarkerStruct);
N_markers = length(markers_names);
for nm = 1:N_markers
    cur_marker_name = markers_names{nm};
    cur_phys_frame = osimModel.getBodySet.get(frame_name);
    Loc = MarkerStruct.(cur_marker_name)*dim_fact;
    marker = Marker(cur_marker_name,...
                    cur_phys_frame,...
                    Vec3(Loc(1), Loc(2), Loc(3)));
    osimModel.addMarker(marker);
end
end
function addBoneLandmarksAsMarkers(osimModel, BLStruct, in_mm)

% defaults
if nargin<3; in_mm = 1; end
if in_mm == 1; dim_fact = 0.001; else; dim_fact = 1; end

% OpenSim libraries
import org.opensim.modeling.*

% loop through the bodies specified in BLStruct
body_list = fields(BLStruct);
Nb = numel(body_list);
for nb = 1:Nb
    % body name
    cur_body_name = body_list{nb};
    % loop through the markers
    cur_body_markers = BLStruct.(cur_body_name);
    markers_list = fields(cur_body_markers);
    N_markers = numel(markers_list);
    for nm = 1:N_markers
        % define the markers
        cur_marker_name = markers_list{nm};
        cur_phys_frame = osimModel.getBodySet.get(cur_body_name);
        Loc = cur_body_markers.(cur_marker_name)*dim_fact;
        marker = Marker(cur_marker_name,...
            cur_phys_frame,...
            Vec3(Loc(1), Loc(2), Loc(3)));
        % add markers to model
        osimModel.addMarker(marker);
    end
end
end
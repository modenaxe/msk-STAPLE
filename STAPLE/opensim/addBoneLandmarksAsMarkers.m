% ADDBONELANDMARKSASMARKERS Add the bone landmarks listed in the input 
% structure as Markers in the OpenSim model.
%
%   addBoneLandmarksAsMarkers(osimModel, BLStruct, in_mm)
%
% Inputs:
%   osimModel - an OpenSim model (object) to which to add the bony
%       landmarks as markers.
%
%   BLStruct - a MATLAB structure with two layers. The external layer has
%       fields named as the bones, the internal layer as fields named as
%       the bone landmarks to add. The value of the latter fields is a
%       [1x3] vector of the coordinate of the bone landmark. For example:
%       BLStruct.femur_r.RFE = [xp, yp, zp].
%
%   in_mm - if all computations are performed in mm or m. Valid values: 1
%       or 0.
%
% Outputs:
%   none - the OpenSim model in the scope of the calling function will
%       include the specified markers.
%
%
% See also LANDMARKBONEGEOM.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function addBoneLandmarksAsMarkers(osimModel, BLStruct, in_mm)

% defaults
if nargin<3; in_mm = 1; end
if in_mm == 1; dim_fact = 0.001; else; dim_fact = 1; end

% OpenSim classes
import org.opensim.modeling.*

% loop through the bodies specified in BLStruct
body_list = fields(BLStruct);
Nb = numel(body_list);
for nb = 1:Nb
    % body name
    cur_body_name = body_list{nb};
    % check that cur_body_name actually corresponds to a body
    if osimModel.getBodySet().getIndex(cur_body_name)<0
        warndlg(['Markers assigned to body ',cur_body_name,' cannot be added to the model. Body is not in BodySet.']);
        continue
    end
    % loop through the markers
    cur_body_markers = BLStruct.(cur_body_name);
    % the actual markers are fields of the cur_body_markers variable
    markers_list = fields(cur_body_markers);
    N_markers = numel(markers_list);
    for nm = 1:N_markers
        % define the markers
        cur_marker_name = markers_list{nm};
        % get body
        cur_phys_frame = osimModel.getBodySet.get(cur_body_name);
        Loc = cur_body_markers.(cur_marker_name)*dim_fact;
        marker = Marker(cur_marker_name,...
                        cur_phys_frame,...
                        Vec3(Loc(1), Loc(2), Loc(3)));
        % add current marker to model
        osimModel.addMarker(marker);
        % clear coordinates as precaution
        clear Loc
    end
end
end
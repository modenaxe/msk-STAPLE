% GETBONELANDMARKLIST Given a bone name, returns names and description of
% the bony landmark identifiable on its surface in a convenient cell array.
%
%   LandmarkStruct = getBoneLandmarkList(bone_name)
%
% Inputs:
%   bone_name - a string indicating a bone of the lower limb
%
% Outputs:
%   LandmarkInfo - cell array containing the name and keywords to
%       identify the bony landmarks on each bone triangulation. This
%       information can easily used as input to findLandmarkCoords.m and
%       landmarkTriGeomBone.m.
%
% See also FINDLANDMARKCOORDS, LANDMARKTRIGEOMBONE.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
%
% TODO: add landmarking for left side

function LandmarkInfo = getBoneLandmarkList(bone_name)

% LandmarkInfo{1} = BL name
% LandmarkInfo{2} = axis
% LandmarkInfo{3} = operator (max/min)
% 2,3 can repeat
% LandmarkInfo{end} = proximal/distal (optional)
    
switch bone_name
    case 'pelvis'
        LandmarkInfo{1} = {'RASI', 'x', 'max', 'z', 'max'};
        LandmarkInfo{2} = {'LASI', 'x', 'max', 'z', 'min'};
        LandmarkInfo{3} = {'RPSI', 'x', 'min', 'z', 'max'};
        LandmarkInfo{4} = {'LPSI', 'x', 'min', 'z', 'min'};
    case 'femur_r'
        LandmarkInfo{1} = {'RKNE', 'z', 'max', 'distal'};
        LandmarkInfo{2} = {'RMFC', 'z', 'min', 'distal'};
        LandmarkInfo{3} = {'RTRO', 'z', 'max', 'proximal'};
    case 'tibia_r'
        LandmarkInfo{1} = {'RTTB','x', 'max', 'proximal'};
        LandmarkInfo{2} = {'RHFB','z', 'max', 'proximal'};
        LandmarkInfo{3} = {'RANK', 'z', 'max', 'distal'};
        LandmarkInfo{4} = {'RMMA', 'z', 'min', 'distal'};
    case 'patella_r'
        LandmarkInfo{1} = {'RLOW','y', 'min', 'distal'};
    case 'calcn_r'
        LandmarkInfo{1} = {'RHEE','x', 'min'};
        LandmarkInfo{2} = {'RD5M', 'z', 'max'};
        LandmarkInfo{3} = {'RD1M', 'z', 'min'};
    otherwise
        error('getBoneLandmarkList.m specified bone name is not supported yet.')
end

end
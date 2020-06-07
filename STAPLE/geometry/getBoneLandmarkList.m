function LandmarkStruct = getBoneLandmarkList(bone_name)
switch bone_name
    case 'pelvis'
        LandmarkStruct{1} = {'RASI', 'x', 'max', 'z', 'max'};
        LandmarkStruct{2} = {'LASI', 'x', 'max', 'z', 'min'};
        LandmarkStruct{3} = {'RPSI', 'x', 'min', 'z', 'max'};
        LandmarkStruct{4} = {'LPSI', 'x', 'min', 'z', 'min'};
    case 'femur_r'
        LandmarkStruct{1} = {'RKNE', 'z', 'max', 'distal'};
        LandmarkStruct{2} = {'RMFC', 'z', 'min', 'distal'};
        LandmarkStruct{3} = {'RTRO', 'z', 'max', 'proximal'};
    case 'tibia_r'
        LandmarkStruct{1} = {'RTTB','x', 'max', 'proximal'};
        LandmarkStruct{2} = {'RHFB','z', 'max', 'proximal'};
        LandmarkStruct{3} = {'RANK', 'z', 'max', 'distal'};
        LandmarkStruct{4} = {'RMMA', 'z', 'min', 'distal'};
    case 'patella_r'
        LandmarkStruct{1} = {'RLOW','y', 'min', 'distal'};
    case 'calcn_r'
        LandmarkStruct{1} = {'RHEE','x', 'min'};
        LandmarkStruct{2} = {'RD5M', 'z', 'max'};
        LandmarkStruct{3} = {'RD1M', 'z', 'min'};
    otherwise
end

end
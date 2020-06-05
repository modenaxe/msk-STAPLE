function LandmarkStruct = getBoneLandmarkList(bone_name)
switch bone_name
    case 'pelvis'
        LandmarkStruct{1} = {'RASIS', 'x', 'max', 'z', 'max'};
        LandmarkStruct{2} = {'LASIS', 'x', 'max', 'z', 'min'};
        LandmarkStruct{3} = {'RPSIS', 'x', 'min', 'z', 'max'};
        LandmarkStruct{4} = {'LPSIS', 'x', 'min', 'z', 'min'};
    case 'femur_r'
        LandmarkStruct{1} = {'RFEL', 'z', 'max', 'distal'};
        LandmarkStruct{2} = {'RFEM', 'z', 'min', 'distal'};
        LandmarkStruct{3} = {'RTRO', 'z', 'max', 'proximal'};
    case 'tibia_r'
        LandmarkStruct{1} = {'RTTB','x', 'max', 'proximal'};
        LandmarkStruct{2} = {'RLFH','z', 'max', 'proximal'};
        LandmarkStruct{3} = {'RLM', 'z', 'max', 'distal'};
        LandmarkStruct{4} = {'RMM', 'z', 'min', 'distal'};
    case 'patella_r'
        LandmarkStruct{1} = {'RLOW','y', 'min', 'distal'};
    case 'calcn_r'
        LandmarkStruct{1} = {'RHEE','x', 'min'};
        LandmarkStruct{2} = {'R5M', 'z', 'max'};
        LandmarkStruct{3} = {'R1M', 'z', 'min'};
    otherwise
end

end
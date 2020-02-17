function JointParamsStruct = getJointParams(joint_name)


switch joint_name
    case 'ground_pelvis'
        JointParamsStruct.name                = 'ground_pelvis';
        JointParamsStruct.parent              = 'ground';
        JointParamsStruct.child               = 'pelvis';
        %         JointParamsStruct.parent_location     = [0.0000	0.0000	0.0000];
        %         JointParamsStruct.parent_orientation  = [0.0000	0.0000	0.0000];
        %         JointParamsStruct.child_location      = pelvis_location;
        %         JointParamsStruct.child_orientation   = pelvis_orientation;
        JointParamsStruct.coordsNames         = {'pelvis_tilt','pelvis_list','pelvis_rotation', 'pelvis_tx','pelvis_ty', 'pelvis_tz'};
        JointParamsStruct.coordsTypes         = {'rotational', 'rotational', 'rotational', 'translational', 'translational','translational'};
        JointParamsStruct.rotationAxes        = 'zxy';
        
    case 'hip_r'
        JointParamsStruct.name                = 'hip_r';
        JointParamsStruct.parent              = 'pelvis';
        JointParamsStruct.child               = 'femur_r';
        %         JointParamsStruct.parent_location     = HJC_location;
        %         JointParamsStruct.parent_orientation  = pelvis_orientation;
        %         JointParamsStruct.child_location      = HJC_location;
        %         JointParamsStruct.child_orientation   = femur_orientation;
        JointParamsStruct.coordsNames         = {'hip_flexion_r','hip_adduction_r','hip_rotation_r'};
        JointParamsStruct.coordsTypes         = {'rotational', 'rotational', 'rotational'};
        JointParamsStruct.rotationAxes        = 'zxy';
        
    case 'knee_r'
        JointParamsStruct.name               = 'knee_r';
        JointParamsStruct.parent             = 'femur_r';
        JointParamsStruct.child              = 'tibia_r';
        %         JointParamsStruct.parent_location    = knee_location_in_parent;
        %         JointParamsStruct.parent_orientation = femur_orientation;
        %         JointParamsStruct.child_location     = knee_location_in_parent;
        %         JointParamsStruct.child_orientation  = tibia_orientation;
        JointParamsStruct.coordsNames        = {'knee_angle_r'};
        JointParamsStruct.coordsTypes        = {'rotational'};
        JointParamsStruct.rotationAxes       = 'zxy';
        
    case 'ankle_r'
        JointParamsStruct.name               = 'ankle_r';
        JointParamsStruct.parent             = 'tibia_r';
        JointParamsStruct.child              = 'talus_r';
        %         JointParamsStruct.parent_location    = knee_location_in_parent;
        %         JointParamsStruct.parent_orientation = femur_orientation;
        %         JointParamsStruct.child_location     = knee_location_in_parent;
        %         JointParamsStruct.child_orientation  = tibia_orientation;
        JointParamsStruct.coordsNames        = {'ankle_angle_r'};
        JointParamsStruct.coordsTypes        = {'rotational'};
        JointParamsStruct.rotationAxes       = 'zxy';
    case 'subtalar_r'
        JointParamsStruct.name               = 'subtalar_r';
        JointParamsStruct.parent             = 'talus_r';
        JointParamsStruct.child              = 'calcn_r';
        %         JointParamsStruct.parent_location    = knee_location_in_parent;
        %         JointParamsStruct.parent_orientation = femur_orientation;
        %         JointParamsStruct.child_location     = knee_location_in_parent;
        %         JointParamsStruct.child_orientation  = tibia_orientation;
        JointParamsStruct.coordsNames        = {'subtalar_angle_r'};
        JointParamsStruct.coordsTypes        = {'rotational'};
        JointParamsStruct.rotationAxes       = 'zxy';
    case 'patellofemoral_r'
                JointParamsStruct.name               = 'patellofemoral_r';
                JointParamsStruct.parent             = 'femur_r';
                JointParamsStruct.child              = 'patella_r';
                JointParamsStruct.coordsNames        = {'knee_angle_r_beta'};
                JointParamsStruct.coordsTypes        = {'rotational'};
                JointParamsStruct.rotationAxes       = 'zxy';
    otherwise
        error('unsupported joint')
end
function JointParamsStruct = appendJointParams(joint_name, JointParamsStruct)

if isempty(JointParamsStruct)
    nj = 1;
else
    nj = length(JointParamsStruct)+1;
end
    
switch joint_name
    case 'ground_pelvis'
        JointParamsStruct(nj).name                = 'ground_pelvis';
        JointParamsStruct(nj).parent              = 'ground';
        JointParamsStruct(nj).child               = 'pelvis';
        JointParamsStruct(nj).parent_location     = [0.0000	0.0000	0.0000];
        JointParamsStruct(nj).parent_orientation  = [0.0000	0.0000	0.0000];
        JointParamsStruct(nj).child_location      = pelvis_location;
        JointParamsStruct(nj).child_orientation   = pelvis_orientation;
        JointParamsStruct(nj).coordsNames         = {'pelvis_tilt','pelvis_list','pelvis_rotation', 'pelvis_tx','pelvis_ty', 'pelvis_tz'};
        JointParamsStruct(nj).coordsTypes         = {'rotational', 'rotational', 'rotational', 'translational', 'translational','translational'};
        JointParamsStruct(nj).rotationAxes        = 'zxy';
        
    case 'hip_r'
        JointParamsStruct(nj).name                = 'hip_r';
        JointParamsStruct(nj).parent              = 'pelvis';
        JointParamsStruct(nj).child               = 'femur_r';
        JointParamsStruct(nj).parent_location     = HJC_location;
        JointParamsStruct(nj).parent_orientation  = pelvis_orientation;
        JointParamsStruct(nj).child_location      = HJC_location;
        JointParamsStruct(nj).child_orientation   = femur_orientation;
        JointParamsStruct(nj).coordsNames         = {'hip_flexion_r','hip_adduction_r','hip_rotation_r'};
        JointParamsStruct(nj).coordsTypes         = {'rotational', 'rotational', 'rotational'};
        JointParamsStruct(nj).rotationAxes        = 'zxy';
        
    case 'knee_r'
        JointParamsStruct(nj).name               = 'knee_r';
        JointParamsStruct(nj).parent             = 'femur_r';
        JointParamsStruct(nj).child              = 'tibia_r';
        JointParamsStruct(nj).parent_location    = knee_location_in_parent;
        JointParamsStruct(nj).parent_orientation = femur_orientation;
        JointParamsStruct(nj).child_location     = knee_location_in_parent;
        JointParamsStruct(nj).child_orientation  = tibia_orientation;
        JointParamsStruct(nj).coordsNames        = {'knee_angle_r'};
        JointParamsStruct(nj).coordsTypes        = {'rotational'};
        JointParamsStruct(nj).rotationAxes       = rotation_axes;
        % JointParams(nj).rotationAxes       = [0.0488	-0.0463	-0.9977];
    case 'ankle_r'
    case 'patello_femoral_r'
    otherwise
end
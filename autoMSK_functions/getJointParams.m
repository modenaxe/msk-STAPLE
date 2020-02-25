function JointParamsStruct = getJointParams(joint_name, parentBodyCS, childBodyCS)

if nargin>1
    % the assumption is that the reference system will be provided for each
    % body. Each body will have specified the parameters for the joint.
    % TODO: ensure a body is connected to ground if no specifics are provided.
    if isempty(parentBodyCS)
        parentBodyCS.(joint_name).parent_location     = [0.0000	0.0000	0.0000];
        parentBodyCS.(joint_name).parent_orientation  = [0.0000	0.0000	0.0000];
    end
    
    % dealing with the cases where the joint centre is computed just in one
    % body and set for the other
    if isfield(childBodyCS.(joint_name), 'child_location')
        JointParamsStruct.child_location      = childBodyCS.(joint_name).child_location;
    else
        JointParamsStruct.child_location   = parentBodyCS.(joint_name).parent_location;
    end
    
    if isfield(parentBodyCS.(joint_name), 'parent_location')
        JointParamsStruct.parent_location      = parentBodyCS.(joint_name).parent_location;
    else
        JointParamsStruct.parent_location   = childBodyCS.(joint_name).child_location;
    end
    % assign orientations
    JointParamsStruct.parent_orientation     = parentBodyCS.(joint_name).parent_orientation;
    JointParamsStruct.child_orientation      = childBodyCS.(joint_name).child_orientation;
end

switch joint_name
    case 'ground_pelvis'
        JointParamsStruct.name                = 'ground_pelvis';
        JointParamsStruct.parent              = 'ground';
        JointParamsStruct.child               = 'pelvis';
        JointParamsStruct.coordsNames         = {'pelvis_tilt','pelvis_list','pelvis_rotation', 'pelvis_tx','pelvis_ty', 'pelvis_tz'};
        JointParamsStruct.coordsTypes         = {'rotational', 'rotational', 'rotational', 'translational', 'translational','translational'};
        JointParamsStruct.rotationAxes        = 'zxy';
        
    case 'hip_r'
        JointParamsStruct.name                = 'hip_r';
        JointParamsStruct.parent              = 'pelvis';
        JointParamsStruct.child               = 'femur_r';
        JointParamsStruct.coordsNames         = {'hip_flexion_r','hip_adduction_r','hip_rotation_r'};
        JointParamsStruct.coordsTypes         = {'rotational', 'rotational', 'rotational'};
        JointParamsStruct.rotationAxes        = 'zxy';
        
    case 'knee_r'
        JointParamsStruct.name               = 'knee_r';
        JointParamsStruct.parent             = 'femur_r';
        JointParamsStruct.child              = 'tibia_r';
        JointParamsStruct.coordsNames        = {'knee_angle_r'};
        JointParamsStruct.coordsTypes        = {'rotational'};
        JointParamsStruct.rotationAxes       = 'zxy';
        
    case 'ankle_r'
        JointParamsStruct.name               = 'ankle_r';
        JointParamsStruct.parent             = 'tibia_r';
        JointParamsStruct.child              = 'talus_r';
        JointParamsStruct.coordsNames        = {'ankle_angle_r'};
        JointParamsStruct.coordsTypes        = {'rotational'};
        JointParamsStruct.rotationAxes       = 'zxy';
    case 'subtalar_r'
        JointParamsStruct.name               = 'subtalar_r';
        JointParamsStruct.parent             = 'talus_r';
        JointParamsStruct.child              = 'calcn_r';
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
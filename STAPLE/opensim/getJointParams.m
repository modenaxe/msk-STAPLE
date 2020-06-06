function JointParamsStruct = getJointParams(joint_name, parentBody, childBody)
% the assumption is that the reference system will be provided for each
% body. Each body will have specified the parameters for the joint.

% these cases implement fixes if they do not.
% TODO: ensure a body is connected to ground if no specifics are provided.
if nargin>1
    
    % empty input as parentBodyCS means all set to zero
    if isempty(parentBody)
        parentBody.(joint_name).parent_location     = [0.0000	0.0000	0.0000];
        parentBody.(joint_name).parent_orientation  = [0.0000	0.0000	0.0000];
    end
    % if joint field is unavailable use the available one
     if ~isfield(childBody, joint_name)
         childBody.(joint_name) = [];
     end
     if ~isfield(parentBody, joint_name)
         parentBody.(joint_name) = [];
     end
    % if joint location is unavailable in child use parent
    if isfield(childBody.(joint_name), 'child_location')
        JointParamsStruct.child_location   = childBody.(joint_name).child_location;
    else
        JointParamsStruct.child_location   = parentBody.(joint_name).parent_location;
    end
    % if joint location is unavailable in parent use child
    if isfield(parentBody.(joint_name), 'parent_location')
        JointParamsStruct.parent_location   = parentBody.(joint_name).parent_location;
    else
        JointParamsStruct.parent_location   = childBody.(joint_name).child_location;
    end
    % if joint orientation is unavailable in child use parent
    if isfield(childBody.(joint_name), 'child_orientation')
        JointParamsStruct.child_orientation   = childBody.(joint_name).child_orientation;
    else
        JointParamsStruct.child_orientation   = parentBody.(joint_name).parent_orientation;
    end
    % if joint orientation is unavailable in parent use child
    if isfield(parentBody.(joint_name), 'parent_orientation')
        JointParamsStruct.parent_orientation  = parentBody.(joint_name).parent_orientation;
    else
        JointParamsStruct.parent_orientation  = childBody.(joint_name).child_orientation;
    end
%     % assign orientations
%     JointParamsStruct.parent_orientation     = parentBodyCS.(joint_name).parent_orientation;
%     JointParamsStruct.child_orientation      = childBodyCS.(joint_name).child_orientation;
end

switch joint_name
    case 'ground_pelvis'
        JointParamsStruct.name                = 'ground_pelvis';
        JointParamsStruct.parent              = 'ground';
        JointParamsStruct.child               = 'pelvis';
        JointParamsStruct.coordsNames         = {'pelvis_tilt','pelvis_list','pelvis_rotation', 'pelvis_tx','pelvis_ty', 'pelvis_tz'};
        JointParamsStruct.coordsTypes         = {'rotational', 'rotational', 'rotational', 'translational', 'translational','translational'};
        JointParamsStruct.rotationAxes        = 'zxy';
    case 'free_to_ground'
        cb                                    = childBody.free_to_ground.child; % current bone
        JointParamsStruct.name                = ['ground_',cb];
        JointParamsStruct.parent              = 'ground';
        JointParamsStruct.child               = cb;
        JointParamsStruct.coordsNames         = {[cb,'_tilt'],[cb,'_list'],[cb,'_rotation'], [cb,'_tx'],[cb,'_ty'], [cb,'_tz']};
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
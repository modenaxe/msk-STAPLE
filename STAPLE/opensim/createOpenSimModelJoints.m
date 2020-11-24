% CREATELOWERLIMBJOINTS Create the lower limb joints based on assigned
% joint coordinate systems stored in a structure and adds them to an
% existing OpenSim model.
%
% createOpenSimModelJoints(osimModel, JCS, method)
%
% Inputs:
%   osimModel - an OpenSim model of the lower limb to which we want to add
%       the lower limb joints. 
%
%   JCS - a MATLAB structure created using the function 
%       createLowerLimbJoints(). This structure includes as fields the
%       elements to generate a CustomJoint using the
%       createCustomJointFromStruct function. See these functions for
%       details.
%
%   method - optional input specifying the final arrangements of location
%       and orientation of the CustomJoint. Valid values are
%       'Modenese2018', which will define the same reference systems
%       described in Modenese et al. J Biomech (2018), or 'auto', that will
%       use the tibial JCS as well. See Modenese and Renault, JBiomech 2020
%       for details.
% 
% Outputs:
%   none - the joints are added to the input OpenSim model.
%
% See also GETJOINTPARAMS, CREATECUSTOMJOINTFROMSTRUCT, CREATELOWERLIMBJOINTS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
%
% TODO add switches for adding custom workflows

function createOpenSimModelJoints(osimModel, JCS, workflow)

% add ground body to JCS together with standard ground_pelvis joint.
% if model is partial, it will be modified.
JCS.ground.ground_pelvis.parentName = 'ground';
JCS.ground.ground_pelvis.parent_location     = [0.0000	0.0000	0.0000];
JCS.ground.ground_pelvis.parent_orientation  = [0.0000	0.0000	0.0000];
    
% based on JCS make a list of bodies and joints
bodies_list = fields(JCS)';
joint_list = {};
n_unique_j = 1;
for n = 1:length(bodies_list)
    cur_body = bodies_list{n};
    % get a temp joint list
    temp_joint_list = fields(JCS.(cur_body));
    % get the complete joint list available from morphological analysis
    for nj = 1:length(temp_joint_list)
        cur_joint = temp_joint_list{nj};
        if sum(strcmp(cur_joint, joint_list))==0
            % list of unique joints mentioned in JCSs
            joint_list{n_unique_j} = cur_joint;
            n_unique_j = n_unique_j+1;
        end
    end
end

% complete the joints parameters
for ncj = 1:length(joint_list)
    cur_joint_name = joint_list{ncj};
    jointStructTemp = getJointParams(cur_joint_name);
        % check that the joint can be built:
        % needs parent/child_location
    % needs parent/child_location
    % parent/child)orientation
    
    % STEP1: definition of parent and child 
%     checkBodies()
    if ~isfield(JCS, jointStructTemp.parentName)
        if isfield(JCS, jointStructTemp.childName)
            disp('Partial model detected...')
            child_name = jointStructTemp.childName;
            disp(['Connecting ', child_name, ' to ground'])
            % get appropriate parameters for the new joint
            jointStructTemp = getJointParams('free_to_ground', child_name);
            % adjusting joint parameters
            old_joint_name = cur_joint_name;
            cur_joint_name = jointStructTemp.jointName;
            % defines the new joints for parent/child location and
            % orientation
            JCS.ground.(cur_joint_name)  = JCS.ground.ground_pelvis;
            JCS.(child_name).(cur_joint_name) = JCS.(child_name).(old_joint_name);
        else
            error(['Incorrect definition of joint ', jointStructTemp.jointName, ': missing both parent and child bones from analysis.'])
        end
    end
    if ~isfield(JCS, jointStructTemp.childName)
        disp('Partial model detected...')
        disp(['deleting incomplete ', cur_joint_name, ' joint.' ])
        continue
    end
    
    % STEP2: check parameters and fill missing
    Pars.parent = JCS.(jointStructTemp.parentName).(cur_joint_name);
    Pars.child  = JCS.(jointStructTemp.childName).(cur_joint_name);
    % implementing the simple completing rule: 
    % if parent/child_location is unavailable use child/parent_location
    % if parent/child_orientation is unavailable use child/parent_orientation
    opt_set = {'parent', 'child', 'parent'};
    for ns = 1:2
        cur_joint_side = opt_set{ns};
        required_fields = {'_location', '_orientation'};
        for nf = 1:length(required_fields)
            cur_req_field = [cur_joint_side, required_fields{nf}];
            other_side_req_filed = [opt_set{ns+1}, required_fields{nf}];
            % fill missing fields of child with parent
            if max(strcmp(fields(Pars.(cur_joint_side)), cur_req_field))==0
                disp(['missing field ', cur_req_field])
                jointStructTemp.(cur_req_field) = Pars.(opt_set{ns+1}).(other_side_req_filed);
            else
                jointStructTemp.(cur_req_field) = Pars.(cur_joint_side).(cur_req_field);
            end
        end
    end
    
    % store the resulting parameters for each joint
    jointStruct.(cur_joint_name) = jointStructTemp;

%     JointParamsStruct.parent_location
%     JointParamsStruct.parent_orientation
%     JointParamsStruct.child_location
%     JointParamsStruct.child_orientation

end

disp('Adding joints to model:')
available_joints =  fields(jointStruct);
for ncj = 1:length(available_joints)
    cur_joint_name = available_joints{ncj};
%     JointParamsStruct = getJointParams(cur_joint_name);
    
    % create the joint
    createCustomJointFromStruct(osimModel, jointStruct.(cur_joint_name));
    
    % display what has been created
    disp(['   * ', cur_joint_name]);
end
    
% % if not specified, method is auto. Other option is Modenese2018.
% % This only influences ankle and subtalar joint.
% if nargin<3;     error('createLowerLimbJoints.m Error: you need to specify a body side.');   end
% if nargin<3;     workflow = 'auto';   end
% if nargin<4
%     side_low = inferBodySideFromAnatomicStruct(JCS);
% else
%     % get sign correspondent to body side
%     [~, side_low] = bodySide2Sign(side_raw);
% end

% % printout
% disp('---------------------');
% disp('   CREATING JOINTS   ')
% disp('---------------------');
% disp(['Workflow for joint definitions: ', workflow])
% 
% % joint names
% hip_name      = ['hip_',side_low];
% knee_name     = ['knee_',side_low];
% ankle_name    = ['ankle_',side_low];
% subtalar_name = ['subtalar_',side_low];
% % patellofemoral_name = ['patellofemoral_',side_low];
% 
% % segment names
% femur_name      = ['femur_',side_low];
% tibia_name      = ['tibia_',side_low];
% % patella_name    = ['patella_',side_low];
% talus_name      = ['talus_',side_low];
% calcn_name      = ['calcn_',side_low];
% 
% disp('Adding joints to model:')
% 
% % ground_pelvis joint
% %---------------------
% if isfield(JCS, 'pelvis')
%     JointParams = getJointParams('ground_pelvis', [], JCS.pelvis, side_low);
%     createCustomJointFromStruct(osimModel, JointParams);
%     disp('   * ground_pelvis');
% else
%     % this allows to create a free body with ground using any segment
%     % requires definition of fields child, child_orientation and
%     % child_location in JCS.free_to_ground (as subfields).
%     disp('Partial model detected (attaching proxbody to ground).')
%     JointParams = getJointParams('free_to_ground', [], JCS.proxbody, side_low);
%     createCustomJointFromStruct(osimModel, JointParams);
%     disp('   * free_to_ground');
% end
% 
% 
% % hip joint
% %-------------
% if isfield(JCS, 'pelvis') && isfield(JCS, femur_name)
%     JointParams = getJointParams(hip_name, JCS.pelvis, JCS.(femur_name), side_low);
%     createCustomJointFromStruct(osimModel, JointParams);
%     disp(['   * ', hip_name]);
% end
% 
% 
% % knee joint
% %-------------
% if isfield(JCS, femur_name) && isfield(JCS, tibia_name)
%     if strcmp(workflow, 'Modenese2018')
%         if isfield(JCS, talus_name)
%             JCS.(tibia_name) = assembleKneeChildOrientationModenese2018(JCS.(femur_name), JCS.(tibia_name), JCS.(talus_name));
%         else
%             warndlg('JCS structure does not have a talus_r field required for Modenese 2018 knee joint definition. Defining joint as auto2020.')
%         end
%     end
%     JointParams = getJointParams(knee_name, JCS.(femur_name), JCS.(tibia_name), side_low);
%     createCustomJointFromStruct(osimModel, JointParams);
%     disp(['   * ', knee_name]);
% end
% 
% 
% % ankle joint
% %-------------
% if isfield(JCS, tibia_name) && isfield(JCS, talus_name) 
%     JCS.(tibia_name) = assembleAnkleParentOrientation(JCS.(tibia_name), JCS.(talus_name));
%     % in case you want to replicate the modelling from Modenese et al. 2018
%     if strcmp(workflow, 'Modenese2018')
%         if isfield(JCS, calcn_name)
%             JCS.(tibia_name) = assembleAnkleParentOrientationModenese2018(JCS.(tibia_name), JCS.(talus_name));
%             JCS.(talus_name) = assembleAnkleChildOrientationModenese2018(JCS.(talus_name), JCS.(calcn_name));
%         else
%             warndlg('JCS structure does not have a calcn_r field required for Modenese 2018 ankle definition. Defining joint as auto2020.')
%         end
%     end
%     JointParams = getJointParams(ankle_name, JCS.(tibia_name), JCS.(talus_name), side_low);
%     createCustomJointFromStruct(osimModel, JointParams);
%     disp(['   * ', ankle_name]);
% end
% 
% 
% % subtalar joint
% %----------------
% if isfield(JCS, talus_name) && isfield(JCS, calcn_name)
%     % in case you want to replicate the modelling from Modenese et al. 2018
%     if strcmp(workflow, 'Modenese2018')
%         if isfield(JCS, femur_name)
%             JCS.(talus_name) = assembleSubtalarParentOrientationModenese2018(JCS.(femur_name), JCS.(talus_name));
%         else
%             warndlg(['JCS structure does not have a ', femur_name,' field required for Modenese 2018 subtalar definition. Defining joint as auto2020.'])
%         end
%     end
%     JointParams = getJointParams(subtalar_name, JCS.(talus_name), JCS.(calcn_name), side_low);
%     createCustomJointFromStruct(osimModel, JointParams);
%     disp(['   * ', subtalar_name]);
% end 
% 
% 
% % patella joint
% %---------------
% % if isfield(JCS, patella_name) && isfield(JCS, femur_name)
% %     JCS.patella_r = assemblePatellofemoralParentOrientation(JCS.(femur_name), JCS.(patella_name));
% %     JointParams = getJointParams(patellofemoral_name, JCS.(femur_name), JCS.(patella_name), side_low);
% %     createCustomJointFromStruct(osimModel, JointParams);
% %     osimModel.addJoint(patfem_joint);
% %     addPatFemJointCoordCouplerConstraint(osimModel, side)
% %     addPatellarTendonConstraint(osimModel, TibiaRBL, PatellaRBL, side, in_mm)
% % disp(['   * ', patellofemoral_name]);
% % end
% 
% disp('Done.')
% 
% end
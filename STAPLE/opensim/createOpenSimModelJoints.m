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

if nargin<3;     workflow = 'auto';   end

% printout
disp('---------------------');
disp('   CREATING JOINTS   ')
disp('---------------------');
disp(['Workflow for joint definitions: ', workflow])

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
disp('Checking joint parameters completeness:')
for ncj = 1:length(joint_list)
    cur_joint_name = joint_list{ncj};
    jointStructTemp = getJointParams(cur_joint_name);

    % STEP1: check if parent and child body are available
    parent_name = jointStructTemp.parentName;
    child_name  = jointStructTemp.childName;
    % the assumption is that if, given a joint from the analysis, parent is
    % missing, that's because the model is partial proximally and will be 
    % connected to ground. If child is missing, instead, the model if
    % partial distally and the chain will be interrupted there.
    if ~isfield(JCS, parent_name)
        if isfield(JCS, child_name)
            disp('Partial model detected proximally:')
            % get appropriate parameters for the new joint
            jointStructTemp = getJointParams('free_to_ground', child_name);
            % adjusting joint parameters
            old_joint_name = cur_joint_name;
            cur_joint_name = jointStructTemp.jointName;
            disp(['   * Connecting ', child_name, ' to ground with ', cur_joint_name, ' free joint.'])
            % defines the new joints for parent/child location and
            % orientation
            JCS.ground.(cur_joint_name)  = JCS.ground.ground_pelvis;
            JCS.(child_name).(cur_joint_name) = JCS.(child_name).(old_joint_name);
        else
            error(['Incorrect definition of joint ', jointStructTemp.jointName, ': missing both parent and child bones from analysis.'])
        end
    end
    if ~isfield(JCS, jointStructTemp.childName)
        disp('Partial model detected distally...')
        disp(['   * Deleting incomplete joint ''', cur_joint_name,'''']);
        continue
    end
    
    % STEP2: check parameters and fill missing
    if isfield(JCS.(parent_name), cur_joint_name)
        Pars.parent = JCS.(parent_name).(cur_joint_name);
    else
        % detect is there is a side
        if strcmp(cur_joint_name(end-1:end), '_r') || strcmp(cur_joint_name(end-1:end), '_l')
            cur_joint_name_short = cur_joint_name(1:end-2);
        end
        % deal with non present reference system. In lower limb should be
        % just the ankle
        switch cur_joint_name_short
            case 'ankle'
                JCS.(parent_name).(cur_joint_name) = assembleAnkleParentOrientation(JCS.(parent_name), JCS.(child_name));
                 Pars.parent = JCS.(parent_name).(cur_joint_name);
            otherwise
                error(['Parameters of joint ', cur_joint_name, ' are not defined. Please hardcode a solution!']);
        end
    end
    if isfield(JCS.(child_name), cur_joint_name)
        Pars.child  = JCS.(child_name).(cur_joint_name);
    end
    
    % STEP3: if both exist then check completeness
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
                disp(['   * ',cur_joint_name,': assign missing ''', cur_req_field, ''' taken from ''', other_side_req_filed,''''])
                jointStructTemp.(cur_req_field) = Pars.(opt_set{ns+1}).(other_side_req_filed);
            else
                jointStructTemp.(cur_req_field) = Pars.(cur_joint_side).(cur_req_field);
            end
        end
    end
    
    % store the resulting parameters for each joint
    jointStruct.(cur_joint_name) = jointStructTemp;

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

disp('Done.')

end
    

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

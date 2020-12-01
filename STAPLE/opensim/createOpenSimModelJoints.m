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

% add ground body to JCS together with standard ground_pelvis joint.
% if model is partial, it will be modified.
JCS.ground.ground_pelvis.parentName = 'ground';
JCS.ground.ground_pelvis.parent_location     = [0.0000	0.0000	0.0000];
JCS.ground.ground_pelvis.parent_orientation  = [0.0000	0.0000	0.0000];

% based on JCS make a list of bodies and joints
joint_list = compileListOfJointsInJCSStruct(JCS);

%% TRANSFORM THE JCS FROM MORPHOLOGYCAL ANALYSIS IN JOINT DEFINITION
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
            parent_name = jointStructTemp.parentName;
            disp(['   * Connecting ', child_name, ' to ground with ', cur_joint_name, ' free joint.'])
            % defines the new joints for parent/child location and
            % orientation
            JCS.ground.(cur_joint_name)  = JCS.ground.ground_pelvis;
            JCS.(child_name).(cur_joint_name) = JCS.(child_name).(old_joint_name);
        else
            error(['Incorrect definition of joint ', jointStructTemp.jointName, ': missing both parent and child bones from analysis.'])
        end
    end
    if ~isfield(JCS, child_name)
        if isfield(JCS, parent_name)
            disp('Partial model detected distally...')
            disp(['   * Deleting incomplete joint ''', cur_joint_name,'''']);
            continue
        else
            error(['Incorrect definition of joint ', jointStructTemp.jointName, ': missing both parent and child bones from analysis.'])
        end
    end
    % display joint details
    disp(['* ', cur_joint_name]);
    disp(['   - parent: ',parent_name])
    disp(['   - child: ', child_name])

    % STEP2: check parameters and fill missing
    % detecting missing reference systems on both side of joints
    if isfield(JCS.(parent_name), cur_joint_name) && isfield(JCS.(child_name), cur_joint_name)
        
        Pars.parent = JCS.(parent_name).(cur_joint_name);
        Pars.child = JCS.(child_name).(cur_joint_name);
        
        % STEP3: if both exist then check completeness
        % implementing the simple completing rule:
        % if parent/child_location is unavailable use child/parent_location
        % if parent/child_orientation is unavailable use child/parent_orientation
        
        child_or_parent = {'parent', 'child', 'parent'};
        location_or_orientation = {'_location', '_orientation'};
%         for ns = 1:2
%           for nf = 1:2
%               cur_req_field = [cur_joint_side, required_fields{nf}];
%               if isfield(Pars.(opt_set{ns}), cur_req_field)==0
%                   disp(['   - ',cur_req_field, ' present.'])
%               else
%                   disp(['   - ',cur_req_field, ' missing.'])
%               end
%           end
%         end
                  
        for ns = 1:2
            cur_joint_side = child_or_parent{ns};
            for nf = 1:length(location_or_orientation)
                cur_req_field = [cur_joint_side, location_or_orientation{nf}];
                other_side_req_filed = [child_or_parent{ns+1}, location_or_orientation{nf}];
                % fill missing fields of child with parent
                if isfield(Pars.(cur_joint_side), cur_req_field)==0
                    disp(['   - ',cur_req_field, ' missing: copied from ''', other_side_req_filed,'''.'])
                    jointStructTemp.(cur_req_field) = Pars.(child_or_parent{ns+1}).(other_side_req_filed);
                else
                    disp(['   - ',cur_req_field, ' present.'])
                    jointStructTemp.(cur_req_field) = Pars.(cur_joint_side).(cur_req_field);
                end
            end
        end
        
    else
        if ~isfield(JCS.(parent_name), cur_joint_name)
            disp(['   - WARNING: joint not defined in ', parent_name])
        end
        if ~isfield(JCS.(child_name), cur_joint_name)
            disp(['   - WARNING: joint not defined in ', child_name])
        end
    end
    
    % store the resulting parameters for each joint to the final struct
    jointStruct.(cur_joint_name) = jointStructTemp;
    clear Pars
end

% WORKFLOW IMPLEMENTATION
disp(['Applying joint definitions: ', workflow])
switch workflow
    case 'auto'
        jointStruct = jointDefinitions_auto2020(JCS, jointStruct);
    case 'Modenese2018'
        % joint definitions of Modenese et al.
        jointStruct = jointDefinitions_Modenese2018(JCS, jointStruct);
    otherwise
        error('createOpenSimModelJoints.m You need to define joint definitions')
end
% completeJoints(jointStruct)

% check that all joints are completed
nF = fields(jointStruct);
fields_to_check = {'jointName', 'parentName', 'parent_location', 'parent_orientation', ...
                   'childName', 'child_location', 'child_orientation',...
                   'coordsNames', 'coordsTypes', 'rotationAxes'};
for nf = 1:length(nF)
    cur_joint = nF{nf};
    defined_joint_params = isfield(jointStruct.(cur_joint),fields_to_check);
    if min(defined_joint_params)~=1
        disp([cur_joint, ' definition incomplete. Missing fields:']);
        error_printout = fields_to_check(~defined_joint_params);
        for nerr = 1:length(error_printout)
            disp(['   -> ', error_printout{nerr}])
        end
%         error('createOpenSimModelJoints.m Incorrect Joint Definition. See above.');
    end
end
disp('All joints verified.')

% after the verification joints can be added
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






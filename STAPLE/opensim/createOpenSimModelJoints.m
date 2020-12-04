% CREATELOWERLIMBJOINTS Create the lower limb joints based on assigned
% joint coordinate systems stored in a structure and adds them to an
% existing OpenSim model.
%
% createOpenSimModelJoints(osimModel, JCS, jointDefs, jointParamFile)
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
%   joint_defs - optional input specifying the joint definitions used for
%       arranging and finalizing the partial reference systems obtained
%       from morphological analysis of the bones. Valid values:
%         - 'Modenese2018': define the same reference systems described in 
%                           Modenese et al. J Biomech (2018).
%         - 'auto2020': use the reference systems from morphological 
%                       analysis as much as possible. See 
%                       Modenese and Renault, JBiomech 2020 for a
%                       comparison.
%         - any definition you want to add. You just need to write a
%           function and include it in the "switch" structure where joints
%           are defined. Your implementation will be check for completeness
%           by the verifyJointStructCompleteness.m function.
%
% jointParamFile - optional input specifying the name of a MATLAB function
%       including the parameters of the joints to build. Default value is:
%           - 'getJointParams.m': same joint parameters as the gait2392
%                                 standard model.
%           - 'getJointParams3DoFKnee.m': file available from the advanced
%                                 examples, shows how to create a 3 dof
%                                 knee joint
%           - any other joint parameters you want to implement. Be careful
%             because joint definitions and input bone will have to match:
%             for example you cannot create a 2 dof ankle joint and
%             exclude a subtalar joint if you are providing a talus and
%             calcn segments, as otherwise they would not have any joint.
%
% Outputs:
%   none - the joints are added to the input OpenSim model.
%
% See also GETJOINTPARAMS, CREATECUSTOMJOINTFROMSTRUCT, 
%          VERIFYJOINTSTRUCTCOMPLETENESS, CREATEOPENSIMMODELJOINTS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function createOpenSimModelJoints(osimModel, JCS, joint_defs, jointParamFile)

if nargin<3;     joint_defs = 'auto2020';   end
if nargin<4;     jointParamFile = 'getJointParams.m';   end

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
disp('Checking parameters from morphological analysis:')

% useful list
fields_v = {'parent_location','parent_orientation','child_location', 'child_orientation'};
    
if exist(jointParamFile, 'file') == 2
    jointParamFuncName = jointParamFile(1:end-2);
else
    disp(['WARNING: Specified function ''', jointParamFile,''' for joint parameters was not found. Using default ''getJointParams.m''']);
    jointParamFuncName = 'getJointParams';
end

for ncj = 1:length(joint_list)
    % current joint name
    cur_joint_name = joint_list{ncj};
    
    % getting joint parameters using the desired joint param function
    eval(['jointStructTemp = ',jointParamFuncName,'(cur_joint_name);'])
    
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
    % if there is a parent but not a child body then the model is partial
    % distally, i.e. it is missing some distal body/bodies.
    if ~isfield(JCS, child_name)
        if isfield(JCS, parent_name)
            disp('Partial model detected distally...')
            disp(['* Deleting incomplete joint ''', cur_joint_name,'''']);
            continue
        else
            error(['Incorrect definition of joint ', jointStructTemp.jointName, ': missing both parent and child bones from analysis.'])
        end
    end
    
    % display joint details
    disp(['* ', cur_joint_name]);
    disp(['   - parent: ',parent_name])
    disp(['   - child: ', child_name])
    
    % create an appropriate jointStructTemp from the info available in JCS
    % ? is this worth its own function JCS2jointStruct?
    body_list = fields(JCS);
    for nb = 1:length(body_list)
        cur_body_name = body_list{nb};
        if isfield(JCS.(cur_body_name), cur_joint_name)
            joint_info = JCS.(cur_body_name).(cur_joint_name);
            copy_fields_id = find(isfield(joint_info, fields_v));
            for nc = copy_fields_id
                jointStructTemp.(fields_v{nc}) = joint_info.(fields_v{nc});
            end  
        else
            continue
        end
    end
    % store the resulting parameters for each joint to the final struct
    jointStruct.(cur_joint_name) = jointStructTemp;
    clear Pars
end

% JOINT DEFINITIONS
disp(['Applying joint definitions: ', joint_defs])
switch joint_defs
    case 'auto2020'
        jointStruct = jointDefinitions_auto2020(JCS, jointStruct);
    case 'Modenese2018'
        % joint definitions of Modenese et al.
        jointStruct = jointDefinitions_Modenese2018(JCS, jointStruct);
    otherwise
        error('createOpenSimModelJoints.m You need to define joint definitions')
end

% completeJoints(jointStruct)
jointStruct = assembleJointStruct(jointStruct);

% check that all joints are completed
verifyJointStructCompleteness(jointStruct)

% after the verification joints can be added
disp('Adding joints to model:')
available_joints =  fields(jointStruct);
for ncj = 1:length(available_joints)
    cur_joint_name = available_joints{ncj};
    % create the joint
    createCustomJointFromStruct(osimModel, jointStruct.(cur_joint_name));
    % display what has been created
    disp(['   * ', cur_joint_name]);
end

disp('Done.')

end
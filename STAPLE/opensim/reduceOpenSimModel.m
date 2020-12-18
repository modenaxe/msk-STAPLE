% REDUCEOPENSIMMODEL Remove from given OpenSim model the bodies specified
% in a provided list and adjusts JointSet, ForceSet and MarkerSets
% accordingly. Note that the script has the limitation of not removing
% constraints.
%
%   osimModel = reduceOpenSimModel(osimModel, listOfBodiesToRemove)
%
% Inputs:
%   osimModel -  OpenSim model that needs to be modified
%
%   listOfBodiesToRemove - cell array of strings. Each string is the name
%       a body that should be removed from the model.
%
% Outputs:
%   osimModel - the updated OpenSim model with removed bodies.
%
%
% See also RENAMEBODYANDADJUSTOPENSIMMODEL, MERGEOPENSIMMODELS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
%
% TODO add a check to identify body names that are bodies in the model
function osimModel = reduceOpenSimModel(osimModel, listOfBodiesToRemove)

% import libraries
import org.opensim.modeling.*

disp('--------------------------------')
disp('     REDUCING OPENSIM MODEL     ')
disp('--------------------------------')
disp(['Model Name: ', char(osimModel.getName())])

%--------------
% REDUCE JOINTS
%--------------
disp('Reducing joints:')
% required to operate with the joints, apparently
osimModel.finalizeConnections()
% get model JointSet
jointSet = osimModel.getJointSet();
% create reduced JointSet
reduced_jointSet = JointSet();
reduced_jointSet.setName('jointset')
% loop through joints
for nj = 0:jointSet.getSize()-1
    % current joint
    cur_joint = jointSet.get(nj);
    %------------------------------------
    % each joint has two frames - better extract them both immediately than
    % loop through them in my experience
    %------------------------------------
    % get the PhysicalOffsetFrames defining the joint
    cur_parent_PhysicalOffsetFrame0 = cur_joint.get_frames(0);
    cur_parent_PhysicalOffsetFrame1 = cur_joint.get_frames(1);
    % get the PhysicalFrame (body)
    parent_frame0 = cur_parent_PhysicalOffsetFrame0.getParentFrame();
    parent_frame1 = cur_parent_PhysicalOffsetFrame1.getParentFrame();
    % name of body to which the PhysicalOffsetFrame is attached
    cur_parent_frame_name0 = char(parent_frame0.getName());
    cur_parent_frame_name1 = char(parent_frame1.getName());
    % if that body is to remove, then don't save it on reduced_jointSet
    if sum(strcmp( listOfBodiesToRemove ,cur_parent_frame_name0))>0 || ...
            sum(strcmp( listOfBodiesToRemove ,cur_parent_frame_name1))>0
        disp(['     * remove joint: ', char(cur_joint.getName())]);
        continue
    else
        % if not on list save it!
        reduced_jointSet.cloneAndAppend(cur_joint);
%         disp(['     * keep joint: ', char(cur_joint.getName())])
        continue
    end 
end
% assigned the reduce jointset
jointSet.assign(reduced_jointSet);
% https://github.com/opensim-org/opensim-core/pull/1748
osimModel.finalizeFromProperties();

%--------------
% REDUCE BODIES
%--------------
disp('Reducing bodies:')
bodySet = osimModel.getBodySet();
reduced_bodySet = BodySet();
reduced_bodySet.setName('bodyset');
for n_b = 0:bodySet.getSize-1
    % loop through the bodyset
    curr_body_name = char(bodySet.get(n_b).getName());
    % if the body name is to remove then do not add to reduce_bodyset
    if sum(strcmp(listOfBodiesToRemove, curr_body_name))>0
        disp(['     * remove ',curr_body_name])
        continue
    else
        % if not in list then add it
        curr_body = bodySet.get(n_b);
        reduced_bodySet.cloneAndAppend(curr_body);
%         disp(['     * keep ',curr_body_name])
    end
end
% assign updated bodyset
bodySet.assign(reduced_bodySet);
% https://github.com/opensim-org/opensim-core/pull/1748
% osimModel.finalizeFromProperties();

%---------------
% REDUCE MARKERS
%---------------
disp('Reducing markers:')
% get markerset
markerset = osimModel.getMarkerSet;
% create reduced markerset
reduced_markerset = MarkerSet();
reduced_markerset.setName('markerset');
for n_m = 0:markerset.getSize-1
    % get marker name
    curr_marker_name = char(markerset.get(n_m).getName());
    % body is returned with /bodyset/ path
    curr_marker_body_name = strrep(char(markerset.get(n_m).getParentFrameName()), '/bodyset/','');
    if max(strcmp(listOfBodiesToRemove, curr_marker_body_name))==1
        disp(['     * remove ',curr_marker_name])
        continue
    else
        curr_marker = markerset.get(n_m);
        reduced_markerset.cloneAndAppend(curr_marker);
%         disp(['     * keep: ',curr_marker_name])
    end
end
% assigning new markerset
markerset.assign(reduced_markerset) ;
% upd_markerset.print('upd_markers.xml');
% https://github.com/opensim-org/opensim-core/pull/1748
% osimModel.finalizeFromProperties();

%---------------
% REDUCE MUSCLES
%---------------
% % 2) remove muscle points associated with the bodies that we want to remove
% % remove muscles with less than 2 points
disp('Reducing muscles:')
muscleSet = osimModel.getMuscles;
reduced_forceSet = ForceSet();
for n_mus = 0:muscleSet.getSize-1
    % get muscles path points
    curr_muscle = muscleSet.get(n_mus);
    curr_muscle_name = char(curr_muscle.getName());
%     disp(['processing ',curr_muscle_name]);
    PathPoints = muscleSet.get(n_mus).getGeometryPath.getPathPointSet();
    % starting a new pathpoint set
%     reduced_pathPointSet = PathPointSet();
    N_p = PathPoints.getSize();
    for n_p = 0:N_p-1
        curr_point = PathPoints.get(n_p);
        curr_muscle_body_name = strrep(char(curr_point.getPropertyByName(...
            'socket_parent_frame')),'/bodyset/','');
        if max(strcmp(listOfBodiesToRemove, curr_muscle_body_name))==1
            disp(['     * remove ',curr_muscle_name])
            break
        end
        if n_p ==N_p-1
            % if code gets to this point all PathPoints are ok
%             disp(['adding ', curr_muscle_name]);
            reduced_forceSet.cloneAndAppend(curr_muscle);
        end    
    end
end
% assign the reduce forceset
osimModel.getForceSet().assign(reduced_forceSet);

if osimModel.isValidSystem()== 0
    disp('Model has been reduced successfully');
end

% updating name
osimModel.setName([char(osimModel.getName),'_reduced']);

% https://github.com/opensim-org/opensim-core/pull/1748
osimModel.finalizeFromProperties();

end


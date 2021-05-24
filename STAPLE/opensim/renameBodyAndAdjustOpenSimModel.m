% RENAMEBODYANDADJUSTOPENSIMMODEL Rename a body of a provided OpenSim model
% and adjusts JointSet, ForceSet and MarkerSets accordingly. 
% Note that the script has the limitation of not adjusting constraints.
%
%   osimModel =renameBodyAndAdjustOpenSimModel(osimModel, aBodyName, newBodyName)
%
% Inputs:
%   osimModel -  OpenSim model of which a body needs to be renamed.
%
%   aBodyName - string that represents the name of a body in the OpenSim 
%       model.
%
%   newBodyName - string that represents the desired name of the body 
%       previously called 'aBodyName' in the the OpenSim model.
%
% Outputs:
%   osimModel - the updated OpenSim model with the renamed body.
%
%
% See also REDUCEOPENSIMMODEL, MERGEOPENSIMMODELS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function osimModel =renameBodyAndAdjustOpenSimModel(osimModel, aBodyName, newBodyName)

% import libraries
import org.opensim.modeling.*

% get the BodySet
bodySet = osimModel.upd_BodySet();
% check if there is a Body with the provided name
if bodySet.getIndex(aBodyName)<0
    error(['renameBodyAndUpdateOpenSimModel.m ', aBodyName, ' is not the name of a Body in the considered OpenSim model.']);
end
% get the body
bodyOfInterest = bodySet.get(aBodyName);
% change the body name
bodyOfInterest.setName(newBodyName);

% update joints
jointSet = osimModel.upd_JointSet();
NJ = jointSet.getSize();
% loop through the joints
for nj = 0:NJ-1
    cur_joint = jointSet.get(nj);
%     joint_class_name = char(cur_joint.getConcreteClassName());
%     eval(['cur_joint = ',joint_class_name,'.safeDownCast(cur_joint)']);
    % loop through the frames
    for nframe = 0:1
        cur_frame = cur_joint.get_frames(nframe);
        cur_body_name = strrep(char(cur_frame.getPropertyByName('socket_parent')), '/bodyset/','');
        % replace the name of the offset frame and parent frame when the ol
       if strcmp(cur_body_name, aBodyName)
            % attempt to correct             
            cur_frame.setParentFrame(bodyOfInterest);
            % REQUIRED to link the new specified parent with the body and 
            % change the name of the frame afterward)
            cur_joint.finalizeConnections(cur_joint);
            cur_frame.setName([newBodyName,'_offset']);
        end
    end
end


% update markers
markerSet = osimModel.getMarkerSet();
Nmarkers = markerSet.getSize();
for nmarker = 0:Nmarkers-1
    cur_marker = markerSet.get(nmarker);
    cur_parent_name = strrep(char(cur_marker.getParentFrameName), '/bodyset/','');
    if strcmp(cur_parent_name, aBodyName)
        cur_marker.setParentFrameName(['/bodyset/',newBodyName]);
    end
end

% update muscles
muscles = osimModel.updMuscles();
Nmuscles = muscles.getSize();
for nmus = 0:Nmuscles-1
    cur_muscle = muscles.get(nmus);
    pathPointSet = cur_muscle.getGeometryPath().getPathPointSet();
    Npoints = pathPointSet.getSize();
    for np = 0:Npoints-1
        cur_p = pathPointSet.get(np);
        p_attach_body = strrep(char(cur_p.getPropertyByName('socket_parent_frame')), '/bodyset/','');
        if strcmp(p_attach_body, aBodyName)
            cur_p.setParentFrame(bodySet.get(newBodyName));
        end
    end
end

% REQUIRED to make the model aware that I have changed the frame name
osimModel.finalizeConnections();

% osimModel.print('outtest.osim');
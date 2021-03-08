function [updTriBoneGeom, jointStruct, landmarkStruct] = transformToBodyCS(BCS, triGeomBoneSet, jointStruct, landmarkStruct)

if nargin < 2; triGeomBoneSet = []; end
if nargin < 3; jointStruct    = []; end
if nargin < 4; landmarkStruct = []; end

if ~isempty(triGeomBoneSet)
    % convert geometries in chosen format (30% of faces for faster visualization)
    updTriBoneGeom = transformTriGeomSet(triGeomBoneSet, BCS);
end

% trasform joint params to BCS
if ~isempty(jointStruct)
    joint_list = fields(jointStruct);
    body_list  = fields(BCS);
    for nb = 1:numel(body_list)
        cur_body_name = body_list{nb};
        cur_body  = BCS.(cur_body_name);
        for nj = 1:numel(joint_list)
            cur_joint_name = joint_list{nj};
            cur_joint = jointStruct.(cur_joint_name);
            if strcmp(cur_joint.childName, cur_body_name)
                jointStruct.(cur_joint_name).child_location = ...
                    (cur_body.V'*(cur_joint.child_location'-cur_body.Origin/1000))';
                jointStruct.(cur_joint_name).child_orientation = ...
                    computeXYZAngleSeq(cur_body.V'*orientation2MatRot(cur_joint.child_orientation));
            end
            if strcmp(cur_joint.parentName, cur_body_name)
                jointStruct.(cur_joint_name).parent_location = ...
                    (cur_body.V'*(cur_joint.parent_location'-cur_body.Origin/1000))';
                
                jointStruct.(cur_joint_name).parent_orientation = ...
                    computeXYZAngleSeq(cur_body.V'*orientation2MatRot(cur_joint.parent_orientation));
            end
        end
    end
end
clear body_list cur_body_name

% transform bony landmarks to BCS (still in mm)
if ~isempty(landmarkStruct)
    body_list = fields(landmarkStruct);
    for nb = 1:numel(landmarkStruct)
        cur_body_name = body_list{nb};
        cur_body  = BCS.(cur_body_name);
        BL_list = fields(landmarkStruct.(cur_body_name));
        if ~isempty(BL_list)
            for nl = 1:numel(BL_list)
                cur_BL_coord = landmarkStruct.(cur_body_name).(BL_list{nl});
                landmarkStruct.(cur_body_name).(BL_list{nl}) = ...
                    (cur_body.V'*(cur_BL_coord-cur_body.Origin))';
            end
        end
        clear BL_list
    end
end


end
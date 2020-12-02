% JOINTDEFINITIONS_AUTO2020 Define the orientation of the
% parent reference system in the ankle joint using the ankle axis as Z axis
% and the long axis of the tibia (made perpendicular to Z) as Y axis. X
% defined by cross-product. The ankle is the only joint that is not defined
% neither in parent or child in the "default" joint definition named 
% 'auto2020'.
%
%   jointStruct = jointDefinitions_auto2020(JCS, jointStruct)
%
% Inputs:
%   JCS - structure with the joint parameters produced by the morphological 
%       analyses of processTriGeomBoneSet.m. Not all listed joints are
%       actually modellable, in the sense that the parent and child
%       reference systems might not be present, the model might be
%       incomplete etc. In this function only the field `V` relative to 
%       talus and tibia will be recalled
%
%   jointStruct - MATLAB structure including all the reference parameters
%       that will be used to generate an OpenSim JointSet. 
%
% Outputs:
%   jointStruct - updated MATLAB structure with a newly defined ankle 
%       joint parent ankle V.
%
% See also CREATESPATIALTRANSFORMFROMSTRUCT.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function jointStruct = jointDefinitions_auto2020(JCS, jointStruct)

side_low = inferBodySideFromAnatomicStruct(JCS);

% bone names
tibia_name      = ['tibia_',side_low];
talus_name      = ['talus_',side_low];

% joint names
ankle_name = ['ankle_', side_low];
knee_name = ['knee_', side_low];

% joint params: JCS.(bone_name) will access the geometrical information
% from the morphological analysis

% take Z from ankle joint (axis of rotation)
if isfield(JCS, talus_name) && isfield(JCS, tibia_name)
    Zpar  = normalizeV(JCS.(talus_name).(ankle_name).V(:,3));
    Ytemp = JCS.(tibia_name).(knee_name).V(:,2);
    % Y and Z orthogonal
    Ypar = normalizeV(Ytemp - Zpar* dot(Zpar,Ytemp)/norm(Zpar));
    Xpar = normalizeV(cross(Ytemp, Zpar));
    
    % assigning pose matrix and parent orientation
    jointStruct.(ankle_name).V = [Xpar Ypar Zpar];
    jointStruct.(ankle_name).parent_orientation = computeXYZAngleSeq(jointStruct.(ankle_name).V);
else
    return
end
end
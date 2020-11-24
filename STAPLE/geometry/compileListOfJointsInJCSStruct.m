% COMPILELISTOFJOINTSINJCSSTRUCT Create a list of joints that can be 
% modelled from the structure that results from morphological analysis.
%
%   joint_list = compileListOfJointsInJCSStruct(JCS)
%
% Inputs:
%   JCS - structure with the joint parameters produced by the morphological 
%       analyses of processTriGeomBoneSet.m. Not all listed joints are
%       actually modellable, in the sense that the parent and child
%       reference systems might not be present, the model might be
%       incomplete etc.
%
% Outputs:
%   joint_list - a cell array with a list of unique elements. Each element
%       is the name of a joint present in the JCS structure.
%
%
% See also CREATEOPENSIMMODELJOINTS, PROCESSTRIGEOMBONESET.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function joint_list = compileListOfJointsInJCSStruct(JCS)
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
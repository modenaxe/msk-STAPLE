% INFERBODYSIDEFROMANATOMICSTRUCT Infer the body side that the user wants
% to process based on a structure containing the anatomical objects
% (triangulations or joint definitions) given as input. The implemented
% logic is trivial: the fields are checked for standard names of bones and
% joints used in OpenSim models.
%
%   guessed_side = inferBodySideFromAnatomicStruct(anat_struct)
%
% Inputs:
%   anat_struct - a MATLAB structure containing anatomical objects, e.g. a
%       set of bone triangulation or joint definitions.
%
% Outputs:
%   guessed_side - a body side label that can be used in all other STAPLE
%       functions requiring such input.
%
% See also CREATELOWERLIMBJOINTS, GETJOINTPARAMS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese & Jean-Baptiste Renault. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function guessed_side = inferBodySideFromAnatomicStruct(anat_struct)

if isstruct(anat_struct)
    % check using the bone names
    fields_side = fields(anat_struct);
elseif iscell(anat_struct)
    fields_side = anat_struct;
else
    error('inferBodySideFromAnatomicStruct.m  Input must be structure or cell array.')
end
body_set = {'femur', 'tibia', 'talus', 'calcn'};
ng_b = 1;
guess_side_b = '';
for nb = 1:length(body_set)
    cur_body = body_set{nb};
    ind_b = strncmp( fields_side, cur_body, length(cur_body));
    if sum(ind_b)>0
        guess_side_b(ng_b) = fields_side{ind_b}(end);
        ng_b = ng_b+1;
    else
        continue
    end
end

% check using the joint names
joint_set = {'hip', 'knee', 'ankle', 'subtalar'};
ng_j = 1;
guess_side_j = '';
for nj = 1:length(joint_set)
    cur_joint = joint_set{nj};
    ind_j = strncmp( fields_side, cur_joint, length(cur_joint));
    if sum(ind_j)>0
        guess_side_j(ng_j) = fields_side{ind_j}(end);
        ng_j = ng_j+1;
    else
        continue
    end

end
% composed vectors
combined_guessed = [guess_side_b, guess_side_j];

if strcmpi(unique(combined_guessed), 'r')
    guessed_side = 'r';
elseif strcmpi(unique(combined_guessed), 'l')
    guessed_side = 'l';
else
    error('guessBodySideFromAnatomicStruct.m Error: it was not possible to infer the body side. Please specify it manually in this occurrance.');
end
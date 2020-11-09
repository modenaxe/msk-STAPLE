% ASSEMBLEANKLEPARENTORIENTATIONMODENESE2018 Define the orientation of
% parent in the ankle joint as in Modenese et al. JBiomech 2018.
% Required for the comparison presented in Modenese and Renault, JBiomech
% 2020.
%
%   TibiaStruct = assembleAnkleParentOrientationModenese2018(TibiaStruct, TalusStruct)
%
% Inputs:
%   TibiaStruct - structure including all the reference system and results
%       of the geometrical analysis on the tibia.
%
%   TalusStruct - structure including all the reference system and results
%       of the geometrical analysis on the talus.
%
% Outputs:
%   TibiaStruct - MATLAB structure with the updated tibia reference system.
%
% See also CREATESPATIALTRANSFORMFROMSTRUCT, ASSEMBLESUBTALARPARENTORIENTATIONMODENESE2018.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function TibiaStruct = assembleAnkleParentOrientationModenese2018(TibiaStruct, TalusStruct, side_raw)

if nargin<3
    % guess side from structure: it should be ok, as processTriGeomBoneSet uses
    % field that end with side.
    side = inferBodySideFromAnatomicStruct(TalusStruct);
else
    [~, side] = bodySide2Sign(side_raw);
end

% joint names
ankle_name = ['ankle_', side];
knee_name = ['knee_', side];

% take Z from ankle joint (axis of rotation)
Zparent  = TalusStruct.(ankle_name).V(:,3);

% take line joining talus and knee centres
if isequal(size(TibiaStruct.(knee_name).Origin), [1, 3])
    TibiaStruct.(knee_name).Origin = TibiaStruct.(knee_name).Origin';
end
Ytemp = (TibiaStruct.(knee_name).Origin - TalusStruct.(ankle_name).Origin)/...
    norm(TibiaStruct.(knee_name).Origin - TalusStruct.(ankle_name).Origin);

% Y and Z orthogonal
Yparent = normalizeV(Ytemp - Zparent* dot(Zparent,Ytemp)/norm(Zparent));
Xparent  = normalizeV(cross(Ytemp, Zparent));

% assigning pose matrix and parent orientation
TibiaStruct.(ankle_name).V = [Xparent Yparent Zparent];
TibiaStruct.(ankle_name).parent_orientation = computeXYZAngleSeq(TibiaStruct.(ankle_name).V);
end
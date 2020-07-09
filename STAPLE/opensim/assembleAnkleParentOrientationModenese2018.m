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

function TibiaStruct = assembleAnkleParentOrientationModenese2018(TibiaStruct, TalusStruct)

% take Z from ankle joint (axis of rotation)
Zparent  = TalusStruct.ankle_r.V(:,3);

% take line joining talus and knee centres
if isequal(size(TibiaStruct.knee_r.Origin), [1, 3])
    TibiaStruct.knee_r.Origin = TibiaStruct.knee_r.Origin';
end
Ytemp = (TibiaStruct.knee_r.Origin - TalusStruct.ankle_r.Origin)/...
    norm(TibiaStruct.knee_r.Origin - TalusStruct.ankle_r.Origin);

% Y and Z orthogonal
Yparent = normalizeV(Ytemp - Zparent* dot(Zparent,Ytemp)/norm(Zparent));
Xparent  = normalizeV(cross(Ytemp, Zparent));

% assigning pose matrix and parent orientation
TibiaStruct.ankle_r.V = [Xparent Yparent Zparent];
TibiaStruct.ankle_r.parent_orientation = computeXYZAngleSeq(TibiaStruct.ankle_r.V);
end
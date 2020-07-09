% ASSEMBLEKNEECHILDORIENTATIONMODENESE2018 Define the orientation of
% child in the knee joint as in Modenese et al. JBiomech 2018.
% Required for the comparison presented in Modenese and Renault, JBiomech
% 2020.
%
%   TibiaStruct = assembleKneeChildOrientationModenese2018(FemurStruct, TibiaStruct, TalusStruct)
%
% Inputs:
%   FemurStruct - structure including all the reference system and results
%       of the geometrical analysis on the femur.
%
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
function TibiaStruct = assembleKneeChildOrientationModenese2018(FemurStruct, TibiaStruct, TalusStruct)

% take Z from knee joint (axis of rotation)
Zparent  = FemurStruct.knee_r.V(:,3);

% take line joining talus and knee centres
if isequal(size(FemurStruct.knee_r.Origin), [1, 3])
    TibiaStruct.knee_r.Origin = FemurStruct.knee_r.Origin';
else
    TibiaStruct.knee_r.Origin = FemurStruct.knee_r.Origin;
end

% vertical axis joining knee and ankle joint centres
Ytemp = (TibiaStruct.knee_r.Origin - TalusStruct.ankle_r.Origin)/...
    norm(TibiaStruct.knee_r.Origin - TalusStruct.ankle_r.Origin);

% Y and Z orthogonal
Yparent = normalizeV(Ytemp - Zparent* dot(Zparent,Ytemp)/norm(Zparent));
Xparent  = normalizeV(cross(Ytemp, Zparent));

% assigning pose matrix and child orientation
TibiaStruct.knee_r.V = [Xparent Yparent Zparent];
TibiaStruct.knee_r.child_orientation = computeXYZAngleSeq(TibiaStruct.knee_r.V);

end
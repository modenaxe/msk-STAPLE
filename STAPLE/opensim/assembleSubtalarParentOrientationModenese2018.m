% ASSEMBLESUBTALARPARENTORIENTATIONMODENESE2018 Define the orientation of
% parent in the subtalar joint as in Modenese et al. JBiomech 2018.
% Required for the comparison presented in Modenese and Renault, JBiomech
% 2020.
%
%   TalusStruct = assembleSubtalarParentOrientationModenese2018(FemurStruct, TalusStruct)
%
% Inputs:
%   FemurStruct - structure including all the reference system and results
%       of the geometrical analysis on the femur.
%
%   TalusStruct - structure including all the reference system and results
%       of the geometrical analysis on the talus.
%
% Outputs:
%   TalusStruct - updated MATLAB structure with the talus reference systems
%
% See also CREATESPATIALTRANSFORMFROMSTRUCT.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function TalusStruct = assembleSubtalarParentOrientationModenese2018(FemurStruct, TalusStruct)

% take Z from subtalar joint (axis of rotation)
Zparent  = TalusStruct.subtalar_r.V(:,3);

% take Y pointing to the knee joint centre
Ytemp = (FemurStruct.knee_r.parent_location - TalusStruct.subtalar_r.parent_location)/...
        norm((FemurStruct.knee_r.parent_location - TalusStruct.subtalar_r.parent_location));

% X and Z orthogonal
Yparent = normalizeV(Ytemp' - Zparent* dot(Zparent,Ytemp')/norm(Zparent));
Xparent  = normalizeV(cross(Yparent, Zparent));

% assigning pose matrix and parent orientation
TalusStruct.subtalar_r.V = [Xparent Yparent Zparent];
TalusStruct.subtalar_r.parent_orientation = computeXYZAngleSeq(TalusStruct.subtalar_r.V);

end
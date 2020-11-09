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
function TalusStruct = assembleSubtalarParentOrientationModenese2018(FemurStruct, TalusStruct, side_raw)

if nargin<3
    % guess side from structure: it should be ok, as processTriGeomBoneSet uses
    % field that end with side.
    side = inferBodySideFromAnatomicStruct(FemurStruct);
else
    [~, side] = bodySide2Sign(side_raw);
end

% joint names
subtalar_name = ['subtalar_', side];
knee_name = ['knee_', side];

% take Z from subtalar joint (axis of rotation)
Zparent  = TalusStruct.(subtalar_name).V(:,3);

% take Y pointing to the knee joint centre
Ytemp = (FemurStruct.(knee_name).parent_location - TalusStruct.(subtalar_name).parent_location)/...
        norm((FemurStruct.(knee_name).parent_location - TalusStruct.(subtalar_name).parent_location));

% X and Z orthogonal
Yparent = normalizeV(Ytemp' - Zparent* dot(Zparent,Ytemp')/norm(Zparent));
Xparent  = normalizeV(cross(Yparent, Zparent));

% assigning pose matrix and parent orientation
TalusStruct.(subtalar_name).V = [Xparent Yparent Zparent];
TalusStruct.(subtalar_name).parent_orientation = computeXYZAngleSeq(TalusStruct.(subtalar_name).V);

end
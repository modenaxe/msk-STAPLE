% ASSEMBLEANKLECHILDORIENTATIONMODENESE2018 Define the orientation of
% child in the ankle joint as in Modenese et al. JBiomech 2018.
% Required for the comparison presented in Modenese and Renault, JBiomech
% 2020.
%
%   TalusStruct = assembleAnkleChildOrientationModenese2018(TalusStruct, CalcnStruct)
%
% Inputs:
%   TalusStruct - structure including all the reference system and results
%       of the geometrical analysis on the talus.
%
%   CalcnStruct - structure including all the reference system and results
%       of the geometrical analysis on the calcaneus/foot.
%
% Outputs:
%   TalusStruct - MATLAB structure with the updated talus reference system.
%
% See also CREATESPATIALTRANSFORMFROMSTRUCT, ASSEMBLESUBTALARPARENTORIENTATIONMODENESE2018.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function TalusStruct = assembleAnkleChildOrientationModenese2018(TalusStruct, CalcnStruct)

% take Z from ankle joint (axis of rotation)
Zchild  = normalizeV(TalusStruct.ankle_r.V(:,3));

% take X ant-post axis of the calcaneus
Xtemp = CalcnStruct.V(:,1);

% X and Z orthogonal
Xchild = normalizeV(Xtemp - Zchild* dot(Zchild,Xtemp)/norm(Zchild));
Ychild  = normalizeV(cross(Zchild, Xtemp));

% assigning pose matrix and child orientation
TalusStruct.ankle_r.V = [Xchild Ychild Zchild];
TalusStruct.ankle_r.child_orientation = computeXYZAngleSeq(TalusStruct.ankle_r.V);


end
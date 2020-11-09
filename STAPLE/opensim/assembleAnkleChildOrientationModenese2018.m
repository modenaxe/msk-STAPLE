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
function TalusStruct = assembleAnkleChildOrientationModenese2018(TalusStruct, CalcnStruct, side_raw)

if nargin<3
    % guess side from structure: it should be ok, as processTriGeomBoneSet uses
    % field that end with side.
    side = inferBodySideFromAnatomicStruct(TalusStruct);
else
    [~, side] = bodySide2Sign(side_raw);
end

% joint names
ankle_name = ['ankle_', side];

% take Z from ankle joint (axis of rotation)
Zchild  = normalizeV(TalusStruct.(ankle_name).V(:,3));

% take X ant-post axis of the calcaneus
Xtemp = CalcnStruct.V(:,1);

% X and Z orthogonal
Xchild = normalizeV(Xtemp - Zchild* dot(Zchild,Xtemp)/norm(Zchild));
Ychild  = normalizeV(cross(Zchild, Xtemp));

% assigning pose matrix and child orientation
TalusStruct.(ankle_name).V = [Xchild Ychild Zchild];
TalusStruct.(ankle_name).child_orientation = computeXYZAngleSeq(TalusStruct.(ankle_name).V);


end
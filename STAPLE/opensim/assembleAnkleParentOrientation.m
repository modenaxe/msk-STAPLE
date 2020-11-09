% ASSEMBLEANKLEPARENTORIENTATION Define the orientation of the
% parent reference system in the ankle joint using the ankle axis as Z axis
% and the long axis of the tibia (made perpendicular to Z) as Y axis. X
% defined by cross-product. This is the generic automatic method (not based
% on Modenese et al. JBiomech 2018).
%
%   TibiaStruct = assembleAnkleParentOrientation(TibiaStruct, TalusStruct)
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
% See also CREATESPATIALTRANSFORMFROMSTRUCT.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function TibiaStruct = assembleAnkleParentOrientation(TibiaStruct, TalusStruct, side_raw)

if nargin<3
    % guess side from structure: it should be ok, as processTriGeomBoneSet uses
    % field that end with side.
    side = inferBodySideFromAnatomicStruct(TibiaStruct);
else
    [~, side] = bodySide2Sign(side_raw);
end

% joint names
ankle_name = ['ankle_', side];
knee_name = ['knee_', side];

% take Z from ankle joint (axis of rotation)
Zpar  = normalizeV(TalusStruct.(ankle_name).V(:,3));

% take vertical axis of the tibia
Ytemp = TibiaStruct.(knee_name).V(:,2);

% Y and Z orthogonal
Ypar = normalizeV(Ytemp - Zpar* dot(Zpar,Ytemp)/norm(Zpar));
Xpar = normalizeV(cross(Ytemp, Zpar));

% assigning pose matrix and parent orientation
TibiaStruct.(ankle_name).V = [Xpar Ypar Zpar];
TibiaStruct.(ankle_name).parent_orientation = computeXYZAngleSeq(TibiaStruct.(ankle_name).V);

end
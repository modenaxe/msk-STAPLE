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
function jointStruct = jointDefinitions_auto2020(JCS, jointStruct)

side_low = inferBodySideFromAnatomicStruct(JCS);

% bone names
tibia_name      = ['tibia_',side_low];
talus_name      = ['talus_',side_low];
% joint names
ankle_name = ['ankle_', side_low];
knee_name = ['knee_', side_low];
% joint params
TibiaStruct = JCS.(tibia_name);
TalusStruct = JCS.(talus_name);

% take Z from ankle joint (axis of rotation)
Zpar  = normalizeV(TalusStruct.(ankle_name).V(:,3));

% take vertical axis of the tibia
Ytemp = TibiaStruct.(knee_name).V(:,2);

% Y and Z orthogonal
Ypar = normalizeV(Ytemp - Zpar* dot(Zpar,Ytemp)/norm(Zpar));
Xpar = normalizeV(cross(Ytemp, Zpar));

% assigning pose matrix and parent orientation
jointStruct.(ankle_name).V = [Xpar Ypar Zpar];
jointStruct.(ankle_name).parent_orientation = computeXYZAngleSeq(jointStruct.(ankle_name).V);
end
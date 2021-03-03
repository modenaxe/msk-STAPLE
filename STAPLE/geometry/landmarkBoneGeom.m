% LANDMARKBONEGEOM Locate points on the surface of triangulation objects
% that are bone geometries.
%
%   Landmarks = landmarkBoneGeom(TriObj, CS, bone_name, debug_plots)
%
% Inputs:
%   TriObj - a triangulation object.
%
%   CS - a structure representing a coordinate systems as a structure with 
%        'Origin' and 'V' fields, indicating the origin and the axis. 
%        In 'V', each column is the normalise direction of an axis 
%        expressed in the global reference system (CS.V = [x, y, z]).
%
%   bone_name - string identifying a lower limb bone. Valid values are:
%   'pelvis', 'femur_r', 'tibia_r', 'patella_r', 'calcn_r'.
%
%   debug_plots - takes value 1 or 0. Plots the steps of the landmarking
%       process. Switched off by default, useful for debugging.
%
% Outputs:
%   Landmarks - structure with as many fields as the landmarks defined in
%       getBoneLandmarkList.m. Each field has the name of the landmark and
%       value the 3D coordinates of the landmark point.
%
% See also GETBONELANDMARKLIST, FINDLANDMARKCOORDS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese, 2020
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function Landmarks = landmarkBoneGeom(TriObj, CS, bone_name, debug_plots)

% better LandmarkBoneTriGeom

% by default do not plot landmarking
if nargin<4; debug_plots = 0; end

% get info about the landmarks in the current bone
LandmarkStruct = getBoneLandmarkList(bone_name);

% change reference system to bone/body reference system
TriObj_in_CS = TriChangeCS(TriObj, CS.V, CS.CenterVol);

% visualise the bone in the bone/body ref system
if debug_plots == 1
%     figure()
    % create coordinate system centred in [0, 0 ,0] and with unitary axis
    % directly along the direction of the ground ref system
    LocalCS        = struct();
    LocalCS.Origin = [0 0 0]';
    LocalCS.V      = eye(3);
    % close all
    plotTriangLight(TriObj_in_CS, LocalCS, 1); hold on
    quickPlotRefSystem(LocalCS);
end

% get points from the triangulation
TriPoints = TriObj_in_CS.Points;

% TODO replace with CentreVol 
% COM = [0 0 0]';

% define proximal or distal:
% 1) considers Y the longitudinal direction
% 2) dividing the bone in three parts
ub = max(TriPoints(:,2))*0.3;
lb = max(TriPoints(:,2))*(-0.3);
if debug_plots == 1
    figure()
    title('proximal (blue) and distal (red) geom')
    % check proximal geometry
    check_proximal = TriPoints(TriPoints(:,2)>ub,:);
    plot3(check_proximal(:,1), check_proximal(:,2), check_proximal(:,3),'b.'); axis equal
    % check distal geometry
    check_distal = TriPoints(TriPoints(:,2)<lb,:);
    plot3(check_distal(:,1), check_distal(:,2), check_distal(:,3),'r.'); axis equal
end

NL = numel(LandmarkStruct);
for nL = 1:NL
    % get info cur_BL_info to identify the current landmark (cell array):
    cur_BL_info = LandmarkStruct{nL};
    % extract info (see LandmarkStruct for details)
    cur_BL_name = cur_BL_info{1}; %landmark name
    cur_axis    = cur_BL_info{2}; %x/y/z
    cur_operator= cur_BL_info{3}; %min/max
    cur_bone_extremity = cur_BL_info(end);
    
    % is the BL proximal or distal?
    if strcmp(cur_bone_extremity, 'proximal')
        % identify the landmark
        local_BL = findLandmarkCoords(TriPoints(TriPoints(:,2)>ub,:), cur_axis, cur_operator);
    elseif strcmp(cur_bone_extremity, 'distal')
        % identify the landmark
        local_BL = findLandmarkCoords(TriPoints(TriPoints(:,2)<lb,:), cur_axis, cur_operator);
    else
        % get landmark if no bone extremity is specified
        local_BL = findLandmarkCoords(TriPoints, cur_axis, cur_operator);
    end
    
    % plot marker (still in local ref system)
    if debug_plots == 1
        plotDot(local_BL,'r',4);
    end
    
    % dimensionality check
    if ~isequal(size(CS.CenterVol),[3,1])
        error('CenterVol dimensionality error, it should be [3x1]');
    end
    
    % save a landmark structure (transform back to global)
    Landmarks.(cur_BL_name) = CS.CenterVol+CS.V*local_BL';
end

end

% JOINTDEFINITIONS_MODENESE2018 Define the orientation of
% lower limb joints as in Modenese et al. JBiomech 2018, 17;73:108-118
% https://doi.org/10.1016/j.jbiomech.2018.03.039
% Required for the comparisons presented in Modenese and Renault, JBiomech
% 2020.
%
%   jointStruct = jointDefinitions_Modenese2018(JCS, jointStruct)
%
% Inputs:
%   JCS - structure with the joint parameters produced by the morphological
%       analyses of processTriGeomBoneSet.m. Not all listed joints are
%       actually modellable, in the sense that the parent and child
%       reference systems might not be present, the model might be
%       incomplete etc.
%
%   jointStruct - structure with the joint parameters ready to be passed to
%       createCustomJointFromStruct.m for creating the OpenSim CustomJoints
%
% Outputs:
%   jointStruct - updated jointStruct with the joints defined as in
%       Modenese2018, rather than connected directly using the joint
%       coordinate system computed in processTriGeomBoneSet.m plus the
%       default joint definition available in jointDefinitions_auto2020.m
%
% See also  CREATEOPENSIMMODELJOINTS, CREATECUSTOMJOINTFROMSTRUCT,
%           PROCESSTRIGEOMBONESET.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function jointStruct = jointDefinitions_Modenese2018(JCS, jointStruct)

side_low = inferBodySideFromAnatomicStruct(JCS);

% joint names
% hip_name      = ['hip_',side_low];
knee_name     = ['knee_',side_low];
ankle_name    = ['ankle_',side_low];
subtalar_name = ['subtalar_',side_low];
% patellofemoral_name = ['patellofemoral_',side_low];

% segment names
femur_name      = ['femur_',side_low];
tibia_name      = ['tibia_',side_low];
talus_name      = ['talus_',side_low];
calcn_name      = ['calcn_',side_low];
mtp_name        = ['mtp_', side_low];
% patella_name    = ['patella_',side_low];

if isfield(JCS, talus_name)
    TalusStruct = JCS.(talus_name);
    
    if isfield(JCS, tibia_name)
        TibiaStruct = JCS.(tibia_name);
        
        if isfield(JCS, femur_name)
            FemurStruct = JCS.(femur_name);
            
            % Knee child orientation
            %---------------------
            % Z aligned like the medio-lateral femoral joint, e.g. axis of cylinder
            % Y aligned with the tibial axis (v betw origin of ankle and knee)
            % X from cross product
            %---------------------
            
            % take Z from knee joint (axis of rotation)
            Zparent  = FemurStruct.(knee_name).V(:,3);
            % take line joining talus and knee centres
            TibiaStruct.(knee_name).Origin = FemurStruct.(knee_name).Origin;
            % vertical axis joining knee and ankle joint centres (same used for ankle
            % parent)
            Ytemp = (TibiaStruct.(knee_name).Origin - TalusStruct.(ankle_name).Origin)/...
                norm(TibiaStruct.(knee_name).Origin - TalusStruct.(ankle_name).Origin);
            % make Y and Z orthogonal
            Yparent = normalizeV(Ytemp - Zparent* dot(Zparent,Ytemp)/norm(Zparent));
            Xparent  = normalizeV(cross(Ytemp, Zparent));
            % assigning pose matrix and child orientation
            jointStruct.(knee_name).child_orientation = computeXYZAngleSeq([Xparent Yparent Zparent]);
        end
        
        % Ankle parent orientation
        %---------------------
        % Z aligned like the cilinder of the talar throclear
        % Y aligned with the tibial axis (v betw origin of ankle and knee)
        % X from cross product
        %---------------------
        % take Z from ankle joint (axis of rotation)
        Zparent  = normalizeV(TalusStruct.(ankle_name).V(:,3));
        % take line joining talus and knee centres
        TibiaStruct.(knee_name).Origin = TibiaStruct.(knee_name).Origin;
        Ytibia = (TibiaStruct.(knee_name).Origin - TalusStruct.(ankle_name).Origin)/...
            norm(TibiaStruct.(knee_name).Origin - TalusStruct.(ankle_name).Origin);
        % make Y and Z orthogonal
        Yparent = normalizeV(Ytibia - Zparent* dot(Zparent,Ytibia)/norm(Zparent));
        Xparent  = normalizeV(cross(Ytibia, Zparent));
        % assigning pose matrix and parent orientation
        jointStruct.(ankle_name).parent_orientation = computeXYZAngleSeq([Xparent Yparent Zparent]);
    end
    
    % Ankle child orientation:
    %---------------------
    % Z aligned like the cilinder of the talar throclear
    % X like calcaneus, but perpendicular to Z
    % Y from cross product
    %---------------------
    if isfield(JCS, calcn_name)
        CalcnStruct = JCS.(calcn_name);
        % take Z from ankle joint (axis of rotation)
        Zchild  = normalizeV(TalusStruct.(ankle_name).V(:,3));
        % take X ant-post axis of the calcaneus
        Xtemp = CalcnStruct.(mtp_name).V(:,1);
        % make X and Z orthogonal
        Xchild = normalizeV(Xtemp - Zchild* dot(Zchild,Xtemp)/norm(Zchild));
        Ychild  = normalizeV(cross(Zchild, Xtemp));
        % assign child orientation
        jointStruct.(ankle_name).child_orientation = computeXYZAngleSeq([Xchild Ychild Zchild]);
    end
    
    % talus + femur
    % Subtalar parent orientation
    %---------------------
    % Z is the subtalar axis of rotation
    % Y from centre of subtalar joint points to femur joint centre
    % X from cross product
    %---------------------
    if isfield(JCS, femur_name)
        % needs to be initialized? 
        FemurStruct = JCS.(femur_name);
        % take Z from subtalar joint (axis of rotation)
        Zparent  = TalusStruct.(subtalar_name).V(:,3);
        % take Y pointing to the knee joint centre
        Ytemp = (FemurStruct.(knee_name).parent_location - TalusStruct.(subtalar_name).parent_location)/...
            norm((FemurStruct.(knee_name).parent_location - TalusStruct.(subtalar_name).parent_location));
        % make Y and Z orthogonal
        Yparent = normalizeV(Ytemp' - Zparent* dot(Zparent,Ytemp')/norm(Zparent));
        Xparent  = normalizeV(cross(Yparent, Zparent));
        % assigning parent orientation
        jointStruct.(subtalar_name).parent_orientation = computeXYZAngleSeq([Xparent Yparent Zparent]);
    end
    
end

end
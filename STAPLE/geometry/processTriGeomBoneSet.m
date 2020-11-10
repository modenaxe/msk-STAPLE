% PROCESSTRIGEOMBONESET Compute parameters of the lower limb joints
% associated with the bone geometries provided as input through a set of 
% MATLAB triangulations. Note that:
% 1) This function does not produce a complete set of joint parameters but
% only those available through geometrical analyses, that are:
%       * from pelvis: ground_pelvis_child
%       * from femur : hip_child  // knee_parent
%       * from tibia : knee_child** 
%       * from talus : ankle_child // subtalar parent
% other functions then complete the information required to generate a MSK
% model, e.g. use ankle child location and ankle axis to define an ankle
% parent reference system etc.
% ** note that the tibia geometry was not used to define the knee child 
% anatomical coord system in the approach of Modenese et al. JB 2018.
% 2) Bony landmarks are identified on all bones except the talus.
% 3) Body-fixed Cartesian coordinate system are defined but not employed in
% the construction of the models.
% 
%   [JCS, BL, CS] = processTriGeomBoneSet(geom_set, method_pelvis,...
%                                         method_femur, method_tibia, in_mm)
%
% Inputs:
%   geom_set - a set of MATLAB triangulation objects, normally created
%       using the function createTriGeomSet. See that function for more
%       details.
% 
%   method_pelvis - the algorithm selected to process the pelvis geometry.
% 
%   method_femur - the algorithm selected to process the femur geometry.
% 
%   method_tibia - the algorithm selected to process the tibial geometry.
%       
%   in_mm - (optional) indicates if the provided geometries are given in mm
%       (value: 1) or m (value: 0). Please note that all tests and analyses
%       done so far were performed on geometries expressed in mm, so this
%       option is more a placeholder for future adjustments.
% 
% Outputs:
%   JCS - structure collecting the parameters of the joint coordinate
%       systems computed on the bone triangulations.
%
%   BL - structure collecting the bone landmarks identified on the
%       three-dimensional bone surfaces.
%
%   CS - structure collecting the body coordinate systems of the processed
%       bones.
% 
% See also CREATETRIGEOMSET, ADDBODIESFROMTRIGEOMBONESET.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

% DESIGN NOTE FOR FUTURE, FORGETFUL ME
%--------------------------------------------------------------------------
% I thought about the structure of the JCS output structure variable.
% Currently it is:
%                   JCS.body_name.joint_name.parameter
% and could have been:
%                   JCS.joint_name.parameter
% I think the first option is better and will allow for better structures to
% save all model info in one structure, e.g.
%       Model.BodyName.(all_CS_fields)
%       Model.BodyName.(all_joints)
%       Model.BodyName.(all_BL)
% so that all params that has been processed here are immediately available
%--------------------------------------------------------------------------


function [JCS, BL, CS] = processTriGeomBoneSet(geom_set, side_raw, algo_pelvis, algo_femur, algo_tibia, result_plots, debug_plots, in_mm)

% setting defaults
if nargin<2
    side = inferBodySideFromAnatomicStruct(geom_set);
else
    % get sign correspondent to body side
    [~, side] = bodySide2Sign(side_raw);
end
if nargin<3; algo_pelvis = 'STAPLE'; algo_femur = ''; algo_tibia = 'Kai'; in_mm = 1; end
if nargin<4; algo_femur = ''; algo_tibia = 'Kai'; in_mm = 1; end
if nargin<5; algo_tibia = 'Kai'; in_mm = 1; end
if nargin<6; result_plots = 1; end
if nargin<7; debug_plots = 0; end
if nargin<8; in_mm = 1; end

disp('-----------------------------------')
disp('Processing provided bone geometries')
disp('-----------------------------------')

% ---- PELVIS -----
if isfield(geom_set,'pelvis')
    switch algo_pelvis
        case 'STAPLE'
            [CS.pelvis, JCS.pelvis, BL.pelvis]  = ...
                STAPLE_pelvis(geom_set.pelvis, side, result_plots, debug_plots, in_mm);
        case 'Kai'
            [CS.pelvis, JCS.pelvis, BL.pelvis]  = ...
                Kai2014_pelvis(geom_set.pelvis, side, result_plots, debug_plots, in_mm);
    end
elseif isfield(geom_set,'pelvis_no_sacrum')
    switch algo_pelvis
        case 'STAPLE'
            [CS.pelvis, JCS.pelvis, BL.pelvis]  = ...
                STAPLE_pelvis(geom_set.pelvis_no_sacrum, side, result_plots, debug_plots, in_mm);
        case 'Kai'
            [CS.pelvis, JCS.pelvis, BL.pelvis]  = ...
                Kai2014_pelvis(geom_set.pelvis_no_sacrum, side, result_plots, debug_plots, in_mm);
    end
end

% ---- FEMUR -----
femur_name = ['femur_', side];
if isfield(geom_set, femur_name)
    switch algo_femur
%         case 'Miranda'
%             [CS.(femur_name), JCS.(femur_name), BL.(femur_name)] = Miranda2010_buildfACS(geom_set.(femur_name));
        case 'Kai'
            [CS.(femur_name), JCS.(femur_name), BL.(femur_name)] = ...
                Kai2014_femur(geom_set.(femur_name), side);
        case 'GIBOC-spheres'
            [CS.(femur_name), JCS.(femur_name), BL.(femur_name)] = ...
                GIBOC_femur(geom_set.(femur_name), side, 'spheres', result_plots, debug_plots, in_mm);
        case 'GIBOC-ellipsoids'
            [CS.(femur_name), JCS.(femur_name), BL.(femur_name)] = ....
                GIBOC_femur(geom_set.(femur_name), side, 'ellipsoids', result_plots, debug_plots, in_mm);
        case 'GIBOC-cylinder'
            [CS.(femur_name), JCS.(femur_name), BL.(femur_name)] = ...
                GIBOC_femur(geom_set.(femur_name), side, 'cylinder', result_plots, debug_plots, in_mm);
        otherwise
            [CS.(femur_name), JCS.(femur_name), BL.(femur_name)] = ...
                GIBOC_femur(geom_set.(femur_name), side, 'cylinder', result_plots, debug_plots, in_mm);
    end
end

%---- TIBIA -----
tibia_name = ['tibia_', side];
if isfield(geom_set, tibia_name)
    switch algo_tibia
%         case 'Miranda' % same as Kai but using inertia
%             [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = Miranda2010_buildtACS(geom_set.tibia_r);
        case 'Kai'
            [CS.(tibia_name), JCS.(tibia_name), BL.(tibia_name)] = ...
                Kai2014_tibia(geom_set.(tibia_name), side, result_plots, debug_plots, in_mm);
        case 'GIBOC-plateau'
            [CS.(tibia_name), JCS.(tibia_name), BL.(tibia_name)] = ...
                GIBOC_tibia(geom_set.(tibia_name), side, 'plateau', result_plots, debug_plots, in_mm);
        case 'GIBOC-ellipse'
            [CS.(tibia_name), JCS.(tibia_name), BL.(tibia_name)] = ...
                GIBOC_tibia(geom_set.(tibia_name), side, 'ellipse', result_plots, debug_plots, in_mm);
        case 'GIBOC-centroids'
            [CS.(tibia_name), JCS.(tibia_name), BL.(tibia_name)] = ...
                GIBOC_tibia(geom_set.(tibia_name), side, 'centroids', result_plots, debug_plots, in_mm);
        otherwise
            [CS.(tibia_name), JCS.(tibia_name), BL.(tibia_name)] = ....
                Kai2014_tibia(geom_set.(tibia_name), side, result_plots, debug_plots, in_mm);
    end
end


%---- PATELLA -----
patella_name = ['patella_', side];
if isfield(geom_set, patella_name)
    switch method_patella
        case 'Rainbow'
            [CS.(patella_name), JCS.(patella_name), BL.(patella_name)] = Rainbow2013_buildpACS();
        case 'GIBOC-vol-ridge'
            [CS.(patella_name), JCS.(patella_name), BL.(patella_name)] = GIBOC_patella(geom_set.(patella_name), 'volume-ridge');
        case 'GIBOC-ridge'
            [CS.(patella_name), JCS.(patella_name), BL.(patella_name)] = GIBOC_patella(geom_set.(patella_name), 'ridge-line');
        case 'GIBOC-ACS'
            [CS.(patella_name), JCS.(patella_name), BL.(patella_name)] = GIBOC_patella(geom_set.(patella_name), 'artic-surf');
        otherwise
            % error('choose coorect patellar algorithm');
    end
                
end
    
%---- TALUS/ANKLE -----
talus_name = ['talus_', side];
if isfield(geom_set,talus_name)
    [CS.(talus_name), JCS.(talus_name)] = ...
        STAPLE_talus(geom_set.(talus_name), side, result_plots,  debug_plots, in_mm);
end

%---- CALCANEUS/SUBTALAR -----
calcn_name = ['calcn_', side];
if isfield(geom_set,calcn_name)
    [CS.(calcn_name), JCS.(calcn_name), BL.(calcn_name)] =...
        STAPLE_foot(geom_set.(calcn_name), side, result_plots,  debug_plots, in_mm);
end

end
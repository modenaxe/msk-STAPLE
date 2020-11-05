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


function [JCS, BL, CS] = processTriGeomBoneSet(geom_set, method_pelvis, method_femur, method_tibia, in_mm)

% setting defaults
if nargin<2; method_pelvis = 'STAPLE'; method_femur = ''; method_tibia = ''; in_mm = 1; end
if nargin<3; method_femur = ''; method_tibia = ''; in_mm = 1; end
if nargin<4; method_tibia = ''; in_mm = 1; end
if nargin<5; in_mm = 1; end

disp('-----------------------------------')
disp('Processing provided bone geometries')
disp('-----------------------------------')

% ---- PELVIS -----
if isfield(geom_set,'pelvis')
    switch method_pelvis
        case 'STAPLE'
            [CS.pelvis, JCS.pelvis, BL.pelvis]  = STAPLE_pelvis(geom_set.pelvis, in_mm);
        case 'Kai'
            [CS.pelvis, JCS.pelvis, BL.pelvis]  = Kai2014_pelvis(geom_set.pelvis, 1, 0, 1);
    end
    %     addMarkersFromStruct(osimModel, 'pelvis', BL.pelvis, in_mm);
elseif isfield(geom_set,'pelvis_no_sacrum')
    switch method_pelvis
        case 'STAPLE'
            [CS.pelvis, JCS.pelvis, BL.pelvis]  = STAPLE_pelvis(geom_set.pelvis_no_sacrum, in_mm);
        case 'Kai'
            [CS.pelvis, JCS.pelvis, BL.pelvis]  = Kai2014_pelvis(geom_set.pelvis_no_sacrum, 0, 0, 1);
    end
    %     addMarkersFromStruct(osimModel, 'pelvis', BL.pelvis, in_mm);
end

% ---- FEMUR -----
if isfield(geom_set,'femur_r')
    switch method_femur
        case 'Miranda'
            [CS.femur_r, JCS.femur_r, BL.femur_r] = Miranda2010_buildfACS(geom_set.tibia_r);
        case 'Kai'
            [CS.femur_r, JCS.femur_r, BL.femur_r] = Kai2014_femur(geom_set.femur_r);
        case 'GIBOC-spheres'
            [CS.femur_r, JCS.femur_r, BL.femur_r] = GIBOC_femur(geom_set.femur_r, [], 'spheres');
        case 'GIBOC-ellipsoids'
            [CS.femur_r, JCS.femur_r, BL.femur_r] = GIBOC_femur(geom_set.femur_r, [], 'ellipsoids');
        case 'GIBOC-cylinder'
            [CS.femur_r, JCS.femur_r, BL.femur_r] = GIBOC_femur(geom_set.femur_r, [], 'cylinder');
        otherwise
            [CS.femur_r, JCS.femur_r, BL.femur_r] = GIBOC_femur(geom_set.femur_r);
    end
%     addMarkersFromStruct(osimModel, 'femur_r', BL.femur_r, in_mm);
end

%---- TIBIA -----
if isfield(geom_set,'tibia_r')
    switch method_tibia
        case 'Miranda' % same as Kai but using inertia
            [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = Miranda2010_buildtACS(geom_set.tibia_r);
        case 'Kai'
            [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = Kai2014_tibia(geom_set.tibia_r);
        case 'GIBOC-plateau'
            [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = GIBOC_tibia(geom_set.tibia_r, [], 'plateau');
        case 'GIBOC-ellipse'
            [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = GIBOC_tibia(geom_set.tibia_r, [], 'ellipse');
        case 'GIBOC-centroids'
            [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = GIBOC_tibia(geom_set.tibia_r, [], 'centroids');
        otherwise
            [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = Kai2014_tibia(geom_set.tibia_r);
    end
%     addMarkersFromStruct(osimModel, 'tibia_r', BL.tibia_r, in_mm);
end


%---- PATELLA -----
if isfield(geom_set,'patella_r')
    switch method_patella
        case 'Rainbow'
            [CS.patella_r, JCS.patella_r, BL.patella_r] = Rainbow2013_buildpACS();
        case 'GIBOC-vol-ridge'
            [CS.patella_r, JCS.patella_r, BL.patella_r] = GIBOC_patella(geom_set.patella_r, 'volume-ridge');
        case 'GIBOC-ridge'
            [CS.patella_r, JCS.patella_r, BL.patella_r] = GIBOC_patella(geom_set.patella_r, 'ridge-line');
        case 'GIBOC-ACS'
            [CS.patella_r, JCS.patella_r, BL.patella_r] = GIBOC_patella(geom_set.patella_r, 'artic-surf');
        otherwise
            % error('choose coorect patellar algorithm');
    end
                
end
    
%---- TALUS/ANKLE -----
if isfield(geom_set,'talus_r')
    [CS.talus_r, JCS.talus_r] = STAPLE_talus(geom_set.talus_r);
end

%---- CALCANEUS/SUBTALAR -----
if isfield(geom_set,'calcn_r')
    [CS.calcn_r, JCS.calcn_r, BL.calcn_r] = STAPLE_foot(geom_set.calcn_r);
%     addMarkersFromStruct(osimModel, 'calcn_r',   CalcnBL,  in_mm); 
end

end
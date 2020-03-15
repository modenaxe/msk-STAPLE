function [JCS, BL, CS] = analyzeBoneGeometries(geom_set, method_fem, method_tibia, in_mm)

% setting defaults
if nargin<2; method_fem = ''; method_tibia = ''; in_mm = 1; end
if nargin<3; method_tibia = ''; in_mm = 1; end
if nargin<4; in_mm = 1; end

% ---- PELVIS -----
if isfield(geom_set,'pelvis')
    [CS.pelvis, JCS.pelvis, BL.pelvis]  = GIBOK_pelvis(geom_set.pelvis, in_mm);
%     addMarkersFromStruct(osimModel, 'pelvis', BL.pelvis, in_mm);
end

% ---- FEMUR -----
if isfield(geom_set,'femur_r')
    switch method_fem
        case 'Miranda'
            [CS.femur_r, JCS.femur_r, BL.femur_r] = Miranda2010_buildfACS(geom_set.tibia_r);
        case 'Kai'
            [CS.femur_r, JCS.femur_r, BL.femur_r]  = CS_femur_Kai2014(geom_set.femur_r);
        case 'GFem-spheres'
            [CS.femur_r, JCS.femur_r, BL.femur_r] = GIBOK_femur(geom_set.femur_r, [], 'spheres');
        case 'GFem-ellipsoids'
            [CS.femur_r, JCS.femur_r, BL.femur_r] = GIBOK_femur(geom_set.femur_r, [], 'ellipsoids');
        case 'GFem-cylinder'
            [CS.femur_r, JCS.femur_r, BL.femur_r] = GIBOK_femur(geom_set.femur_r, [], 'cylinder');
        otherwise
            [CS.femur_r, JCS.femur_r, BL.femur_r] = GIBOK_femur(geom_set.femur_r);
    end
%     addMarkersFromStruct(osimModel, 'femur_r', BL.femur_r, in_mm);
end

%---- TIBIA -----
if isfield(geom_set,'tibia_r')
    switch method_tibia
        case 'Miranda' % same as Kai but using inertia
            [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = Miranda2010_buildtCS(geom_set.tibia_r);
        case 'Kai'
            [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = CS_tibia_Kai2014(geom_set.tibia_r);
        case 'GTib-plateau'
            [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = GIBOK_tibia(geom_set.tibia_r, [], 'plateau');
        case 'GTib-ellipse'
            [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = GIBOK_tibia(geom_set.tibia_r, [], 'ellipse');
        case 'GTib-centroids'
            [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = GIBOK_tibia(geom_set.tibia_r, [], 'centroids');
        otherwise
            [CS.tibia_r, JCS.tibia_r, BL.tibia_r] = CS_tibia_Kai2014(geom_set.tibia_r);
    end
%     addMarkersFromStruct(osimModel, 'tibia_r', BL.tibia_r, in_mm);
end

%---- TALUS/ANKLE -----
if isfield(geom_set,'talus_r')
    [CS.talus_r, JCS.talus_r] = GIBOK_talus(geom_set.talus_r);
end

%---- CALCANEUS/SUBTALAR -----
if isfield(geom_set,'calcn_r')
    [CS.calcn_r, JCS.calcn_r, BL.calcn_r] = GIBOK_calcn(geom_set.calcn_r);
%     addMarkersFromStruct(osimModel, 'calcn_r',   CalcnBL,  in_mm); 
end

end
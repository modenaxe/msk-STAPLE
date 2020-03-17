clear; clc; close all
tic
% add useful scripts
addpath(genpath('GIBOK-toolbox'));
addpath('autoMSK_functions');

%--------------------------------------
dataset_set = {'LHDL_CT', 'P0_MRI', 'JIA_CSm6', 'TLEM2_CT', 'TLEM2_MRI'};
in_mm = 1;

for n_d = 1:5
    
    % setup folders
    main_ds_folder =  ['test_geometries',filesep,dataset_set{n_d}];
    tri_folder = fullfile(main_ds_folder,'tri');
    cur_geom_file = fullfile(tri_folder, 'femur_r');
    
    % load the femur and split it on prox and dist
    Femur = load_mesh(cur_geom_file);
    [ProxFem, DistFem] = cutLongBoneMesh(Femur);
    
    % Get eigen vectors V_all of the Femur 3D geometry and volumetric center
    [ CS.V_all, CS.CenterVol ] = TriInertiaPpties(Femur);
    
    % Check that the distal femur is 'below' the proximal femur or invert Z0
    Z0 = CS.V_all(:,1);
    CS.Z0 = sign((mean(ProxFem.Points)-mean(DistFem.Points))*Z0)*Z0;
    
    CoeffMorpho = computeTriCoeffMorpho(Femur);
    
    % crea
    debug_plots = 0;
    [CSKai, MostProxPoint] = fitSphere2FemHead_Kai2014(ProxFem, CS, debug_plots);
    [CSRenault, FemHead] = fitSphere2FemHead_Renault2019(ProxFem, CS, CoeffMorpho, debug_plots);
    
    % save estimations
    estimations(n_d,:) = [  CSKai.CenterFH_Kai, CSKai.RadiusFH_Kai, ...
                            CSRenault.CenterFH_Renault, CSRenault.RadiusFH_Renault];
    
end

% results
diff_centre_comp = estimations(:,1:3)-estimations(:,5:7);
abs_distance = sqrt(sum(diff_centre_comp.^2 , 2));
diff_radii = abs(estimations(:,4)-estimations(:,8));
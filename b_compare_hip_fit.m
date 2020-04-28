%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('GIBOK-toolbox'));
addpath('autoMSK_functions');

% settings
%----------
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'P0_MRI', 'JIA_MRI'};
in_mm = 1;
% if visualization is desired
debug_plots = 0;
%----------

for n_d = 1:4
    
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
    % morphological coeff
    CoeffMorpho = computeTriCoeffMorpho(Femur);
    
    % if a vi
    
    [CSKai, MostProxPoint] = fitSphere2FemHead_Kai2014(ProxFem, CS, debug_plots);
    [CSRenault, FemHead] = fitSphere2FemHead_Renault2019(ProxFem, CS, CoeffMorpho, debug_plots);
    
    % save estimations
    estimations(n_d,:) = [  CSKai.CenterFH_Kai,...
                            CSKai.RadiusFH_Kai, ...
                            CSRenault.CenterFH_Renault,...
                            CSRenault.RadiusFH_Renault];
    
end

% results table
res_table = table(estimations(:,1:3), estimations(:,4), estimations(:,5:7),estimations(:,8),...
            'VariableNames',{'HJC_Kai2014', 'Radius_Kai2014', 'HJC_Renault2018','Radius_Renault2018'});
res_table.Properties.RowNames = dataset_set;
      
% metrics table
diff_centre_comp = estimations(:,1:3)-estimations(:,5:7);
abs_distance = sqrt(sum(diff_centre_comp.^2 , 2));
diff_radii = abs(estimations(:,4)-estimations(:,8));

metric_table = table(diff_centre_comp, abs_distance, diff_radii,...
    'VariableNames',{'Diff_Vector', 'Diff_Vec_Magnitude', 'Radius_Diff'});
metric_table.Properties.RowNames = dataset_set;
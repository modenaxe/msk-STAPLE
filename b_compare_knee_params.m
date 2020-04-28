%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clear; clc; close all
addpath(genpath('GIBOK-toolbox'));
addpath('autoMSK_functions');
addpath(genpath('FemPatTibACS/KneeACS/Tools'));

%---------
% SETTINGS
%---------
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'P0_MRI', 'JIA_MRI'};
in_mm = 1;

nf = 1;
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
%     debug_plots = 0;
try
    [FemCS1, JCS1] = Miranda2010_buildfACS(Femur);
catch
    failed_Miranda(nf) = n_d;
    nf = nf+1;
    JCS1.knee_r.Origin = [0 0 0];
    JCS1.knee_r.V = zeros(3,3);
end
    [FemCS2, JCS2] = CS_femur_Kai2014(Femur, [], 0);
    [FemCS3, JCS3] = GIBOK_femur(Femur, [], 'spheres', 0);
    [FemCS4, JCS4] = GIBOK_femur(Femur, [], 'ellipsoids', 0);
    [FemCS5, JCS5] = GIBOK_femur(Femur, [], 'cylinder', 0);

    KJCs(:,:,n_d) = [JCS1.knee_r.Origin;
                    JCS2.knee_r.Origin;
                    JCS3.knee_r.Origin;
                    JCS4.knee_r.Origin;
                    JCS5.knee_r.Origin];

    KJZ(:,:,n_d) = [JCS1.knee_r.V(:,3)';
                    JCS2.knee_r.V(:,3)';
                    JCS3.knee_r.V(:,3)';
                    JCS4.knee_r.V(:,3)';
                    JCS5.knee_r.V(:,3)'];
               clear JCS1 JCS2 JCS3 JCS4 JCS5
end


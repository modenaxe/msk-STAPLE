%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
%
% NOTE: Kai-algorithms require tibia and fibula, GIBOC works on tibia only.
% On STAPLE the fibula is removed automatically when using GIBOC.
% ----------------------------------------------------------------------- %

clear; clc; close all
addpath(genpath('msk-STAPLE/STAPLE'));

%----------
% SETTINGS
%---------------------------
results_folder = 'results/tibiofemoral_alignment';
bone_geometry_folder = 'bone_geometries';
dataset_set = {'LHDL_CT', 'TLEM2_CT', 'ICL_MRI', 'JIA_MRI'};
bone_set = { 'femur_r', 'tibia_r'};
% reference_algorithm = 'STAPLE';
in_mm = 1;
results_plots = 0;
%---------------------------

% create results folder if needed
if ~isfolder(results_folder); mkdir(results_folder); end

% loop through datasets only
for n_d = 1:numel(dataset_set)
    
    % setup folders
    cur_dataset = dataset_set{n_d};
    main_ds_folder =  fullfile(bone_geometry_folder,cur_dataset);
    
    % compute femur JCS using GIBOC-Cylinder as reference
    cur_fem_file = fullfile(main_ds_folder, 'tri', 'femur_r');
    fem_triang = load_mesh(cur_fem_file);
    [~, ref_JCSFem] = GIBOC_femur(fem_triang, [], 'cylinder', results_plots);
    
    % load the tibia
    cur_geom_file = fullfile(main_ds_folder,'tri',  'tibia_r');
    tibia_triang = load_mesh(cur_geom_file);
    
    % Get eigen vectors V_all of the Femur 3D geometry and volumetric center
    [ CS.V_all, CS.CenterVol ] = TriInertiaPpties(tibia_triang);
    % take the long direction for femur
    CS.Z0 = CS.V_all(:,1);
    CoeffMorpho = computeTriCoeffMorpho(tibia_triang);
    
    % compute JCSs for all available algorithms
    try
        [CS1, JCS1] = Miranda2010_buildtACS(tibia_triang);
    catch
        JCS1.knee_r.Origin = nan(1,3);
        JCS1.knee_r.V = nan(3,3);
    end
    [CS2, JCS2] = Kai2014_tibia(tibia_triang, [], results_plots);
    [CS3, JCS3] = GIBOC_tibia(tibia_triang, [], 'plateau', results_plots);
    [CS4, JCS4] = GIBOC_tibia(tibia_triang, [], 'ellipse', results_plots);
    [CS5, JCS5] = GIBOC_tibia(tibia_triang, [], 'centroids', results_plots);
    
    % table headers - here just so they are close to the methods
    table_head = {'KneeJointCentre_tibia_v_mm', 'Dist_norm_mm' 'KneeJointAxis_tibia', 'Ang_diff_deg'};
    methods_list = {'Miranda2010','Kai2014','GIBOK-Plateau','GIBOK-Ellipse','GIBOK-Centroids'};
    
    % origins of reference systems
    joint_centres = [   JCS1.knee_r.Origin;
                        JCS2.knee_r.Origin;
                        JCS3.knee_r.Origin;
                        JCS4.knee_r.Origin;
                        JCS5.knee_r.Origin];
    
    
    % compute linear distances (distance vectors in femur coord frame)
    orig_diff = (joint_centres - ref_JCSFem.knee_r.Origin)*ref_JCSFem.knee_r.V;
    orig_dist = sqrt(sum(orig_diff.^2, 2));
    
    % compute angular differences between femural JCSs and tibial
    for naxis = 1:3
        joint_axis =[   JCS1.knee_r.V(:,naxis)';
                        JCS2.knee_r.V(:,naxis)';
                        JCS3.knee_r.V(:,naxis)';
                        JCS4.knee_r.V(:,naxis)';
                        JCS5.knee_r.V(:,naxis)'];
        ang_diff(:,naxis) = acosd(joint_axis*ref_JCSFem.knee_r.V(:,naxis)); %#ok<*SAGROW>
    end
    
    % second option for reporting results (cumulative variables)
    row_ind = n_d:numel(dataset_set):numel(methods_list)*numel(dataset_set);
    orig_diff_opt2(row_ind,:) = orig_diff;
    orig_dist_opt2(row_ind,:) = orig_dist;
    ang_diff_opt2(row_ind,:)  = ang_diff;
    
    % table with results (one per method)
    % res_table = table(orig_diff, orig_dist, joint_axis, ang_diff, ...
    %                   'VariableNames',table_head);
    % res_table.Properties.RowNames = methods_list;
    
    % write one table per dataset if required
    % writetable(res_table,fullfile(results_folder, [cur_bone,'_', cur_dataset,'.xlsx']));
    
    % clear all
    clear JCS1 JCS2 JCS3 JCS4 JCS5 ref_JCS ang_diff orig_dist orig_diff bone_triang
    
    close all
end

% table with results for deviation of all tibial reference systems compared
% to the chosen femoral one.
res_table2 = table(orig_diff_opt2, orig_dist_opt2, ang_diff_opt2, ...
                   'VariableNames',table_head([1,2,4]));
writetable(res_table2,fullfile(results_folder, 'tibiofemoral_alignment.xlsx'));

% visualise in clean console
clc;
disp(res_table2)
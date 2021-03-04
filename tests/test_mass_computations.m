%-------------------------------------------------------------------------%
% Copyright (c) 2021 Modenese L.                                          %
%    Author:   Luca Modenese, April 2018                                  %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% test to verify that the calculation of bone mass properties (mass and
% inertia) is correct. NMSBuilder is used as reference application.
clear; clc; close all
addpath(genpath('../STAPLE'));

%----------
% SETTINGS 
%----------
ref_model = './ref_models/mass/ankle_R_ref.osim';
% add OpenSim libraries
import org.opensim.modeling.*
% datasets that you would like to process
dataset_set = {'JIA_ANKLE_MRI'};

% cell array with the bone geometries that you would like to process
bone_geometries_folder = '../bone_datasets';
bones_list = {'tibia_r','talus_r','calcn_r'};
in_mm = 1;
%--------------------------------------
test_pass = 1;
for n_d = 1:numel(dataset_set)
    
    % setup folders
    cur_dataset = dataset_set{n_d};
    main_ds_folder =  fullfile(bone_geometries_folder, cur_dataset);
    
    % model and model file naming
    tri_folder = fullfile(main_ds_folder,'tri');
    
    % create geometry set structure for the entire dataset
    geom_set = createTriGeomSet(bones_list, tri_folder);

    % initialize OpenSim model
    osimModel = initializeOpenSimModel('test_model_for_mass_comput');
    
    % create bodies
    osimModel = addBodiesFromTriGeomBoneSet(osimModel, geom_set, '.','');
    
    % finalize connections
    osimModel.finalizeConnections();
    
    % print OpenSim model
    osimModel.print('./ref_models/mass/mass_calc.osim');
    
    % inform the user about time employed to create the model
    disp('-------------------------')
    disp(['Model generated in ', sprintf('%.1f', toc), ' s']);
    disp('Saved as /models_from_tests/mass_calc.osim.');
    disp('-------------------------')
end


%% verification section
% load reference model
osimModelRef = Model(ref_model);
tol = 10-5;

disp('=================')
disp('  testing mass   ')
disp('=================')
for n = 1:numel(bones_list)
    disp(['Body: ', bones_list{n},'...']);
    
    curr_body_ref = osimModelRef.getBodySet.get(bones_list{n});
    curr_body_model = osimModel.getBodySet.get(bones_list{n});
    
    % check mass properties
    diff =  curr_body_ref.getMass-curr_body_model.getMass;
    if diff<tol
        disp('   same mass!')
    else
        disp(['WARNING: difference in mass > ', num2str(tol)])
    end 
    
    m = curr_body_ref.get_inertia();
    % components of inertia (ref model)
    xx = m.get(0); yy = m.get(1); zz = m.get(2); 
    xy = m.get(3); xz = m.get(4); yz = m.get(5);
    inertia_ref = [xx , yy , zz , xy , xz , yz];
    
    % components of inertia (curr model)
    mc = curr_body_model.get_inertia();
    xxc = mc.get(0); yyc = mc.get(1); zzc = mc.get(2); 
    xyc = mc.get(3); xzc = mc.get(4); yzc = mc.get(5);
    inertia_model = [xxc , yyc , zzc , xyc , xzc , yzc];  
    
    max_diff = max(inertia_ref-inertia_model);
    if diff<tol
        disp('   same inertia!')
    else
        test_pass = 0;
        disp(['WARNING: max difference in inertia component > ', num2str(tol)])
    end 
end
assert(test_pass==1, 'Mass properties are different');
disp('------------')
disp('Test passed.')
% remove paths
rmpath(genpath('../STAPLE'));
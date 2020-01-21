% EXAMPLE %
% -------------------------------------------------------------------------
% EXAMPLE DATA CAN BE FOUND AT
% https://www.dropbox.com/sh/ciy1fu2k63nqnd4/AACWkJvSHsiA_-9slJBiEEiua?dl=0
%
% then they should be put at the root of the code
%
% Reading .msh file might be a bit faster than stl
%--------------------------------------------------------------------------
clear; clc; close all
addpath(genpath('GIBOK-toolbox'));

%--------------------------------
% SETTINGS
%--------------------------------
% specify where data are
bone_geom_folder = './test_geometries';
dataset_folder_set = {  'P0_MRI_tri',...% working
                        'TLEM2_MRI_tri',...
                        'TLEM2_CT_tri',...
                        'LHDL_CT_tri'};
% select dataset (just for testing, will be loop)
nd_given = 1;
% specify the bones you want to calculate the ACSs for
bone_name_set = {'pelvis_no_sacrum', 'femur_r',  'tibia_r', 'patella_r','talus_r', 'toes_r'};

% specify where to store the results
ACs_store_folder = './ACs';
%--------------------------------


for nd = nd_given %1:numel(dataset_folder_set)
    dataset_folder = dataset_folder_set{nd};
    
    N_bones = numel(bone_name_set);
    
    for nb = 1:N_bones
        cur_bone_name = bone_name_set{nb};
        
        % read mat triangulation
        geom_file = fullfile(bone_geom_folder, dataset_folder, [cur_bone_name,'.mat']);
        %TODO: add existence check
        geom = load(geom_file);
        % reads field name (might be different due to changes in
        % a_stl2triang.m
        str_name = fields(geom);
        geom = geom.(str_name{1});
        
        switch cur_bone_name
            
            case 'pelvis_no_sacrum'
                try 
                    [ PelvisACSsResults, PelvisTriangulations ] = PelvisFun( geom);
                    PlotPelvis_ISB( PelvisACSsResults.ISB, PelvisTriangulations.Pelvis )
                catch EM
                    disp('=================================');disp(EM.identifier); 
                    disp(EM.message);disp('=================================');
                    warning([cur_bone_name, ' could not be processed. Please double check your mesh and error logs.']);
                    continue
                end
            
            case 'femur_r'
                try 
                    [ FemACSsResults, FemurTriangulations ] = RFemurFun(geom);
                    PlotFemurDist_ISB( FemACSsResults.PCC, FemurTriangulations );
                    PlotFemurProx_ISB( FemACSsResults.PCC, FemurTriangulations, FemACSsResults );
                catch EM
                    disp('=================================');disp(EM.identifier); 
                    disp(EM.message);disp('=================================');
                    warning([cur_bone_name, ' could not be processed. Please double check your mesh and error logs.']);
                    continue
                end
            case 'tibia_r'
                try
                    [ TibACSsResults, TibiaTriangulations ] = RTibiaFun(geom);
                    PlotTibiaProx_ISB( TibACSsResults.PIAASL, TibiaTriangulations )
                catch EM
                    disp('=================================');disp(EM.identifier); 
                    disp(EM.message);disp('=================================');
                    warning([cur_bone_name, ' could not be processed. Please double check your mesh and error logs.']);
                    continue
                end
            case 'patella_r'
                try
                    [ PatACSsResults, PatellaTriangulations ] = RPatellaFun( geom );
                    PlotPatella( PatACSsResults.VR, PatellaTriangulations )
                catch EM
                    disp('=================================');disp(EM.identifier); 
                    disp(EM.message);disp('=================================');
                    warning([cur_bone_name, ' could not be processed. Please double check your mesh and error logs.']);
                    continue
                end
            case 'talus_r'
                continue
            case 'toes_r'
                continue
            otherwise
                error([cur_bone_name, ' does not have a mesh associated with it. Please double check inputs.']);
        end
        
        clear geom
    end
    save(fullfile(ACs_store_folder, [dataset_folder,'_ACSsResults']),...
        'PelvisACSsResults','FemACSsResults', 'TibACSsResults', 'PatACSsResults');
end

% %% Pelvis
% % if stl is to be read (slow)
% % [Pelvis] = ReadMesh(fullfile(bone_geom_folder, 'pelvis_no_sacrum.stl'));
% % read triangulation
% Pelvis = load(fullfile(bone_dir,'pelvis_no_sacrum.mat'));
% Pelvis = Pelvis.curr_triang;
% [ PelvisRS, PelvisTriangulations ] = PelvisFun( Pelvis);
% PlotPelvis_ISB( PelvisRS.ISB, PelvisTriangulations.Pelvis )
%
% %% Example for a Femur composed of two parts (distal and proximal)
% [Fem] = ReadMesh(fullfile(bone_geom_folder, dataset_folder,'femur_r_LHDL_remeshed15.stl'));
%
% [ FemACSsResults, FemurTriangulations ] = RFemurFun(Fem);
% PlotFemurDist_ISB( FemACSsResults.PCC, FemurTriangulations )
%
% %% Example for a Tibia composed of two parts (distal and proximal)
% [Tib] = ReadMesh(fullfile(bone_geom_folder,dataset_folder,'/tibia_r_LHDL_remeshed15.stl'));
%
% [ TibACSsResults, TibiaTriangulations ] = RTibiaFun( Tib);
% PlotTibiaDist_ISB( TibACSsResults.PIAASL, TibiaTriangulations )
%
% %% Example for a Patella
% [Patella] = ReadMesh(strcat(bone_geom_folder,dataset_folder,'/patella_r_LHDL_remeshed10.stl'));
%
% [ PatACSsResults, PatellaTriangulations ] = RPatellaFun( Patella );
% PlotPatella( PatACSsResults.VR, PatellaTriangulations )
%
% %% saving reference systems
% save(fullfile(ACs_folder, [dataset_folder,'_ACSsResults']), 'FemACSsResults', 'TibACSsResults', 'PatACSsResults')

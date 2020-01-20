% EXAMPLE %
% -------------------------------------------------------------------------
% EXAMPLE DATA CAN BE FOUND AT
% https://www.dropbox.com/sh/ciy1fu2k63nqnd4/AACWkJvSHsiA_-9slJBiEEiua?dl=0
%
% then they should be put at the root of the code
%
% Reading .msh file might be a bit faster than stl
%--------------------------------------------------------------------------
clearvars; clc; close all
addpath(genpath('GIBOK-toolbox'));

%--------------------------------
% SETTINGS
%--------------------------------
% specify where data are
bone_geom_folder = './test_geometries';
dataset_folder_set = {'P0_MRI_tri', 'TLEM2_MRI_tri', 'TLEM2_CT_tri', 'LHDL_CT_tri'};
% select dataset (just for testing, will be loop)
nd_given = 3;
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
        geom = load(geom_file);
        geom = geom.curr_triang;
        
        switch cur_bone_name
            case 'pelvis_no_sacrum'
                [ PelvisACSsResults, PelvisTriangulations ] = PelvisFun( geom);
                PlotPelvis_ISB( PelvisACSsResults.ISB, PelvisTriangulations.Pelvis )
            case 'femur_r'
                [ FemACSsResults, FemurTriangulations ] = RFemurFun(geom);
                PlotFemurDist_ISB( FemACSsResults.PCC, FemurTriangulations )
            case 'tibia_r'
                [ TibACSsResults, TibiaTriangulations ] = RTibiaFun(geom);
                PlotTibiaProx_ISB( TibACSsResults.PIAASL, TibiaTriangulations )
            case 'patella_r'
                [ PatACSsResults, PatellaTriangulations ] = RPatellaFun( geom );
                PlotPatella( PatACSsResults.VR, PatellaTriangulations )
            case 'talus_r'
                continue
            case 'toes_r'
                continue
            otherwise
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

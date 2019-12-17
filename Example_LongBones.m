% EXAMPLE %
% -------------------------------------------------------------------------
% EXAMPLE DATA CAN BE FOUND AT
% https://www.dropbox.com/sh/ciy1fu2k63nqnd4/AACWkJvSHsiA_-9slJBiEEiua?dl=0
%
% then they should be put at the root of the code
%
% Reading .msh file might be a bit faster than stl
%--------------------------------------------------------------------------
clearvars 
clc; close all

%--------------------------------
% SETTINGS
%--------------------------------
addpath(genpath('GIBOK-toolbox'));
bone_geom_folder = './test_geometries';
ACs_folder = './ACs';
test_case = 'LHDL';
%--------------------------------

%% Pelvis will be integrated here


%% Example for a Femur composed of two parts (distal and proximal)
[Fem] = ReadMesh(fullfile(bone_geom_folder, test_case,'femur_r_LHDL_remeshed15.stl'));

[ FemACSsResults, FemurTriangulations ] = RFemurFun(Fem);
PlotFemurDist_ISB( FemACSsResults.PCC, FemurTriangulations )

%% Example for a Tibia composed of two parts (distal and proximal)
[Tib] = ReadMesh(fullfile(bone_geom_folder,test_case,'/tibia_r_LHDL_remeshed15.stl'));

[ TibACSsResults, TibiaTriangulations ] = RTibiaFun( Tib);
PlotTibiaDist_ISB( TibACSsResults.PIAASL, TibiaTriangulations )

%% Example for a Patella
[Patella] = ReadMesh(strcat(bone_geom_folder,test_case,'/patella_r_LHDL_remeshed10.stl'));

[ PatACSsResults, PatellaTriangulations ] = RPatellaFun( Patella );
PlotPatella( PatACSsResults.VR, PatellaTriangulations )

%% saving reference systems
save(fullfile(ACs_folder, [test_case,'_ACSsResults']), 'FemACSsResults', 'TibACSsResults', 'PatACSsResults')

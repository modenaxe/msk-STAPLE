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
clc
close all

addpath(genpath(strcat(pwd,'/SubFunctions')));
bone_geom_folder = '../test_geom_full';

%% Example for a Femur composed of two parts (distal and proximal)
[Fem] = ReadMesh(strcat(bone_geom_folder,'/femur_r_LHDL_remeshed15.stl'));

[ FemACSsResults, FemurTriangulations ] = RFemurFun(Fem);
PlotFemur( FemACSsResults.PCC, FemurTriangulations )

%% Example for a Tibia composed of two parts (distal and proximal)
[Tib] = ReadMesh(strcat(bone_geom_folder,'/tibia_r_LHDL_remeshed15.stl'));

[ TibACSsResults, TibiaTriangulations ] = RTibiaFun( Tib);
PlotTibia( TibACSsResults.PIAASL, TibiaTriangulations )
figure
PlotTibia( TibACSsResults.ECASE, TibiaTriangulations )
%% Example for a Patella
[Patella] = ReadMesh(strcat(bone_geom_folder,'/patella_r_LHDL_remeshed10.stl'));

[ PatACSsResults, PatellaTriangulations ] = RPatellaFun( Patella );
PlotPatella( PatACSsResults.VR, PatellaTriangulations )

save('LHDL_ACSsResults', 'FemACSsResults', 'TibACSsResults', 'PatACSsResults')

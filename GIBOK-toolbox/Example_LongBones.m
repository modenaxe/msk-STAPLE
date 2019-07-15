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
close all

addpath(genpath(strcat(pwd,'/SubFunctions')));

%% Example for a Femur composed of two parts (distal and proximal)
[Fem] = ReadMesh(strcat(pwd,'/femur_r_LHDL.stl'));

[ FemACSsResults, FemurTriangulations ] = RFemurFun(Fem);
PlotFemur( FemACSsResults.PCC, FemurTriangulations )

%% Example for a Tibia composed of two parts (distal and proximal)
[Tib] = ReadMesh(strcat(pwd,'/tibia_r_LHDL.stl'));

[ TibACSsResults, TibiaTriangulations ] = RTibiaFun( Tib);
PlotTibia( TibACSsResults.PIAASL, TibiaTriangulations )

%% Example for a Patella
[Patella] = ReadMesh(strcat(pwd,'/patella_r.stl'));

[ PatACSsResults, PatellaTriangulations ] = RPatellaFun( Patella );
PlotPatella( PatACSsResults.VR, PatellaTriangulations )

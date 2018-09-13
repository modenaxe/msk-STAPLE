% EXAMPLE %
% -------------------------------------------------------------------------
% EXAMPLE DATA CAN BE FOUND AT
% https://www.dropbox.com/sh/ciy1fu2k63nqnd4/AACWkJvSHsiA_-9slJBiEEiua?dl=0
%--------------------------------------------------------------------------
clearvars 
close all

addpath(genpath(strcat(pwd,'\SubFunctions')));

% % Example for a Tibia composed of two parts (distal and proximal)
% [ProxTib,DistTib] = ReadMesh(strcat(pwd,'\ProxTib_S1_05.msh'),...
%     strcat(pwd,'\DistTib_S1_05.msh'));
% 
% [ ACSsResults, TrObjects ] = RTibiaFun( ProxTib , DistTib);
% PlotTibia( ACSsResults.tech3, TrObjects )

% % Example for a Femur composed of two parts (distal and proximal)
% [ProxTib,DistTib] = ReadMesh(strcat(pwd,'\DistFem_S2_05.msh'),...
%     strcat(pwd,'\ProxFem_S2_05.msh'));
% 
% [ ACSsResults, TrObjects ] = RFemurFun( ProxTib , DistTib);
% close all
% PlotFemur( ACSsResults.PCC, TrObjects )

% Example for a Patella
[Patella] = ReadMesh(strcat(pwd,'\Patella_S4_05.msh'));
%Patella_S3_05.msh

[ ACSsResults, TrObjects ] = RPatellaFun( Patella );
close all
PlotPatella( ACSsResults.VR, TrObjects )

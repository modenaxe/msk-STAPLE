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
bone_geom_folder = './test_geom_full';

%% Example for a Femur composed of two parts (distal and proximal)
% [Pelvis] = ReadMesh(strcat(bone_geom_folder,'/pelvis_sacrum_10.stl'));
% save('pelvis_sacrum_10', 'Pelvis')
load(fullfile(bone_geom_folder,'pelvis_sacrum_10'));

[ TrNewCS, V ,T ] = TriChangeCS( Pelvis)

% Get eigen vectors V_all and volumetric center
[eigVctrs, CenterVol, InertiaMatrix ] =  TriInertiaPpties( Pelvis );

PelvisRS.Origin = CenterVol;
PelvisRS.X = eigVctrs(:,1)';
PelvisRS.Y = eigVctrs(:,2)';
PelvisRS.Z = eigVctrs(:,3)';



PlotPelvis( PelvisRS, Pelvis )


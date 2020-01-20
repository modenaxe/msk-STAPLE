%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  % 
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
clearvars; clc; close all

addpath(genpath('./GIBOK-toolbox'));
addpath(genpath('./autoMSK_functions'))

bone_dir = './test_geometries/TLEM2_CT_tri';

%% Pelvis
Pelvis = load(fullfile(bone_dir,'pelvis.mat'));
Pelvis = Pelvis.curr_triang;

[ PelvisRS, PelvisISBTriangulations ] = PelvisFun( Pelvis);

PlotPelvis_ISB( PelvisRS.KAI, Pelvis )

% Plot inertial axis and center of volume of the pelvis
% PelvisRS.Origin = CenterVol;
% PelvisRS.X = RotISB2Glob(:,1)';
% PelvisRS.Y = RotISB2Glob(:,2)';
% PelvisRS.Z = RotISB2Glob(:,3)';
% PlotPelvis( PelvisRS, Pelvis )

% defining the ref system (ISB) - TO VERIFY THAT THE TRANSFORMATION WORKED
figure
PelvisISBRS.Origin = [0 0 0]';
PelvisISBRS.X = [1 0 0];
PelvisISBRS.Y = [0 1 0];
PelvisISBRS.Z = [0 0 1];
PlotPelvis_ISB( PelvisISBRS, Pelvis )
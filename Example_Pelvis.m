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
% [Pelvis] = ReadMesh(fullfile(bone_dir, 'pelvis_no_sacrum.stl'));
Pelvis = load(fullfile(bone_dir,'pelvis_no_sacrum.mat'));
Pelvis = Pelvis.curr_triang;

[ PelvisRS, PelvisTriangulations ] = PelvisFun( Pelvis);

PlotPelvis_ISB( PelvisRS.ISB, PelvisTriangulations.Pelvis )

% Plot inertial axis and center of volume of the pelvis
% PelvisRS.Origin = CenterVol;
% PelvisRS.X = RotISB2Glob(:,1)';
% PelvisRS.Y = RotISB2Glob(:,2)';
% PelvisRS.Z = RotISB2Glob(:,3)';
% PlotPelvis( PelvisRS, Pelvis )
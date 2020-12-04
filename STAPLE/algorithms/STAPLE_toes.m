%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese 
%-------------------------------------------------------------------------%
function [CS, JCS, ToesBL] = STAPLE_toes(toesTri, side_raw, result_plots,  debug_plots, in_mm)

% results/debug plot default
if nargin<3;     result_plots =1;  end
if nargin<4;     debug_plots = 0;  end
if nargin<5;     in_mm = 1;        end
if in_mm == 1;   dim_fact = 0.001; else;  dim_fact = 1; end

% get sign correspondent to body side
[sign_side, side_low] = bodySide2Sign(side_raw);

% joint names
toes_name     = ['mtp_', side_low];

% inform user about settings
disp('---------------------')
disp('   STAPLE - TOES     '); 
disp('---------------------')
disp(['* Body Side   : ', upper(side_low)]);
disp(['* Fit Method  : ', 'N/A']);
disp(['* Result Plots: ', convertBoolean2OnOff(result_plots)]);
disp(['* Debug  Plots: ', convertBoolean2OnOff(debug_plots)]);
disp(['* Triang Units: ', 'mm']);
disp('---------------------')
disp('Initializing method...')

% 1. Indentify initial CS of the foot
% Get eigen vectors V_all of the Talus 3D geometry and volumetric center
[ V_all, CenterVol ] = TriInertiaPpties( toesTri );

% THIS IS USED IN jointDefinitions_Modenese2018.m
CS.V = V_all;
CS.Origin = CenterVol;

% define toes joint
% JCS.(toes_name).Origin = ;
% JCS.(toes_name).V = ;
% JCS.(toes_name).parent_location = ;
% JCS.(toes_name).parent_orientation = );
JCS.(toes_name) = [];
ToesBL = [];

if result_plots == 1
    figure('Name', ['STAPLE | bone: toes | side: ', side_low])
    % plot the calcn triangulation
    plotTriangLight(toesTri, CS, 0)
    % Plot the inertia Axis & Volumic center
%     quickPlotRefSystem(JCS.(toes_name))
    
    % plot markers and labels
%     plotBoneLandmarks(ToesBL, label_switch)   

end

end
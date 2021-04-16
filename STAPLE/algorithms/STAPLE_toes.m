%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese 
%-------------------------------------------------------------------------%
function [BCS, JCS, ToesBL] = STAPLE_toes(toesTri, side_raw, result_plots,  debug_plots, in_mm)

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
[ V_all, CenterVol, ~, D ] = TriInertiaPpties( toesTri );

% ASSUMPTIONS - TO VERIFY:
% 1) largest eigenvalue is medial-lateral
% 2) smaller eigenvalue is vertical direction.
[~, I] = sort(diag(D));
z = V_all(:,I(1));
y = V_all(:,I(3));
x = normalizeV(cross(y,z));
% being unsure is this will handle the correct directions, I re-cross
z = normalizeV(cross(x,y));

% required for plotting and transforming geometry, even if not 100% tested
% this will not influence model results except joint reaction at
% calcn-toes joint
BCS.V = [x, y, z];
BCS.Origin = CenterVol;

% define toes joint (CURRENTLY NOT IMPLEMENTED)
% JCS.(toes_name).Origin = ;
% JCS.(toes_name).V = ;
% JCS.(toes_name).parent_location = ;
% JCS.(toes_name).parent_orientation = ;

% fields filled building the model
JCS.(toes_name) = [];
ToesBL = [];

if result_plots == 1
    figure('Name', ['STAPLE | bone: toes | side: ', side_low])
    % plot the calcn triangulation
    plotTriangLight(toesTri, BCS, 0)
    % % Plot the inertia Axis & Volumic center
    % quickPlotRefSystem(JCS.(toes_name))
    quickPlotRefSystem(BCS)
    % % plot markers and labels
    % plotBoneLandmarks(ToesBL, label_switch)   
end

end
% KAI2014_PELVIS Custom implementation of the method for defining a 
% reference system of the pelvis described in the following publication: 
% Kai, Shin, et al. Journal of biomechanics 47.5 (2014):1229-1233. 
% https://doi.org/10.1016/j.jbiomech.2013.12.013
% The algorithm creates a reference system based on principal axes of
% inertia and geometrical considerations as described in the original
% publication. Please note that:
% 1. the original implementation includes the sacrum, here excluded because
% difficult to segment from MRI scans.
% 2. the original publication defines the pelvis reference system
% differently from the reccomendations of the International Society of
% Biomechanics.
% 3. The robustness of the Kai2014 algorithm with respect to different
% global reference systems is ensured, in our experience, only through the
% further checks implemented in the pelvis_guess_CS.m function developed
% for STAPLE_pelvis.
%
%   [BCS, JCS, pelvisBL] = Kai2014_pelvis(pelvisTri,...
%                                        side_raw,...
%                                        result_plots, ...
%                                        debug_plots, in_mm)
%
% Inputs:
%   pelvisTri - MATLAB triangulation object of the entire pelvic geometry.
%
%   side_raw - generic string identifying a body side. 'right', 'r', 'left' 
%       and 'l' are accepted inputs, both lower and upper cases.
%
%   result_plots - enable plots of final fittings and reference systems. 
%       Value: 1 (default) or 0.
%
%   debug_plots - enable plots used in debugging. Value: 1 or 0 (default).
%
%   in_mm - (optional) indicates if the provided geometries are given in mm
%       (value: 1) or m (value: 0). Please note that all tests and analyses
%       done so far were performed on geometries expressed in mm, so this
%       option is more a placeholder for future adjustments.
%
% Outputs:
%   BCS - MATLAB structure containing body reference system and other 
%       geometrical features identified by the algorithm.
%
%   JCS - MATLAB structure containing the joint reference systems connected
%       to the bone being analysed. These might NOT be sufficient to define
%       a joint of the musculoskeletal model yet.
%
%   pelvisBL - MATLAB structure containing the bony landmarks identified 
%       on the bone geometries based on the defined reference systems. Each
%       field is named like a landmark and contain its 3D coordinates.
%
% See also KAI2014_FEMUR, KAI2014_TIBIA.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese & Jean-Baptiste Renault. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ BCS, JCS, pelvisBL] = Kai2014_pelvis(pelvisTri,...
                                               side_raw,...
                                               result_plots,...
                                               debug_plots,...
                                               in_mm)

if nargin<2;    side_raw = 'r';   end
if nargin<3;    result_plots=1;   end
if nargin<4;    debug_plots = 0;  end
if nargin<5;    in_mm = 1;        end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% get side id correspondent to body side (used for hip joint parent)
% no need for sign, left and right rf are identical
[~, side_low] = bodySide2Sign(side_raw);

disp('----------------------')
disp('   KAI2014 - PELVIS   '); 
disp('----------------------')
disp(['* Hip Joint   : ', upper(side_low)]);
disp(['* Method      : ', 'Princ Axes Inertia + Geometry']);
disp(['* Result Plots: ', convertBoolean2OnOff(result_plots)]);
disp(['* Debug  Plots: ', convertBoolean2OnOff(debug_plots)]);
disp(['* Triang Units: ', 'mm']);
disp('---------------------')
disp('Initializing method...')

% Initial guess of CS direction [JB]
% RISB2Glob_guess: principal inertial axes named as ISB (guess)
[RISB2Glob_guess, LargestTriangle] = pelvis_guess_CS(pelvisTri);

% Get eigen vectors V_all and volumetric center
[~, CenterVol, InertiaMatrix, D ] =  TriInertiaPpties(pelvisTri);

%------------------------------------
% TODO: develop other way of identifying the axes direction.
% there is always an eigenvector smaller than the other
% [~, ind_v] = min(diag(D));
% v = circshift([1, 2, 3], ind_v-1);
% y_pelvis_in_global = eigVctrs(:,ind_v);
% z_pelvis_in_global = eigVctrs(:,v(1));
% x_pelvis_in_global = eigVctrs(:,v(2));
%------------------------------------

% generating a triangulated pelvis with axes directed as they would be in a
% ISB reference system (Y upwards, X frontal etc)
[ PelvisPseudoISB, ~ , ~ ] = TriChangeCS( pelvisTri, RISB2Glob_guess, CenterVol);

% In ISB reference system: right side if z>0, upwards if Y>0
R_side_ind = PelvisPseudoISB.Points(:,3)>0;

disp('Analyzing pelvis geometry...')
% identifying the height of point beween most distal point and section with
% largest medio-lateral span.
[min_dist_H, ~] = min(PelvisPseudoISB.Points(:,2)); % most dist
[~, max_WD_R_ind] = max(PelvisPseudoISB.Points(:,3));
[~, max_WD_L_ind] = min(PelvisPseudoISB.Points(:,3));

% simplification: taking the height of the largest section as midpoint of
% furthest points in the +Z and -Z
max_WD_H = (PelvisPseudoISB.Points(max_WD_R_ind,2)+PelvisPseudoISB.Points(max_WD_L_ind,2))/2;

% height of dividing plane as described by Kai et al. 
H_div_plane = (max_WD_H+min_dist_H)/2;

% indices of points below the dividing plane
Dist_ind =  PelvisPseudoISB.Points(:,2)<H_div_plane;

%---------------------------------------------
% % possible improvements sectioning the triangulations
% [Areas, Alt] = TriSliceObjAlongAxis(PelvisPseudoISB, [0 -1 0 ]', 1);
% [Areas, Alt] = TriSliceObjAlongAxis(PelvisPseudoISB, [0 0  1]', 1);
% figure; plot(Alt, Areas)
%---------------------------------------------

disp('Landmarking...')

% identifying bony landmarks
[~, RASIS_ind] = max(PelvisPseudoISB.Points(:,1).* R_side_ind);
[~, LASIS_ind] = max(PelvisPseudoISB.Points(:,1).*~R_side_ind);
[~, RPSIS_ind] = min(PelvisPseudoISB.Points(:,1).* R_side_ind);
[~, LPSIS_ind] = min(PelvisPseudoISB.Points(:,1).*~R_side_ind);
[~, RPS_ind]   = max(PelvisPseudoISB.Points(:,1).* R_side_ind.*Dist_ind);
[~, LPS_ind]   = max(PelvisPseudoISB.Points(:,1).*~R_side_ind.*Dist_ind);

if debug_plots == 1
    quickPlotTriang(PelvisPseudoISB);
    plot3(  PelvisPseudoISB.Points(Dist_ind,1),...
            PelvisPseudoISB.Points(Dist_ind,2),...
            PelvisPseudoISB.Points(Dist_ind,3))
    plotDot(PelvisPseudoISB.Points(RPS_ind,:), 'k', 7)
    plotDot(PelvisPseudoISB.Points(LPS_ind,:), 'k', 7)
end

% extract points on bone in medical images ref system
[RASIS, LASIS, RPSIS, LPSIS, RPS, LPS] = deal(  pelvisTri.Points(RASIS_ind,:), ...
                                                pelvisTri.Points(LASIS_ind,:), ...
                                                pelvisTri.Points(RPSIS_ind,:), ...
                                                pelvisTri.Points(LPSIS_ind,:), ...
                                                pelvisTri.Points(RPS_ind,:), ...
                                                pelvisTri.Points(LPS_ind,:)); 

% check if bone landmarks are correctly identified or axes were incorrect
% TEST: inter-ASIS distance must be larger than inter-PSIS
if norm(RASIS-LASIS)<norm(RPSIS-LPSIS)
    % inform user
    disp('GIBOK_pelvis.')
    disp('Inter-ASIS distance is shorter than inter-PSIS distance.')
    disp('Likely error in guessing medical image axes. Flipping X-axis.')
    % switch ASIS and PSIS
    % temp variables
    LPSIS_temp = RASIS;
    RPSIS_temp = LASIS;
    % assign asis
    LASIS = RPSIS;
    RASIS = LPSIS;
    % update psis
    LPSIS = LPSIS_temp;
    RPSIS = RPSIS_temp;
    % TODO: recalculate synphisis with X = -X
end

% defining the ref system (global)
PelvisOr = (RASIS+LASIS)'/2.0;

% segment reference system
BCS.CenterVol = CenterVol;
BCS.Origin = PelvisOr;
BCS.InertiaMatrix = InertiaMatrix;
BCS.V = CS_pelvis_ISB(RASIS, LASIS, RPSIS, LPSIS);

% storing joint details
JCS.ground_pelvis.V                 = BCS.V;
JCS.ground_pelvis.Origin            = PelvisOr;%[3x1] as Origin should be
JCS.ground_pelvis.child_location    = PelvisOr'*dim_fact;%[1x3] as in OpenSim
JCS.ground_pelvis.child_orientation = computeXYZAngleSeq(BCS.V);%[1x3] as in OpenSim

% define hip parent
hip_name = ['hip_', side_low];
JCS.(hip_name).parent_orientation        = computeXYZAngleSeq(BCS.V);

% Export bone landmarks(pelvis ref system)
pelvisBL.RASI     = RASIS;
pelvisBL.LASI     = LASIS;
pelvisBL.RPSI     = RPSIS;
pelvisBL.LPSI     = LPSIS;
pelvisBL.RPS      = RPS;
pelvisBL.LPS      = LPS;

% debug plot
label_switch = 1;
if result_plots == 1
    figure('Name', ['Kai2014 | bone: pelvis | side: ', side_low])
    plotTriangLight(pelvisTri, BCS, 0); hold on
%     quickPlotRefSystem(CS)
    quickPlotRefSystem(JCS.ground_pelvis);
    trisurf(LargestTriangle,'facealpha',0.4,'facecolor','y',...
        'edgecolor','k');

    % plot markers and labels
    plotBoneLandmarks(pelvisBL, label_switch)
end

% final printout
disp('Done.');

end
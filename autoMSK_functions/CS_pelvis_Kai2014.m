%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         % 
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Author: Luca Modenese                                                %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
function [ CS, JCS, PelvisBL] = CS_pelvis_Kai2014(Pelvis, result_plots, debug_plots, label_switch, in_mm)

if nargin<2; result_plots=1; end
if nargin<3;     debug_plots = 0;  end
if nargin<4;     label_switch = 0;  end
if nargin<5;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% Initial guess of CS direction [JB]
% RISB2Glob_guess: principal inertial axes named as ISB (guess)
[RISB2Glob_guess, LargestTriangle] = pelvis_get_correct_first_CS(Pelvis);

% Get eigen vectors V_all and volumetric center
[~, CenterVol, InertiaMatrix, D ] =  TriInertiaPpties(Pelvis);

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
[ PelvisPseudoISB, ~ , ~ ] = TriChangeCS( Pelvis, RISB2Glob_guess, CenterVol);

% In ISB reference system: right side if z>0, upwards if Y>0
R_side_ind = PelvisPseudoISB.Points(:,3)>0;

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
[RASIS, LASIS, RPSIS, LPSIS, RPS, LPS] = deal(  Pelvis.Points(RASIS_ind,:), ...
                                                Pelvis.Points(LASIS_ind,:), ...
                                                Pelvis.Points(RPSIS_ind,:), ...
                                                Pelvis.Points(LPSIS_ind,:), ...
                                                Pelvis.Points(RPS_ind,:), ...
                                                Pelvis.Points(LPS_ind,:)); 

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
CS.V = CS_pelvis_ISB(RASIS, LASIS, RPSIS, LPSIS);

% segment reference system
CS.CenterVol = CenterVol;
CS.InertiaMatrix = InertiaMatrix;
CS.Origin = CenterVol;

% storing joint details
JCS.ground_pelvis.V                 = CS.V;
JCS.ground_pelvis.Origin            = PelvisOr;
JCS.ground_pelvis.child_location    = PelvisOr*dim_fact;
JCS.ground_pelvis.child_orientation = computeXYZAngleSeq(CS.V);

% define hip_r parent
JCS.hip_r.parent_orientation        = computeXYZAngleSeq(CS.V);

% Export bone landmarks
PelvisBL.RASIS     = RASIS; % in Pelvis ref
PelvisBL.LASIS     = LASIS; % in Pelvis ref
PelvisBL.RPSIS     = RPSIS; % in Pelvis ref
PelvisBL.LPSIS     = LPSIS; % in Pelvis ref
PelvisBL.RPS       = RPS;
PelvisBL.LPS       = LPS;

% debug plot
if result_plots == 1
    figure('Name','Pelvis')
    PlotTriangLight(Pelvis, CS, 0); hold on
%     quickPlotRefSystem(CS)
    quickPlotRefSystem(JCS.ground_pelvis);
    trisurf(LargestTriangle,'facealpha',0.4,'facecolor','y',...
        'edgecolor','k');
    % plot markers
    BLfields = fields(PelvisBL);
    for nL = 1:numel(BLfields)
        cur_name = BLfields{nL};
        plotDot(PelvisBL.(cur_name), 'k', 7)
        if label_switch==1
            text(PelvisBL.(cur_name)(1),...
                PelvisBL.(cur_name)(2),...
                PelvisBL.(cur_name)(3),...
                ['  ',cur_name],...
                'VerticalAlignment', 'Baseline',...
                'FontSize',8);
        end
    end
end

end
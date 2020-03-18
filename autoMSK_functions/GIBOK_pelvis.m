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
function [ CS, JCS, PelvisBL] = GIBOK_pelvis(Pelvis, result_plots,in_mm)

if nargin<2; result_plots=1; end
% check units
if nargin<3;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% guess of direction of axes on medical images (not always correct)
% Z : pointing cranially
% Y : pointing posteriorly
% X : pointing medio-laterally
% translating this direction in ISB reference system:
% -------------------------------------------------------------------------
% Modification of initial guess of CS direction [JB]
[BL, RotISB2Glob, CenterVol, InertiaMatrix ] = pelvis_get_correct_first_CS(Pelvis);
% x_pelvis_in_global = Xpig';
% y_pelvis_in_global = Ypig';
% z_pelvis_in_global = Zpig';
% 
% x_pelvis_in_global = [0 -1 0];
% y_pelvis_in_global = [0 0 1];
% z_pelvis_in_global = [-1 0 0];
% 
% % building the rot mat from global to pelvis ISB (roughly)
% % RGlob2Pelvis = [x_pelvis_in_global; y_pelvis_in_global; z_pelvis_in_global];
% 
% % Get eigen vectors V_all and volumetric center
% [eigVctrs, CenterVol, InertiaMatrix, D ] =  TriInertiaPpties(Pelvis);
% 
% % [ PelvisInertia, ~ , ~ ] = TriChangeCS( Pelvis);
% 
% % clarifying that this rotation goes inertial to global
% RInert2Glob = eigVctrs;
% 
% % aligning pelvis ref system to ISB one provided
% [~, ind_x_pelvis] = max(abs(RInert2Glob'*x_pelvis_in_global'));
% [~, ind_y_pelvis] = max(abs(RInert2Glob'*y_pelvis_in_global'));
% [~, ind_z_pelvis] = max(abs(RInert2Glob'*z_pelvis_in_global'));
% 
% % signs of axes for the largest component
% sign_x_pelvis = sign(RInert2Glob'*x_pelvis_in_global');
% sign_y_pelvis = sign(RInert2Glob'*y_pelvis_in_global');
% sign_z_pelvis = sign(RInert2Glob'*z_pelvis_in_global');
% sign_x_pelvis = sign_x_pelvis(ind_x_pelvis);
% sign_y_pelvis = sign_y_pelvis(ind_y_pelvis);
% sign_z_pelvis = sign_z_pelvis(ind_z_pelvis);
% 
% RotISB2Glob = [sign_x_pelvis*eigVctrs(:, ind_x_pelvis),...  
%                sign_y_pelvis*eigVctrs(:, ind_y_pelvis),...
%                sign_z_pelvis*eigVctrs(:, ind_z_pelvis)];
%            
% % RInert2ISB = RInert2Glob*RotISB2Glob';
% %
% % -------------------------------------------------------------------------
% 
% % generating a triangulated pelvis with coordinate system ISB (see comment
% % in function). Pseudo because there are still possible errors (see check
% % below).
% [ PelvisPseudoISB, ~ , ~ ] = TriChangeCS( Pelvis, RotISB2Glob, CenterVol);
% 
% % In ISB reference system, points at the right have positive z coordinates
% % max z should be ASIS
% R_side_ind = PelvisPseudoISB.Points(:,3)>0;
% [~, RASIS_ind] = max(PelvisPseudoISB.Points(:,1).*R_side_ind);
% [~, LASIS_ind] = max(PelvisPseudoISB.Points(:,1).*~R_side_ind);
% [~, RPSIS_ind] = min(PelvisPseudoISB.Points(:,1).*R_side_ind);
% [~, LPSIS_ind] = min(PelvisPseudoISB.Points(:,1).*~R_side_ind);
% 
% % extract points on bone
% RASIS = [Pelvis.Points(RASIS_ind,1),Pelvis.Points(RASIS_ind,2), Pelvis.Points(RASIS_ind,3)];
% LASIS = [Pelvis.Points(LASIS_ind,1),Pelvis.Points(LASIS_ind,2), Pelvis.Points(LASIS_ind,3)];
% RPSIS = [Pelvis.Points(RPSIS_ind,1),Pelvis.Points(RPSIS_ind,2), Pelvis.Points(RPSIS_ind,3)];
% LPSIS = [Pelvis.Points(LPSIS_ind,1),Pelvis.Points(LPSIS_ind,2), Pelvis.Points(LPSIS_ind,3)];
% 
% %
% % -------------------------------------------------------------------------
% extract points on bone in CT/MRI Reference Frame
RASIS = BL.RASIS;
LASIS = BL.LASIS;
RPSIS = BL.RPSIS;
LPSIS = BL.LPSIS;


% check if bone landmarks are correctly identified or axes were incorrect
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
end

% defining the ref system (global)
PelvisOr = (RASIS+LASIS)'/2.0;
Z = normalizeV(RASIS-LASIS);
temp_X = ((RASIS+LASIS)/2.0) - ((RPSIS+LPSIS)/2.0);
pseudo_X = temp_X/norm(temp_X);
Y = normalizeV(cross(Z, pseudo_X));
X = normalizeV(cross(Y, Z));

% segment reference system
CS.CenterVol = CenterVol;
CS.InertiaMatrix = InertiaMatrix;
% ISB reference system
CS.Origin = CenterVol;
% CS.X = X; CS.Y = Y; CS.Z = Z;
CS.V = [X Y Z];

% storing joint details
JCS.ground_pelvis.V = CS.V;
JCS.ground_pelvis.Origin = PelvisOr;
JCS.ground_pelvis.child_location    = PelvisOr*dim_fact;
JCS.ground_pelvis.child_orientation = computeZXYAngleSeq(CS.V);

% define hip_r parent
JCS.hip_r.parent_orientation        = computeZXYAngleSeq(CS.V);

% debug plot
if result_plots == 1
    PlotTriangLight(Pelvis, CS, 1); hold on
    quickPlotRefSystem(CS)
    quickPlotRefSystem(JCS.ground_pelvis);
    plotDot(RASIS, 'k', 7)
    plotDot(LASIS, 'k', 7)
    plotDot(LPSIS, 'k', 7)
    plotDot(RPSIS, 'k', 7)
end

% Export bone landmarks
PelvisBL.RASIS     = RASIS; % in Pelvis ref
PelvisBL.LASIS     = LASIS; % in Pelvis ref
PelvisBL.RPSIS     = RPSIS; % in Pelvis ref
PelvisBL.LPSIS     = LPSIS; % in Pelvis ref

end
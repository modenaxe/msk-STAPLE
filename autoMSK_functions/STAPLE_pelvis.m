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
function [ CS, JCS, PelvisBL] = GIBOK_pelvis(Pelvis, result_plots, debug_plots, label_switch, in_mm)

if nargin<2; result_plots=1; end
if nargin<3;     debug_plots = 0;  end
if nargin<4;     label_switch = 1;  end
if nargin<5;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% guess of direction of axes on medical images (not always correct)
% Z : pointing cranially
% Y : pointing posteriorly
% X : pointing medio-laterally
% translating this direction in ISB reference system:
% -------------------------------------------------------------------------

% inertial axes
[V_all, CenterVol, InertiaMatrix, D ] =  TriInertiaPpties(Pelvis);

% Modification of initial guess of CS direction [JB]
[RotPseudoISB2Glob, LargestTriangle] = pelvis_get_correct_first_CS(Pelvis, debug_plots);

%% Get the RPSIS and LPSIS raw BoneLandmarks (BL)
[ PelvisPseudoISB, ~ , ~ ] = TriChangeCS( Pelvis, RotPseudoISB2Glob, CenterVol);

% get the bony landmarks
% Along an axis oriented superiorly and a bit on the right we find
% projected on this axis succesively RASIS, LASIS then SYMP
[~, ind_XYZ] = max(abs(RotPseudoISB2Glob));

% RASIS_ind = find(LargestTriangle.Points(:,ind_XYZ(2))>0 & LargestTriangle.Points(:,ind_XYZ(3))>0);
% LASIS_ind = find(LargestTriangle.Points(:,ind_XYZ(2))>0 & LargestTriangle.Points(:,ind_XYZ(3))<0);

%---------------------------
% THIS IS NOT GENERIC
%---------------------------
% U_SupSupRight = normalizeV(4*RotPseudoISB2Glob(:,2)+RotPseudoISB2Glob(:,3));
% [~,I] = sort(LargestTriangle.Points*U_SupSupRight);
%------------------------------------------
% project vectors on Z (SYMP is the minimal one)
[~, I] = sort(abs((LargestTriangle.Points-CenterVol')*RotPseudoISB2Glob(:,3)));
ASI_inds = I(2:3);
ind_RASIS = find(((LargestTriangle.Points(ASI_inds, : )-CenterVol')*RotPseudoISB2Glob(:,3))>0);
ind_LASIS = find(((LargestTriangle.Points(ASI_inds, : )-CenterVol')*RotPseudoISB2Glob(:,3))<0);
SYMP  = LargestTriangle.Points(I(1), : );
RASIS = LargestTriangle.Points(ASI_inds(ind_RASIS), : );
LASIS = LargestTriangle.Points(ASI_inds(ind_LASIS), : );

% Get the Posterior, Superior, Right eigth of the pelvis
Nodes_RPSIS = find( PelvisPseudoISB.Points(:,1) < 0 & ...
    PelvisPseudoISB.Points(:,2) > 0 & ...
    PelvisPseudoISB.Points(:,3) > 0 ) ;
Pelvis_RPSIS = TriReduceMesh(Pelvis, [], Nodes_RPSIS);
% Find the most posterior points in this eigth
[~,Imin] = min(Pelvis_RPSIS.Points*RotPseudoISB2Glob(:,1));
RPSIS = Pelvis_RPSIS.Points(Imin,:);

% Get the Posterior, Superior, Left eigth of the pelvis
Nodes_LPSIS = find( PelvisPseudoISB.Points(:,1) < 0 & ...
    PelvisPseudoISB.Points(:,2) > 0 & ...
    PelvisPseudoISB.Points(:,3) < 0 ) ;
Pelvis_LPSIS = TriReduceMesh(Pelvis, [], Nodes_LPSIS);
% Find the most posterior points in this eigth
[~,Imin] = min(Pelvis_LPSIS.Points*RotPseudoISB2Glob(:,1));
LPSIS = Pelvis_LPSIS.Points(Imin,:);


% check if bone landmarks are correctly identified or axes were incorrect
if norm(RASIS-LASIS)<norm(RPSIS-LPSIS)
    % inform user
    disp('GIBOK_pelvis.')
    warndlg('Inter-ASIS distance is shorter than inter-PSIS distance. Better check manually.')
end
% segment reference system
CS.CenterVol = CenterVol;
CS.Origin = CS.CenterVol;
CS.InertiaMatrix = InertiaMatrix;

% ISB reference system
PelvisOr = (RASIS+LASIS)'/2.0;
% CS.V = RotPseudoISB2Glob;
CS.V = CS_pelvis_ISB(RASIS, LASIS, RPSIS, LPSIS);

% storing joint details
JCS.ground_pelvis.V = CS.V;
JCS.ground_pelvis.Origin = PelvisOr;
JCS.ground_pelvis.child_location    = PelvisOr*dim_fact;
JCS.ground_pelvis.child_orientation = computeXYZAngleSeq(CS.V);

% define hip_r parent
JCS.hip_r.parent_orientation        = computeXYZAngleSeq(CS.V);

% Export bone landmarks
PelvisBL.RASIS     = RASIS; 
PelvisBL.LASIS     = LASIS; 
PelvisBL.RPSIS     = RPSIS; 
PelvisBL.LPSIS     = LPSIS; 
PelvisBL.SYMP      = SYMP;

% debug plot
if result_plots == 1
    plotTriangLight(Pelvis, CS, 1); hold on
    quickPlotRefSystem(CS)
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
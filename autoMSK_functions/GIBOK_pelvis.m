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
% Modification of initial guess of CS direction [JB]
[PelvisBL, ~, CenterVol, InertiaMatrix ] = pelvis_get_correct_first_CS(Pelvis);

% extract points on bone in CT/MRI Reference Frame
RASIS = PelvisBL.RASIS;
LASIS = PelvisBL.LASIS;
RPSIS = PelvisBL.RPSIS;
LPSIS = PelvisBL.LPSIS;

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
JCS.ground_pelvis.child_orientation = computeXYZAngleSeq(CS.V);

% define hip_r parent
JCS.hip_r.parent_orientation        = computeXYZAngleSeq(CS.V);

% Export bone landmarks
% PelvisBL points are defined from the initialization function, see above

% debug plot
if result_plots == 1
    PlotTriangLight(Pelvis, CS, 1); hold on
    quickPlotRefSystem(CS)
    quickPlotRefSystem(JCS.ground_pelvis);
    
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
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
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
% script that takes as an input a femur geometry and computes the ISB
% reference system based on Kai et al. 2014.

function [CS, JCS, FemurBL_r] = Kai2014_femur(Femur, DistFem, result_plots, debug_plots, in_mm)

% result plots on by default, debug off
if nargin<3; result_plots = 0; end
if nargin<4; debug_plots = 0; end
if nargin<5;     in_mm = 1;  end% check units
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% if this is an entire femur then cut it in two parts
% but keep track of all geometries
if ~exist('DistFem','var') || isempty(DistFem)
      V_all = pca(Femur.Points);
      [ U_DistToProx ] = femur_guess_CS( Femur, debug_plots );
      [ProxFem, DistFem] = cutLongBoneMesh(Femur, U_DistToProx);
      [ ~, CenterVol] = TriInertiaPpties(Femur);
else
    % join two parts in one triangulation
    ProxFem = Femur;
    Femur = TriUnite(DistFem, ProxFem);
    [ V_all, CenterVol] = TriInertiaPpties( Femur );
end

%-------------------------------------
% Z0: points upwards (inertial axis) 
% Y0: points medio-lat (from OT and Z0 in findFemoralHead.m)
% X0: used only in Kai2014
%-------------------------------------

% Initial estimate of the Distal-to-Proximal (DP) axis Z0
% Check that the distal femur is 'below' the proximal femur,
% invert Z0 direction otherwise
Z0 = V_all(:,1);
Z0 = sign((mean(ProxFem.Points)-mean(DistFem.Points))*Z0)*Z0;

% store approximate Z direction and centre of mass of triangulation
CS.Z0 = Z0;
CS.CenterVol = CenterVol;

% find femoral head
[CS, ~] = Kai2014_femur_fitSphere2FemHead(ProxFem, CS, debug_plots);

% slicing the femoral condyles
CS = Kai2014_femur_fitSpheres2Condyles(DistFem, CS, debug_plots);

% common axes: X is orthog to Y and Z, which are not mutually perpend
Z = normalizeV(CS.Center_Lat-CS.Center_Med);
Y = normalizeV(CS.CenterFH_Kai- CS.KneeCenter);
X = normalizeV(cross(Y,Z));

% define the segment CS
CS.Origin = CenterVol;
CS.X = X;
CS.Y = Y;
CS.Z = normalizeV(cross(X, Y));
CS.V = [X Y Z];

% define the hip reference system
Zml_hip = normalizeV(cross(X, Y));
JCS.hip_r.V  = [X Y Zml_hip];
JCS.hip_r.child_location    = CS.CenterFH_Kai*dim_fact;
JCS.hip_r.child_orientation = computeXYZAngleSeq(JCS.hip_r.V);
JCS.hip_r.Origin = CS.CenterFH_Kai;

% define the knee reference system
Ydp_knee = normalizeV(cross(Z, X));
JCS.knee_r.V  = [X Ydp_knee Z];
JCS.knee_r.parent_location = CS.KneeCenter*dim_fact;
JCS.knee_r.parent_orientation = computeXYZAngleSeq(JCS.knee_r.V);
JCS.knee_r.Origin = CS.KneeCenter;

% landmark bone according to CS (only Origin and CS.V are used)
FemurBL_r   = landmarkTriGeomBone(Femur, CS, 'femur_r');

% result plot
label_switch=1;
if result_plots == 1
    figure
    alpha = 0.5;
    subplot(2,2,[1,3]);
    plotTriangLight(Femur, CS, 0)
    quickPlotRefSystem(CS);
    quickPlotRefSystem(JCS.hip_r);
    quickPlotRefSystem(JCS.knee_r);
    % plot markers
    BLfields = fields(FemurBL_r);
    for nL = 1:numel(BLfields)
        cur_name = BLfields{nL};
        plotDot(FemurBL_r.(cur_name), 'k', 7)
        if label_switch==1
            text(FemurBL_r.(cur_name)(1),...
                FemurBL_r.(cur_name)(2),...
                FemurBL_r.(cur_name)(3),...
                ['  ',cur_name],...
                'VerticalAlignment', 'Baseline',...
                'FontSize',8);
        end
    end
    
    subplot(2,2,2); % femoral head
    plotTriangLight(ProxFem, CS, 0); hold on
    quickPlotRefSystem(JCS.hip_r);
    plotSphere(CS.CenterFH_Kai, CS.RadiusFH_Kai, 'g', alpha);
    
    subplot(2,2,4);
    plotTriangLight(DistFem, CS, 0); hold on
    quickPlotRefSystem(JCS.knee_r);
    plotSphere(CS.Center_Med, CS.Radius_Med, 'r', alpha);
    plotSphere(CS.Center_Lat, CS.Radius_Lat, 'b', alpha);
end

end


% KAI2014_FEMUR Implement a custom implementation of the method for 
% defining a reference system of the femur described in the following 
% publication: Kai, Shin, et al. Journal of biomechanics 47.5 (2014): 
% 1229-1233. https://doi.org/10.1016/j.jbiomech.2013.12.013
% The algorithm creates a reference system from the centre of the femoral 
% head and the centres of the femoral condyles, after identifying these
% feature through slicing the bone geometry with planes perpendicular to
% the longitudinal axis and anterior-posterior axis respectively.
%
%   [CS, JCS, FemurBL] = Kai2014_femur(femurTri, side, result_plots, ...
%                                      debug_plots, in_mm)
%
% Inputs:
%   femurTri - MATLAB triangulation object of the entire femoral geometry.
%
%   side - 
%
%   result_plots - enable plots of final fittings and reference systems. 
%       Value: 1 (default) or 0.
%
%   debug_plots - enable plots used in debugging. Value: 1 or 0 (default).
%
% Outputs:
%   CS - update input structure including radii and centres of the spheres
%       fitted to the femoral condyles identified by the algorithm.
%
% See also KAI2014_FEMUR, KAI2014_FEMUR_FITSPHERE2FEMHEAD.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese & Jean-Baptiste Renault. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%

function [CS, JCS, FemurBL] = Kai2014_femur(femurTri, side, result_plots, debug_plots, in_mm)

% result plots on by default, debug off
if nargin<2;    side = 'r';       end
if nargin<3;    result_plots = 1; end
if nargin<4;    debug_plots = 0;  end
if nargin<5;    in_mm = 1;        end
if in_mm == 1;  dim_fact = 0.001; else;  dim_fact = 1; end

% get sign correspondent to body side
[side_sign, side_low] = bodySide2Sign(side);

% joint names
hip_name = ['hip_',side_low];
knee_name = ['knee_',side_low];

% it is assumed that, even for partial geometries, the femoral bone is
% always provided as unique file. Previous versions of this function did
% use separated proximal and distal triangulations. Check Git history if
% you are interested in that.
V_all = pca(femurTri.Points);

% guess vertical direction, pointing proximally
[ U_DistToProx ] = femur_guess_CS( femurTri, debug_plots );

% divide bone in three parts and take proximal and distal 
[ProxFem, DistFem] = cutLongBoneMesh(femurTri, U_DistToProx);

% centre of volume
[ ~, CenterVol] = TriInertiaPpties(femurTri);

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
% adjust for body side, so that U_tmp is aligned as Z_ISB
Z = normalizeV(CS.Center_Lat-CS.Center_Med)*side_sign;
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
JCS.(hip_name).V  = [X Y Zml_hip];
JCS.(hip_name).child_location    = CS.CenterFH_Kai*dim_fact;
JCS.(hip_name).child_orientation = computeXYZAngleSeq(JCS.(hip_name).V);
JCS.(hip_name).Origin = CS.CenterFH_Kai;

% define the knee reference system
Ydp_knee = normalizeV(cross(Z, X));
JCS.(knee_name).V  = [X Ydp_knee Z];
JCS.(knee_name).parent_location = CS.KneeCenter*dim_fact;
JCS.(knee_name).parent_orientation = computeXYZAngleSeq(JCS.(knee_name).V);
JCS.(knee_name).Origin = CS.KneeCenter;

% landmark bone according to CS (only Origin and CS.V are used)
FemurBL   = landmarkBoneGeom(femurTri, CS, ['femur_', side_low]);

% result plot
label_switch=1;
if result_plots == 1
    figure
    alpha = 0.5;
    subplot(2,2,[1,3]);
    plotTriangLight(femurTri, CS, 0)
    quickPlotRefSystem(CS);
    quickPlotRefSystem(JCS.(hip_name));
    quickPlotRefSystem(JCS.(knee_name));
    
    % plot markers and labels
    plotBoneLandmarks(FemurBL, label_switch)
    
    subplot(2,2,2); % femoral head
    plotTriangLight(ProxFem, CS, 0); hold on
    quickPlotRefSystem(JCS.(hip_name));
    plotSphere(CS.CenterFH_Kai, CS.RadiusFH_Kai, 'g', alpha);
    
    subplot(2,2,4);
    plotTriangLight(DistFem, CS, 0); hold on
    quickPlotRefSystem(JCS.(knee_name));
    plotSphere(CS.Center_Med, CS.Radius_Med, 'r', alpha);
    plotSphere(CS.Center_Lat, CS.Radius_Lat, 'b', alpha);
end

end


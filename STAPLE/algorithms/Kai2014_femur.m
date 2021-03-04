% KAI2014_FEMUR Custom implementation of the method for 
% defining a reference system of the femur described in the following 
% publication: Kai, Shin, et al. Journal of biomechanics 47.5 (2014): 
% 1229-1233. https://doi.org/10.1016/j.jbiomech.2013.12.013
% The algorithm creates a reference system from the centre of the femoral 
% head and the centres of the femoral condyles, after identifying these
% feature through slicing the bone geometry with planes perpendicular to
% the longitudinal axis and anterior-posterior axis respectively.
%
%   [BCS, JCS, femurBL] = Kai2014_femur(femurTri,...
%                                      side_raw,...
%                                      result_plots, ...
%                                      debug_plots, in_mm)
%
% Inputs:
%   femurTri - MATLAB triangulation object of the entire femoral geometry.
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
%   CS - MATLAB structure containing body reference system and other 
%       geometrical features identified by the algorithm.
%
%   JCS - MATLAB structure containing the joint reference systems connected
%       to the bone being analysed. These might NOT be sufficient to define
%       a joint of the musculoskeletal model yet.
%
%   femurBL - MATLAB structure containing the bony landmarks identified 
%       on the bone geometries based on the defined reference systems. Each
%       field is named like a landmark and contain its 3D coordinates.
%
% See also KAI2014_FEMUR, KAI2014_FEMUR_FITSPHERE2FEMHEAD.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese & Jean-Baptiste Renault. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%

function [BCS, JCS, femurBL, AuxCSInfo] = Kai2014_femur(femurTri,...
                                            side_raw,...
                                            result_plots,...
                                            debug_plots,...
                                            in_mm)

% result plots on by default, debug off
if nargin<2;    side_raw = 'r';   end
if nargin<3;    result_plots = 1; end
if nargin<4;    debug_plots = 0;  end
if nargin<5;    in_mm = 1;        end
if in_mm == 1;  dim_fact = 0.001; else;  dim_fact = 1; end

% get sign correspondent to body side
[side_sign, side_low] = bodySide2Sign(side_raw);

% joint names
hip_name = ['hip_',side_low];
knee_name = ['knee_',side_low];

% inform user
disp('---------------------')
disp('   KAI2014 - FEMUR   '); 
disp('---------------------')
% inform user about settings
disp(['* Body Side   : ', upper(side_low)]);
disp(['* Fit Method  : ', 'spheres']);
disp(['* Result Plots: ', convertBoolean2OnOff(result_plots)]);
disp(['* Debug  Plots: ', convertBoolean2OnOff(debug_plots)]);
disp(['* Triang Units: ', 'mm']);
disp('---------------------')
disp('Initializing method...')

% it is assumed that, even for partial geometries, the femoral bone is
% always provided as unique file. Previous versions of this function did
% use separated proximal and distal triangulations. Check Git history if
% you are interested in that.
disp('Computing PCA for given geometry...');
V_all = pca(femurTri.Points);

% guess vertical direction, pointing proximally
[ U_DistToProx ] = femur_guess_CS( femurTri, debug_plots );

% divide bone in three parts and take proximal and distal 
[ProxFem, DistFem] = cutLongBoneMesh(femurTri, U_DistToProx);

% centre of volume
[ ~, CenterVol, InertiaMatrix] = TriInertiaPpties(femurTri);

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
AuxCSInfo.Z0 = Z0;
AuxCSInfo.CenterVol = CenterVol;

% find femoral head
[AuxCSInfo, ~] = Kai2014_femur_fitSphere2FemHead(ProxFem, AuxCSInfo, debug_plots);

% slicing the femoral condyles
disp('Processing femoral condyles:')
AuxCSInfo = Kai2014_femur_fitSpheres2Condyles(DistFem, AuxCSInfo, debug_plots);

% common axes: X is orthog to Y and Z, which are not mutually perpend
% adjust for body side, so that U_tmp is aligned as Z_ISB
Z = normalizeV(AuxCSInfo.Center_Lat-AuxCSInfo.Center_Med)*side_sign;
Y = normalizeV(AuxCSInfo.CenterFH_Kai- AuxCSInfo.KneeCenter);
X = normalizeV(cross(Y,Z));

% segment reference system
BCS.CenterVol = CenterVol;
BCS.Origin = AuxCSInfo.CenterFH_Kai'; % we want [3x1]
BCS.InertiaMatrix = InertiaMatrix;
BCS.V = [X Y normalizeV(cross(X, Y))]; % same as hip.V

% define the hip reference system
Zml_hip = normalizeV(cross(X, Y));
JCS.(hip_name).V  = [X Y Zml_hip];
JCS.(hip_name).child_location    = AuxCSInfo.CenterFH_Kai*dim_fact;
JCS.(hip_name).child_orientation = computeXYZAngleSeq(JCS.(hip_name).V);
JCS.(hip_name).Origin = AuxCSInfo.CenterFH_Kai'; % [3x1] as Origin should be

% define the knee reference system
Ydp_knee = normalizeV(cross(Z, X));
JCS.(knee_name).V  = [X Ydp_knee Z];
JCS.(knee_name).parent_location = AuxCSInfo.KneeCenter*dim_fact;
JCS.(knee_name).parent_orientation = computeXYZAngleSeq(JCS.(knee_name).V);
JCS.(knee_name).Origin = AuxCSInfo.KneeCenter'; % [3x1] as Origin should be

% landmark bone according to CS (only Origin and CS.V are used)
disp('Landmarking...')
femurBL   = landmarkBoneGeom(femurTri, BCS, ['femur_', side_low]);

% result plot
label_switch=1;
if result_plots == 1
    figure('Name', ['Kai2014 | bone: femur | side: ', side_low])
    alpha = 0.5;
    subplot(2,2,[1,3]);
    plotTriangLight(femurTri, BCS, 0)
    quickPlotRefSystem(BCS);
    quickPlotRefSystem(JCS.(hip_name));
    quickPlotRefSystem(JCS.(knee_name));
    
    % plot markers and labels
    plotBoneLandmarks(femurBL, label_switch)
    
    subplot(2,2,2); % femoral head
    plotTriangLight(ProxFem, BCS, 0); hold on
    quickPlotRefSystem(JCS.(hip_name));
    plotSphere(AuxCSInfo.CenterFH_Kai, AuxCSInfo.RadiusFH_Kai, 'g', alpha);
    
    subplot(2,2,4);
    plotTriangLight(DistFem, BCS, 0); hold on
    quickPlotRefSystem(JCS.(knee_name));
    plotSphere(AuxCSInfo.Center_Med, AuxCSInfo.Radius_Med, 'r', alpha);
    plotSphere(AuxCSInfo.Center_Lat, AuxCSInfo.Radius_Lat, 'b', alpha);
end

% final printout
disp('Done.');

end


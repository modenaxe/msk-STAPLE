% KAI2014_TIBIA Custom implementation of the method for 
% defining a reference system of the tibia described in the following 
% publication: Kai, Shin, et al. Journal of biomechanics 47.5 (2014): 
% 1229-1233. https://doi.org/10.1016/j.jbiomech.2013.12.013.
% The algorithm slices the tibia along the vertical axis identified via
% principal component analysis, identifies the largest section and fits an
% ellips to it. It finally uses the ellipse axes to define the reference
% system. This implementation includes several non-obvious checks to ensure 
% that the bone geometry is always sliced in the correct direction.
%
%   [CS, JCS, tibiaBL] = Kai2014_tibia(tibiaTri,...
%                                      side_raw,...
%                                      result_plots, ...
%                                      debug_plots, in_mm)
%
% Inputs:
%   tibiaTri - MATLAB triangulation object of the entire tibial geometry.
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
% See also KAI2014_FEMUR, KAI2014_PELVIS, TRISLICEOBJALONGAXIS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese & Jean-Baptiste Renault. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [CS, JCS, tibiaBL] = Kai2014_tibia(tibiaTri,...
                                            side_raw,...
                                            result_plots,...
                                            debug_plots,...
                                            in_mm)

% Slices 1 mm apart as in Kai et al. 2014
slices_thickness = 1;

% default behaviour of results/debug plots
if nargin<2;     side_raw='r';      end
if nargin<3;     result_plots = 1;  end
if nargin<4;     debug_plots = 0;   end
if nargin<5;     in_mm = 1;         end %placeholder

% get sign correspondent to body side
[side_sign, side_low] = bodySide2Sign(side_raw);

% inform user about settings
disp('---------------------')
disp('   KAI2014 - TIBIA   '); 
disp('---------------------')
disp(['* Body Side   : ', upper(side_low)]);
disp(['* Fit Method  : ', 'N/A']);
disp(['* Result Plots: ', convertBoolean2OnOff(result_plots)]);
disp(['* Debug  Plots: ', convertBoolean2OnOff(debug_plots)]);
disp(['* Triang Units: ', 'mm']);
disp('---------------------')
disp('Initializing method...')

% it is assumed that, even for partial geometries, the tibial bone is
% always provided as unique file. Previous versions of this function did
% use separated proximal and distal triangulations. Check Git history if
% you are interested in that.
disp('Computing PCA for given geometry...');
V_all = pca(tibiaTri.Points);

% guess vertical direction, pointing proximally
U_DistToProx = tibia_guess_CS(tibiaTri, debug_plots);

% divide bone in three parts and take proximal and distal 
[ProxTib, DistTib] = cutLongBoneMesh(tibiaTri, U_DistToProx);

% center of the volume
[ ~, CenterVol] = TriInertiaPpties( tibiaTri );

% checks on vertical direction
Y0 = V_all(:,1);
% NOTE: not redundant for partial models, e.g. ankle model. If this check
% is not implemented the vertical axis is not aligned with the Z axis of
% the images.
Y0 = sign((mean(ProxTib.Points)-mean(DistTib.Points))*Y0)*Y0;

% slice tibia along axis and get maximum height
disp('Slicing tibia longitudinally...')
[~, ~, ~, ~, AltAtMax] = TriSliceObjAlongAxis(tibiaTri, Y0, slices_thickness);

% slice geometry at max area
[ Curves , ~, ~ ] = TriPlanIntersect(tibiaTri, Y0 , -AltAtMax );

% keep just the largest outline (tibia section)
[maxAreaSection, N_curves] = getLargerPlanarSect(Curves);

% check number of curves
if N_curves>2
    warning(['There are ', num2str(N_curves), ' section areas at the largest tibial slice.']);
    error('This should not be the case (only tibia and possibly fibula should be there).')
end

% Move the outline curve points in the inertial ref system, so the vertical
% component (:,1) is orthogonal to a plane
PtsCurves = vertcat(maxAreaSection.Pts)*V_all;

% Fit a planar ellipse to the outline of the tibia section
disp('Fitting ellipse to largest section...')
FittedEllipse = fit_ellipse(PtsCurves(:,2), PtsCurves(:,3));

% depending on the largest axes, YElpsMax is assigned.
% vector shapes justified by the rotation matrix used in fit_ellipse
% R       = [ cos_phi sin_phi; 
%             -sin_phi cos_phi ];
if FittedEllipse.a>FittedEllipse.b
    % horizontal ellipse
    ZElpsMax = V_all*[ 0; cos(FittedEllipse.phi); -sin(FittedEllipse.phi)];
else
    % vertical ellipse - get
    ZElpsMax = V_all*[ 0; sin(FittedEllipse.phi); cos(FittedEllipse.phi)];
end

% note that ZElpsMax and Y0 are perpendicular
% dot(ZElpsMax, Y0)

% check ellipse fitting
if debug_plots == 1
    figure
    ax1 = axes();
    plot(ax1, PtsCurves(:,2), PtsCurves(:,3)); hold on; axis equal
    FittedEllipse = fit_ellipse(PtsCurves(:,2), PtsCurves(:,3), ax1);
    plot([0 50], [0, 0], 'r', 'LineWidth', 4)
    plot([0 0], [0, 50], 'g', 'LineWidth', 4)
    xlabel('X'); ylabel('Y')
end

% centre of ellipse back to medical images reference system
CenterEllipse = transpose(V_all*[mean(PtsCurves(:,1)); % constant anyway
                                 FittedEllipse.X0_in;
                                 FittedEllipse.Y0_in]);

% identify lateral direction
[U_tmp, MostDistalMedialPt, just_tibia] = tibia_identify_lateral_direction(DistTib, Y0);
if just_tibia == 1; m_col = 'r'; else; m_col = 'b'; end

% adjust for body side, so that U_tmp is aligned as Z_ISB
U_tmp = side_sign*U_tmp;

% making Y0/U_temp normal to Z0 (still points laterally)
Z0_temp = normalizeV(U_tmp' - (U_tmp*Y0)*Y0); 

% here the assumption is that Y0 has correct m-l orientation               
ZElpsMax = sign(Z0_temp'*ZElpsMax)*ZElpsMax;

EllipsePts = transpose(V_all*[ones(length(FittedEllipse.data),1)*PtsCurves(1) FittedEllipse.data']');

% common axes: X is orthog to Y and Z, which are not mutually perpend
Y = normalizeV(Y0);
Z = normalizeV(ZElpsMax);
X = normalizeV(cross(Y, Z));

% segment reference system
CS.Origin        = CenterVol;
% CS.ElpsMaxPtVect = YElpsMax;
CS.ElpsPts       = EllipsePts;
Z_cs = normalizeV(cross(X, Y));
CS.V = [X Y Z_cs];

% define the knee reference system
joint_name = ['knee_',side_low];
Ydp_knee  = normalizeV(cross(Z, X));
JCS.(joint_name).Origin = CenterEllipse;
JCS.(joint_name).V = [X Ydp_knee Z]; 

% NOTE THAT CS.V and JCS.knee_r.V are the same, so the distinction is here
% purely formal. This is because all axes are perpendicular.

JCS.(joint_name).child_orientation = computeXYZAngleSeq(JCS.(joint_name).V);

% the knee axis is defined by the femoral fitting
% CS.knee_r.child_location = KneeCenter*dim_fact;

% the talocrural joint is also defined by the talus fitting.
% apart from the reference system -> NB: Z axis to switch with talus Z
% CS.ankle_r.parent_orientation = computeZXYAngleSeq(CS.V_knee);

% landmark bone according to CS (only Origin and CS.V are used)
tibiaBL   = landmarkBoneGeom(tibiaTri, CS, ['tibia_',side_low]);
if just_tibia == 0
    tibiaBL.RLM = MostDistalMedialPt;
end
label_switch = 1;

% plot reference systems
if result_plots == 1
    % plot tibia and reference systems
    figure('Name', ['Kai2014 | bone: tibia | side: ', side_low])
    plotTriangLight(tibiaTri, CS, 0);
    quickPlotRefSystem(CS);
    quickPlotRefSystem(JCS.(joint_name));
    
    % plot markers and labels
    plotBoneLandmarks(tibiaBL, label_switch)

    % plot largest section
    plot3(maxAreaSection.Pts(:,1), maxAreaSection.Pts(:,2), maxAreaSection.Pts(:,3),'r-', 'LineWidth',2); hold on
    plotDot(MostDistalMedialPt, m_col, 4);
end

disp('Done.')

end


function [CS, JCS, TibiaBL_r] = STAPLE_tibia(Tibia, DistTib, result_plots, debug_plots)

% default behaviour of results/debug plots
if nargin<3;     result_plots = 1;  end
if nargin<4;     debug_plots = 0;  end

% if this is an entire tibia then cut it in two parts
% but keep track of all geometries
if ~exist('DistTib','var') || isempty(DistTib)
    % Only one mesh, this is a long bone that should be cutted in two
    % parts
    [ U_DistToProx ] = tibia_get_correct_first_CS(Tibia, debug_plots);
    [ProxTib, DistTib] = cutLongBoneMesh(Tibia, U_DistToProx);
else
    % join two parts in one triangulation
    ProxTib = Tibia;
    Tibia = TriUnite(DistTib, ProxTib);
end
[ V_all, CenterVol] = TriInertiaPpties( Tibia );

% checks on vertical direction
Y0 = V_all(:,1);
Y0 = sign((mean(ProxTib.Points)-mean(DistTib.Points))*Y0)*Y0;

% Slices 1 mm apart as in Kai et al. 2014
slices_thick = 1;
[~, ~, ~, ~, AltAtMax] = TriSliceObjAlongAxis(Tibia, Y0, slices_thick);

% slice at max area
[ Curves , ~, ~ ] = TriPlanIntersect(Tibia, Y0 , -AltAtMax );

% keep just the largest outline (tibia section)
[maxAreaSection, N_curves] = GIBOK_getLargerPlanarSect(Curves);

% check number of curves
if N_curves>2
    warning(['There are ', num2str(N_curves), ' section areas.']);
    error('This should not be the case (only tibia and possibly fibula should be there).')
end

% Move the outline curve points in the inertial ref system, so the vertical
% component (:,1) is on a plane
PtsCurves = vertcat(maxAreaSection.Pts)*V_all;

% Fit a planar ellipse to the outline of the tibia section
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
Ydp_knee  = normalizeV(cross(Z, X));
JCS.knee_r.Origin = CenterEllipse;
JCS.knee_r.V = [X Ydp_knee Z]; 

% NOTE THAT CS.V and JCS.knee_r.V are the same, so the distinction is here
% purely formal. This is because all axes are perpendicular.

JCS.knee_r.child_orientation = computeXYZAngleSeq(JCS.knee_r.V);

% the knee axis is defined by the femoral fitting
% CS.knee_r.child_location = KneeCenter*dim_fact;

% the talocrural joint is also defined by the talus fitting.
% apart from the reference system -> NB: Z axis to switch with talus Z
% CS.ankle_r.parent_orientation = computeZXYAngleSeq(CS.V_knee);

% landmark bone according to CS (only Origin and CS.V are used)
TibiaBL_r   = landmarkTriGeomBone(Tibia, CS, 'tibia_r');
if just_tibia == 0
    TibiaBL_r.RLM = MostDistalMedialPt;
end
label_switch = 1;

% plot reference systems
if result_plots == 1
    figure('Name', ['STAPLE | bone: tibia | side: ', side_low])
    PlotTriangLight(Tibia, CS, 0);
    quickPlotRefSystem(CS);
    quickPlotRefSystem(JCS.knee_r);
    % plot markers
    BLfields = fields(TibiaBL_r);
    for nL = 1:numel(BLfields)
        cur_name = BLfields{nL};
        plotDot(TibiaBL_r.(cur_name), 'k', 7)
        if label_switch==1
            text(TibiaBL_r.(cur_name)(1),...
                TibiaBL_r.(cur_name)(2),...
                TibiaBL_r.(cur_name)(3),...
                ['  ',cur_name],...
                'VerticalAlignment', 'Baseline',...
                'FontSize',8);
        end
    end
    % plot largest section
    plot3(maxAreaSection.Pts(:,1), maxAreaSection.Pts(:,2), maxAreaSection.Pts(:,3),'r-', 'LineWidth',2); hold on
    plotDot(MostDistalMedialPt, m_col, 4);
    title('Tibia - Kai et al. 2014')
end

end

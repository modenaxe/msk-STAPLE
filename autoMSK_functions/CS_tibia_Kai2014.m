
function CS = CS_tibia_Kai2014(Tibia, DistTib, debug_plot)

% check plots
if nargin<3;     debug_plot = 1;  end

% if this is an entire tibia then cut it in two parts
% but keep track of all geometries
if ~exist('DistTib','var')
    % Only one mesh, this is a long bone that should be cutted in two
    % parts
    V_all = pca(Tibia.Points);
    [ProxTib, DistTib] = cutLongBoneMesh(Tibia);
    [ ~, CenterVol] = TriInertiaPpties( Tibia );
else
    % join two parts in one triangulation
    ProxTib = Tibia;
    Tibia = TriUnite(DistTib, ProxTib);
    [ V_all, CenterVol] = TriInertiaPpties( Tibia );
end

% checks on vertical direction
Z0 = V_all(:,1);
Z0 = sign((mean(ProxTib.Points)-mean(DistTib.Points))*Z0)*Z0;

% Slices 1 mm apart as in Kai et al. 2014
slices_thick = 1;
[~, ~, ~, ~, AltAtMax] = TriSliceObjAlongAxis(Tibia, Z0, slices_thick);

% slice at max area
[ Curves , ~, ~ ] = TriPlanIntersect(Tibia, Z0 , -AltAtMax );

% keep just the largest outline (tibia section)
[maxAreaSection, N_curves] = GIBOK_getLargerPlanarSect(Curves);

% check number of curves
if N_curves>2
    warning(['There are ', num2str(N_curves), ' section areas.']);
    error('This should not be the case (only tibia and possibly fibula should be there).')
end

% plot max section to check
if debug_plot
    quickPlotTriang(Tibia,[], 1); hold on
    for nn = 1:N_curves
        plot3(maxAreaSection.Pts(:,1), maxAreaSection.Pts(:,2), maxAreaSection.Pts(:,3),'r-', 'LineWidth',3); hold on
    end
end

% Move the outline curve points in the inertial ref system, so the vertical
% component (:,1) is on a plane
PtsCurves = vertcat(maxAreaSection.Pts)*V_all;

% Fit a planar ellipse to the outline of the tibia section
FittedEllipse = fit_ellipse(PtsCurves(:,2), PtsCurves(:,3));

% back to medical images reference system
CenterEllipse = transpose(V_all*[mean(PtsCurves(:,1)); % constant anyway
                                 FittedEllipse.X0_in;
                                 FittedEllipse.Y0_in]);

% project the ellipse back to reference system
YElpsMax = V_all*[  0 ;
                   cos(FittedEllipse.phi);
                   sin(FittedEllipse.phi)]; % [LM: GIBOK had a -sin() (?) probable BUG]

% slice at centroid of distal tibia
[ ~, CenterVolTibDist] = TriInertiaPpties( DistTib );
d = CenterVolTibDist'*Z0;
[ DistCurves , ~, ~ ] = TriPlanIntersect(DistTib, Z0 , -d );
% check the number of curves on that slice
N_DistCurves = length(DistCurves);
just_tibia = 1;
if N_DistCurves == 2
    disp('Tibia and fibula have been detected.')
    just_tibia = 0;
elseif N_DistCurves>2
    warning(['There are ', num2str(N_DistCurves), ' section areas.']);
    error('This should not be the case (only tibia and possibly fibula should be there.')
end

% compute a vector pointing laterally (Z_ISB)
if just_tibia
    % Find the most distal point, it will be medial
    [~ , I_dist_fib] = min( Tibia.Points* -Z0 );
    MostDistalMedialPt = Tibia.Points(I_dist_fib,:);
    % vector pointing laterally
    U_tmp = CenterVolTibDist'- MostDistalMedialPt;
else
    %tibia and fibula
    % check which area is larger(Tibia)
    if DistCurves(1).Area>DistCurves(2).Area
        % vector from tibia section to fibular section
        U_tmp = mean(DistCurves(2).Pts) - mean(DistCurves(1).Pts);
    else
        U_tmp = -1 * (mean(DistCurves(2).Pts) - mean(DistCurves(1).Pts));
    end
end

% making U_temp normal to Z0 (still points laterally)
Y0_temp = normalizeV(U_tmp' - (U_tmp*Z0)*Z0); 

% here the assumption is that Y0 has correct m-l orientation               
YElpsMax = sign(Y0_temp'*YElpsMax)*YElpsMax;

% EllipsePts = transpose(V_all*[ones(length(FittedEllipse.data),1)*PtsCurves(1) FittedEllipse.data']');

% common axes: X is orthog to Y and Z, which are not mutually perpend
Y = normalizeV(Z0);
Z = normalizeV(YElpsMax);
X = cross(Y, Z);

% segment reference system
CS.Origin        = CenterVol;
% CS.CenterKnee  = CenterEllipse;
% CS.ElpsMaxPtVect = YElpsMax;
% CS.ElpsPts       = EllipsePts;
CS.X = X;
CS.Y = Y;
CS.Z = Z;

% define the knee reference system
Ydp_knee  = cross(Z, X);
JCS.knee_r.Origin = CenterEllipse;
JCS.knee_r.V = [X Ydp_knee Z];
JCS.knee_r.child_orientation = computeZXYAngleSeq(JCS.knee_r.V);

% the knee axis is defined by the femoral fitting
% CS.knee_r.child_location = KneeCenter*dim_fact;

% the talocrural joint is also defined by the talus fitting.
% apart from the reference system -> NB: Z axis to switch with talus Z
% CS.ankle_r.parent_orientation = computeZXYAngleSeq(CS.V_knee);

if debug_plot
    quickPlotRefSystem(CS);
    quickPlotRefSystem(JCS.knee_r)
end

end

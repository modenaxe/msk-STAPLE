
function CS = MSK_tibia_Kai2014(Tibia, DistTib, in_mm)

% check units
if nargin<3;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

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

warning('PCA WITH/WITHOT TIBIA NEEDS TESTNG')

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

% report if there are more than two curves
just_tibia = 1;
if N_curves == 2
    disp('Tibia and fibula have been detected.')
    just_tibia = 0;
elseif N_curves>2
    warning(['There are ', num2str(N_curves), ' section areas.']);
    error('This should not be the case (only tibia and fibula should be there.')
end

% debug plots
quickPlotTriang(Tibia,'m', 1); hold on
for nn = 1:N_curves
    plot3(maxAreaSection.Pts(:,1), maxAreaSection.Pts(:,2), maxAreaSection.Pts(:,3),'r-', 'LineWidth',4); hold on
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

YElpsMax = V_all*[  0 ;
                   cos(FittedEllipse.phi);
                   -sin(FittedEllipse.phi)];

% compute lateral direction
warning('==========================')
warning('THIS NEEDS PROPER TESTING')
warning('==========================')
[ ~, CenterVolTibDist] = TriInertiaPpties(DistTib);
if just_tibia
    % Find the most distal point, it will be medial
    [~ , I_dist_fib] = min( Tibia.Points* -Z0 );
    MostDistalMedialPt = Tibia.Points(I_dist_fib,:);
    % vector pointing laterally
    U_tmp = MostDistalMedialPt - CenterVolTibDist';
else %tibia and fibula
    warning('==========================')
    warning('THIS NEEDS PROPER TESTING')
    warning('==========================')
    % slice at the centroid of tibial distal
    d = CenterVolTibDist*Z0;
    [ Curves , ~, ~ ] = TriPlanIntersect(DistTib, Z0 , -d );
    quickPlotTriang(DistTib, 'g', 1); hold on
    plot3(Curves.Pts(:,1), Curves.Pts(:,2), Curves.Pts(:,3),'r-', 'LineWidth',4); hold on
    
    % throw error if more than 2 sections
    if length(Curves)>2; error('There are more than two sections in tibia triangulation. Please check.'); end
    % define the vector
    if Curves(1).Area>Curves(2).Area
        % vector from tibia section to fibular section
        U_tmp = mean(Curves(2).Pts) - mean(Curves(1).Pts);
    else
        U_tmp = -1 * (mean(Curves(2).Pts) - mean(Curves(1).Pts));
    end
end
% points medially
Y0_temp = normalizeV(U_tmp' - (U_tmp*Z0)*Z0); 

% here the assumption is that Y0 has correct m-l orientation               
YElpsMax = sign(Y0_temp'*YElpsMax)*YElpsMax;

EllipsePts = transpose(V_all*[ones(length(FittedEllipse.data),1)*PtsCurves(1) FittedEllipse.data']');

% Store body info
CS.Origin        = CenterEllipse*dim_fact;
CS.CenterVol     = CenterVol;
% CS.CenterKnee  = CenterEllipse;
CS.ElpsMaxPtVect = YElpsMax;
CS.ElpsPts       = EllipsePts;

% common axes: X is orthog to Y and Z, which are not mutually perpend
Y = normalizeV(Z0);
Z = normalizeV(YElpsMax);
X = cross(Y, Z);

% define the knee reference system
Ydp_knee  = cross(Z, X);
CS.V_knee = [X Ydp_knee Z];
CS.knee_r.child_orientation = computeZXYAngleSeq(CS.V_knee);

% the knee axis is defined by the femoral fitting
% CS.knee_r.child_location = KneeCenter*dim_fact;

% the talocrural joint is also defined by the talus fitting.
% apart from the reference system -> NB: Z axis to switch with talus Z
% CS.ankle_r.parent_orientation = computeZXYAngleSeq(CS.V_knee);

% quickPlotRefSystem(CS)

end

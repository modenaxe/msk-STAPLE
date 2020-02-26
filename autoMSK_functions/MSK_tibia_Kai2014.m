
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

% checks on vertical direction
Z0 = V_all(:,1);
Z0 = sign((mean(ProxTib.Points)-mean(DistTib.Points))*Z0)*Z0;

% need to finish
%==================================================
warning('need to compute ankle joint centre to ensure med-lat axis');
% assuming tibia is in the geometry
% Find the most distal point
[~ , I_dist_fib] = min( Tibia.Points* -Z0 );
MostDistalPoint = Tibia.Points(I_dist_fib,:);
% this will point laterally, as Z should do for right side
% med2lat = MostDistalPoint-CenterVol';
% Y0 = med2lat';
Y0 = V_all(:,2);
%==================================================

% Slices 1 mm apart as in Kai et al. 2014
slices_thick = 1;
[~, ~, ~, ~, AltAtMax] = TriSliceObjAlongAxis(Tibia, Z0, slices_thick);

% slice at max area
[ Curves , ~, ~ ] = TriPlanIntersect(Tibia, Z0 , -AltAtMax );

% keep just the largest outline (tibia section)
N_Curves = length(Curves);
max_area = 0;
if N_Curves>1
    for nc = 1:N_Curves
        cur_area = Curves(nc).Area;
        if cur_area>max_area
            slice_to_fit = Curves(nc);
        end
    end
else
    slice_to_fit = Curves;
end

% debug plots
quickPlotTriang(Tibia,'m', 1); hold on
for nn = 1:N_Curves
    plot3(slice_to_fit.Pts(:,1), slice_to_fit.Pts(:,2), slice_to_fit.Pts(:,3),'r-', 'LineWidth',4); hold on
end
    
% Move the outline curve points in the inertial ref system, so the vertical
% component (:,1) is on a plane
PtsCurves = vertcat(Curves(:).Pts)*V_all;

% Fit a planar ellipse to the outline of the tibia section
FittedEllipse = fit_ellipse(PtsCurves(:,2), PtsCurves(:,3));

% back to medical images reference system
CenterEllipse = transpose(V_all*[mean(PtsCurves(:,1)); % constant anyway
                                 FittedEllipse.X0_in;
                                 FittedEllipse.Y0_in]);

YElpsMax = V_all*[  0 ;
                   cos(FittedEllipse.phi);
                   -sin(FittedEllipse.phi)];
               
% here the assumption is that Y0 has correct m-l orientation               
YElpsMax = sign(Y0'*YElpsMax)*YElpsMax;

EllipsePts = transpose(V_all*[ones(length(FittedEllipse.data),1)*PtsCurves(1) FittedEllipse.data']');

% Store body info
CS.Origin  = CenterEllipse;
CS.CenterVol = CenterVol;
% CS.CenterKnee = CenterEllipse;
CS.ElpsMaxPtVect = YElpsMax;
CS.ElpsPts = EllipsePts;

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
CS.ankle_r.parent_orientation = computeZXYAngleSeq(CS.V_knee);

% quickPlotRefSystem(CS)

end

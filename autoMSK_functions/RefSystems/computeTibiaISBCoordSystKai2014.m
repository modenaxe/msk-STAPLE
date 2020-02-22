
function CS = computeTibiaISBCoordSystKai2014(Tibia, DistTib)

% NOTE THAT PCA AND INERTIAL AXES ARE ALMOST IDENTICAL

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

Z0 = V_all(:,1);
Z0 = sign((mean(ProxTib.Points)-mean(DistTib.Points))*Z0)*Z0;

% need to 
warning('need to compute ankle joint centre to ensure med-lat axis');
% assuming tibia is in the geometry
% Find the most distal point
[~ , I_dist_fib] = min( Tibia.Points* -Z0 );
MostDistalPoint = Tibia.Points(I_dist_fib,:);

% this will point laterally, as Z should do for right side
% med2lat = MostDistalPoint-CenterVol';
% Y0 = med2lat';
Y0 = V_all(:,2);

% Slices of 1mm as in Kai et al. 2014
slices_thick = 1;
[~, ~, ~, ~, AltAtMax] = TriSliceObjAlongAxis(Tibia, Z0, slices_thick);

% slice at max area
[ Curves , ~, ~ ] = TriPlanIntersect(Tibia, Z0 , -AltAtMax );

% keep just tibia section (largest outline)
N_Curves = length(Curves);
max_area = 0;
if N_Curves>1
    for nc = 1:N_Curves
    slice = polyshape(Curves(nc).Pts(:,1), Curves(nc).Pts(:,2));
%     plot(slice)
    area_curve = area(slice);
    if area_curve>max_area
        max_area = area_curve;
        slice_to_fit = Curves(nc);
    end
    end
else
    slice_to_fit = Curves;
end

% debug plots
quickPlotTriang(Tibia,'m', 1)
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
               
YElpsMax = sign(Y0'*YElpsMax)*YElpsMax;

EllipsePts = transpose(V_all*[ones(length(FittedEllipse.data),1)*PtsCurves(1) FittedEllipse.data']');

warning('!!!TODO PLOT THE AXES OF THE ELLIPSE!!!');

% % % create GIBOK ref system
% Zend = Z0;
% Xend = normalizeV( cross(YElpsMax,Zend) );
% Yend = cross(Zend,Xend);
% Yend = normalizeV( sign(Yend'*Y0)*Yend );
% Xend = cross(Yend,Zend);
% GIBOK.Origin = CenterEllipse;
% GIBOK.X=Xend;
% GIBOK.Y=Yend;
% GIBOK.Z=Zend;
% quickPlotRefSystem(GIBOK);

% create ISB ref system
Yend = Z0;
Xend = normalizeV( -cross(YElpsMax,Z0) );
Zend = cross(Xend, Yend);
Zend = normalizeV( sign(Zend'*Y0)*Zend );
Xend = cross(Yend,Zend);

% Store geometrical info
CS.CenterVol = CenterVol;
CS.CenterKnee = CenterEllipse;
CS.YElpsMax = YElpsMax;
CS.ElpsPts = EllipsePts;

% store axes in structure
CS.Origin  = CenterEllipse;
CS.X       = Xend;
CS.Y       = Yend;
CS.Z       = Zend;
CS.V       = [Xend Yend Zend];

quickPlotRefSystem(CS)

end

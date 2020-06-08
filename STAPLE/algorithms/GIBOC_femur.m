function [CS, JCS, FemurBL_r] = GIBOC_femur(Femur, DistFem, fit_method, result_plots, in_mm, debug_plots)

%
% depends on 
% ????
% FitCSA (?)
% PlanPolygonCentroid3D
% processFemoralEpyphysis
% LargestEdgeConvHull
% PCRegionGrowing
% getFemoralCondyleMostProxPoint
% lsplane
% PtsOnCondylesFemur
% fit_ellipse
% smoothFemoralCondyles.m
% filterFemoralCondyleSurf
% ELLIPSOIDS
% ellipsoid_fit

% check units
if nargin<5;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end
% result plots on by default, debug off
if nargin<4; result_plots = 1; end
if nargin<6; debug_plots = 0; end

% coordinate system structure to store results
CS = struct();

% if this is an entire femur then cut it in two parts
% but keep track of all geometries
if ~exist('DistFem','var') || isempty(DistFem)
    [ U_DistToProx ] = femur_guess_CS( Femur, debug_plots );
    [ProxFem, DistFem] = cutLongBoneMesh(Femur, U_DistToProx);
else
    % join two parts in one triangulation
    ProxFemur = Femur;
    Femur = TriUnite(ProxFemur, DistFem);
end

% default method is the cylinder fitting one as in Modenese et al. JBiomech
% 2018
if ~exist('fit_method', 'var') || isempty(fit_method) || strcmp(fit_method, '')
    fit_method = 'cylinder';
end

% Get the mean edge length of the triangles composing the femur
% This is necessary because the functions were originally developed for
% triangulation with constant mean edge lengths of 0.5 mm
PptiesFemur = TriMesh2DProperties( Femur );

% Assume triangles are equilaterals
meanEdgeLength = sqrt( 4/sqrt(3) * PptiesFemur.TotalArea / Femur.size(1) );

% Get the coefficient for morphology operations
CoeffMorpho = 0.5 / meanEdgeLength ;

% Initial Coordinate system (from inertial axes and femoral head)
%-------------------------------------
% Z0: points upwards (inertial axis) 
% Y0: points medio-lat (from OT and Z0 in findFemoralHead.m)
%-------------------------------------

% Get eigen vectors V_all of the Femur 3D geometry and volumetric center
[ V_all, CenterVol ] = TriInertiaPpties( Femur );

% Check that the distal femur is 'below' the proximal femur or invert Z0
Z0 = V_all(:,1);
Z0 = sign((mean(ProxFem.Points)-mean(DistFem.Points))*Z0)*Z0;

% store approximate Z direction and centre of mass of triangulation
CS.Z0 = Z0;
CS.CenterVol = CenterVol;
CS.V_all = V_all;

% Find Femoral Head Center
% NB adds a CSs.Y0, (lateral)
try
    % sometimes Renault2018 fails for sparse meshes
    [CS, FemHeadACS] = GIBOC_femur_fitSphere2FemHead(ProxFem, CS, CoeffMorpho, debug_plots);
catch
    % use Kai when Renault fails
    warndlg({'Renault2018 fitting has failed.','Using Kai femoral head fitting.'})
    [CS, ~] = Kai2014_femur_fitSpheres2Condyles(ProxFem, CS, debug_plots);
    CS.CenterFH_Renault  = CS.CenterFH_Kai;
    CS.RadiusFH_Renault  = CS.RadiusFH_Kai;
end

% X0 points backwards
CS.X0 = cross(CS.Y0, CS.Z0);

% Isolates the epiphysis
EpiFem = GIBOC_isolate_epiphysis(DistFem, Z0, 'distal');

% extract full femoral condyles
[fullCondyle_Med, fullCondyle_Lat, CS] = GIBOC_femur_ArticSurf(EpiFem, CS, CoeffMorpho, 'full_condyles');

% extract posterior part of condyles (points)
% by fitting an ellipse on long convexhull edges extremities
[postCondyle_Med, postCondyle_Lat, CS] = GIBOC_femur_ArticSurf(EpiFem, CS,  CoeffMorpho, 'post_condyles');

% extract patellar grooves
% [Groove_Med, Groove_Lat, CS] = GIBOC_femur_ArticSurf(EpiFem, CS, CoeffMorpho, 'pat_groove');

% Fit two spheres to patellar groove
% CS = CS_femur_SpheresOnPatellarGroove(Groove_Lat, Groove_Med, CS);

% how to compute the joint axes
switch fit_method
    case 'spheres'
        % Fit two spheres on articular surfaces of posterior condyles
        [CS, JCS] = CS_femur_SpheresOnCondyles(postCondyle_Lat, postCondyle_Med, CS);
    case 'cylinder'
        % Fit the posterior condyles with a cylinder
        [CS, JCS] = CS_femur_CylinderOnCondyles(postCondyle_Lat, postCondyle_Med, CS);
    case 'ellipsoids'
        % Fit the entire condyles with an ellipsoid
        [CS, JCS] = CS_femur_EllipsoidsOnCondyles(fullCondyle_Lat, fullCondyle_Med, CS);
    otherwise
        error('GIBOC_femur.m ''method'' input has value: ''spheres'', ''cylinder'' or ''ellipsoids''.')
end

% define segment ref system
CS.Origin = CenterVol;
CS.V = JCS.hip_r.V;

% landmark bone according to CS (only Origin and CS.V are used)
FemurBL_r   = landmarkTriGeomBone(Femur  , CS,     'femur_r');

% check if right or left and correct CS
% correctCSforLegSide(FemurBL_r)

% result plot
label_switch=1;
if result_plots == 1
    figure('Name','femur_r');
    alpha = 0.5;
    subplot(2,2,[1,3]);
    plotTriangLight(Femur, CS, 0)
%     quickPlotRefSystem(CS);
    quickPlotRefSystem(JCS.hip_r);
    quickPlotRefSystem(JCS.knee_r);
    % add articular surfaces
    if strcmp(fit_method,'ellipsoids')
        quickPlotTriang(fullCondyle_Lat, 'b')
        quickPlotTriang(fullCondyle_Med, 'r')
    else
        quickPlotTriang(postCondyle_Lat, 'b')
        quickPlotTriang(postCondyle_Med, 'r')
    end
    plotSphere(CS.CenterFH_Renault, CS.RadiusFH_Renault, 'g' , alpha)
%     quickPlotTriang(FemHead, 'g')
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
    plotSphere(CS.CenterFH_Renault, CS.RadiusFH_Renault, 'g', alpha);
    
    subplot(2,2,4);
    plotTriangLight(DistFem, CS, 0); hold on
    quickPlotRefSystem(JCS.knee_r);
    
    switch fit_method
        case 'spheres'
            plotSphere(CS.sphere_center_lat, CS.sphere_radius_lat, 'b', alpha);
            plotSphere(CS.sphere_center_med, CS.sphere_radius_med, 'r', alpha);
        case 'cylinder'
            plotCylinder( CS.Cyl_Y, CS.Cyl_Radius, CS.Cyl_Pt, CS.Cyl_Range*1.1, alpha, 'g')
        case 'ellipsoids'
            plotEllipsoid(CS.ellips_centre_med, CS.ellips_radii_med, CS.ellips_evec_med, 'r', alpha)
            plotEllipsoid(CS.ellips_centre_lat, CS.ellips_radii_lat, CS.ellips_evec_lat, 'b', alpha)
        otherwise
            error('GIBOC_femur.m ''method'' input has value: ''spheres'', ''cylinder'' or ''ellipsoids''.')
    end
grid off
end

% % plot patellar fitting as well
% PlotTriangLight(DistFem, CS, 1); hold on
% quickPlotTriang(Groove_Lat, 'b')
% quickPlotTriang(Groove_Med, 'r')
% plotSphere(CS.patgroove_center_med,CS.patgroove_radius_med, 'r', alpha);
% plotSphere(CS.patgroove_center_lat,CS.patgroove_radius_lat, 'b', alpha);

end


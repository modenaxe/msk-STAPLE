function [CS, JCS, TibiaBL_r] = GIBOK_tibia(Tibia, DistTib, fit_method, result_plots, in_mm, debug_plots)

% check units
if nargin<5;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end
% result plots on by default, debug off
if nargin<4; result_plots = 1; end
if nargin<6; debug_plots = 0; end

% coordinate system structure to store results
CS = struct();

% if this is an entire tibia then cut it in two parts
% but keep track of all geometries
if ~exist('DistTib','var') || isempty(DistTib)
    % Only one mesh, this is a long bone that should be cutted in two
    % parts
    [ U_DistToProx ] = tibia_get_correct_first_CS(Tibia, debug_plots);
    [ProxTib, DistTib] = cutLongBoneMesh(Tibia, U_DistToProx);

else
    ProxTib = Tibia;
    % join two parts in one triangulation
    Tibia = TriUnite(DistTib, ProxTib);
end

% Compute the coefficient for morphology operations
CoeffMorpho = computeTriCoeffMorpho(Tibia);

% Get eigen vectors V_all of the Tibia 3D geometry and volumetric center
[ V_all, CenterVol, InertiaMatrix ] = TriInertiaPpties( Tibia );

% Initial estimate of the Inf-Sup axis Z0 - Check that the distal tibia
% is 'below': the proximal tibia, invert Z0 direction otherwise;
Z0 = V_all(:,1);
Z0 = sign((mean(ProxTib.Points)-mean(DistTib.Points))*Z0)*Z0;

% store approximate Z direction and centre of mass of triangulation
CS.Z0 = Z0;
CS.CenterVol = CenterVol;
CS.InertiaMatrix = InertiaMatrix;
CS.V_all = V_all;

% extract the tibia (used to compute the mechanical Z axis)
CS.CenterAnkleInside = GIBOK_tibia_DistMaxSectCentre(DistTib, CS);

% extract the distal tibia articular surface
AnkleArtSurf = GIBOK_tibia_DistArtSurf(DistTib, CS, CoeffMorpho);

% Method to get ankle center : 
%  1) Fit a LS plan to the distal tibia art surface, 
%  2) Inset the plan 5mm
%  3) Get the center of section at the intersection with the plan 
%  4) Project this center Bback to original plan
%-----------
% parameters
%-----------
plane_thick = 0.005 / dim_fact; 
%-----------
[oLSP_AAS, nAAS] = lsplane(AnkleArtSurf.Points, Z0);
Curves = TriPlanIntersect( DistTib, nAAS , (oLSP_AAS + plane_thick*nAAS') );

% this gets the larger area (allows fibula to be in the geometry)
[TibiaDistSection, N_curves, ~] = GIBOK_getLargerPlanarSect(Curves);

if debug_plots == 1
    quickPlotTriang(DistTib,[],1)
    for nnn = 1:N_curves
        plot3(Curves(nnn).Pts(:,1), Curves(nnn).Pts(:,2), Curves(nnn).Pts(:,3)); hold on; axis equal
    end
    axis equal
end

% ankle centre (considers only tibia)
Centre = PlanPolygonCentroid3D( TibiaDistSection.Pts );
CS.AnkleCenter = Centre - plane_thick * nAAS';
% check ankle centre section
if debug_plots == 1
    plot3(TibiaDistSection.Pts(:,1), TibiaDistSection.Pts(:,2), TibiaDistSection.Pts(:,3)); hold on; axis equal
    plot3(CS.AnkleCenter(1),CS.AnkleCenter(2),CS.AnkleCenter(3),'o')
end

%% Find a pseudo medioLateral Axis
% DIFFERENT FROM ORIGINAL TOOLBOX
% NB: in GIBOK AnkleArtSurfProperties is calculated from the AnkleArtSurf
% BEFORE the last iteration and filters

% identify lateral direction
[U_tmp, MostDistalMedialPt, just_tibia] = tibia_identify_lateral_direction(DistTib, Z0);
if just_tibia; plot_col = 'r'; else; plot_col = 'b';  end

% debug plot for most distal point
if debug_plots == 1;   plotDot(MostDistalMedialPt,'k',3) ; end

% Make the vector U_tmp orthogonal to Z0 and normalize it
CS.Y0 = normalizeV(  U_tmp' - (U_tmp*Z0)*Z0  ); 

%% Proximal Tibia
% remove fibula from prox tibia
ProxTib = removeFibulaFromProxTibia(ProxTib, 'GIBOK_tibia.m');

% isolate tibia proximal epiphysis 
EpiTib = GIBOK_isolate_epiphysis(ProxTib, Z0, 'proximal');

%============
% ITERATION 1 
%============
%Identify raw Articular Surfaces (AS) based on curvature
%--------------
% parameters
%--------------
angle_thresh = 35;% deg
curv_quartile = 0.25;
%--------------
[EpiTibAS, oLSP, Ztp] = GIBOK_tibia_FullProxArtSurf(EpiTib, CS, CoeffMorpho, angle_thresh, curv_quartile);

% debug plots
if debug_plots == 1
    quickPlotTriang(EpiTibAS, [], 1);hold on
    title('STEP1: Full proximal Articular Surface')
end

% remove the ridge and the central part of the surface
EpiTibAS = GIBOK_tibia_ProxArtSurf_it1(ProxTib, EpiTib, EpiTibAS, CS, Ztp , oLSP, CoeffMorpho);

% debug plots
if debug_plots == 1
    quickPlotTriang(EpiTibAS, [], 1);hold on
    title('STEP2: Full proximal Articular Surface (central ridge removed)')
end

% Smooth found ArtSurf
EpiTibAS = TriOpenMesh(EpiTib,EpiTibAS, 15*CoeffMorpho);
EpiTibAS = TriCloseMesh(EpiTib,EpiTibAS, 30*CoeffMorpho);

%==================
% ITERATION 2 ( & 3 )
%==================
CS.Y0_GIBOK  = CS.Y0*-1;
[EpiTibASMed, EpiTibASLat, ~] = GIBOK_tibia_ProxArtSurf_it2(EpiTib, EpiTibAS, CS, CoeffMorpho);

% builld the triangulation
% EpiTibAS3 is the final triang of the articular surfaces
EpiTibAS3 = TriUnite(EpiTibASMed, EpiTibASLat);

% debug plots
if debug_plots == 1
    quickPlotTriang(EpiTibAS3, [], 1);hold on
    title('STEP3: Final Articular Surface (refined)')
end

% compute joint coord system
switch fit_method
    case 'ellipse'
        % fit an ellipse to the articular surface
        [CS, JCS] = CS_tibia_Ellipse(EpiTibAS3, CS);
    case 'centroids'
        % uses the centroid of the articular surfaces to define the Z axis
        [CS, JCS] = CS_tibia_ArtSurfCentroids(EpiTibASMed, EpiTibASLat, CS);
    case 'plateau'
        [CS, JCS] = CS_tibia_PlateauLayer(EpiTib, EpiTibAS3, CS);
    otherwise
        error('GIBOK_tibia.m ''method'' input has value: ''ellipse'', ''centroids'' or ''plateau''.')
end

% define segment ref system
CS.V = JCS.knee_r.V;
CS.Origin = CenterVol;

% CS.Y = mech axis
% CS.X = perp to plane YZ
% CS.Z = XY

% landmark bone according to CS (only Origin and CS.V are used)
TibiaBL_r   = LandmarkGeom(Tibia, CS, 'tibia_r');
if just_tibia == 0
    TibiaBL_r.RLM = MostDistalMedialPt;
end
label_switch = 1;

if result_plots == 1
    
    figure('Name', 'tibia_r');
    % plot entire tibia 
    subplot(2,2,[1,3])
    PlotTriangLight(Tibia, CS, 0);
    quickPlotRefSystem(JCS.knee_r)
    quickPlotTriang(EpiTibASMed,'r');
    quickPlotTriang(EpiTibASLat,'b');
    quickPlotTriang(AnkleArtSurf, 'g');
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

    % plot proximal tibia
    subplot(2,2,2)
    alpha_AS = 1;
    PlotTriangLight(ProxTib, CS, 0);
    switch fit_method
        case 'ellipse'
            quickPlotTriang(EpiTibAS3,'g', 0, alpha_AS );
            quickPlotRefSystem(JCS.knee_r)
            title('GIBOK Tibia - Ellipse fitting')
        case 'centroids'
            quickPlotTriang(EpiTibASMed,'r', 0, alpha_AS );
            quickPlotTriang(EpiTibASLat,'b',0, alpha_AS);
            plotDot(CS.Centroid_AS_lat, 'b', 4);
            plotDot(CS.Centroid_AS_med, 'r', 4);
            plotCylinder((CS.Centroid_AS_lat-CS.Centroid_AS_med)', 3, (CS.Centroid_AS_lat+CS.Centroid_AS_med)/2,...
                1.7*norm(CS.Centroid_AS_lat-CS.Centroid_AS_med), 1, 'k');
            title('GIBOK Tibia - Centroids')
        case 'plateau'
            quickPlotTriang(EpiTibAS3,'g', 0, alpha_AS );
            quickPlotRefSystem(JCS.knee_r)
            title('GIBOK Tibia - Plateau')
    end

    % plot distal tibia
    subplot(2,2,4)
    PlotTriangLight(DistTib, CS, 0);
    quickPlotTriang(AnkleArtSurf, 'g');
    plotDot(CS.AnkleCenter, 'g', 4);
%     plotDot(CS.CenterAnkleInside, 'y', 4);
    plotDot(MostDistalMedialPt,plot_col,3); % should be always medial

end


%% Inertia Results
% Yi = V_all(:,2); Yi = sign(Yi'*Y0)*Yi;
% Xi = cross(Yi,Z0);
% 
% CSs.CenterAnkle2 = CenterAnkleInside;
% CSs.CenterAnkle = ankleCenter;
% CSs.Zinertia = Z0;
% CSs.Yinertia = Yi;
% CSs.Xinertia = Xi;
% CSs.Minertia = [Xi Yi Z0];

end


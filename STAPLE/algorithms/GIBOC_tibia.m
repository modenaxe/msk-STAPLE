% depends on
% AnkleSurfFit
% fitEllipseOnTibialCondylesEdge (PLATEAU)
% ProjectOnPlan

function [CS, JCS, TibiaBL, ArtSurf] = GIBOC_tibia(tibiaTri, side_raw, fit_method, result_plots,  debug_plots, in_mm)

% result plots on by default, debug off
if nargin<2;    side_raw = 'r';          end
if nargin<3;    fit_method = 'ellipse';  end
if nargin<4;    result_plots = 1;        end
if nargin<5;    debug_plots = 0;         end
if nargin<6;    in_mm = 1;               end
if in_mm == 1;  dim_fact = 0.001;        else;  dim_fact = 1; end

% default algorithm: cylinder fitting (Modenese et al. JBiomech 2018)
if ~exist('fit_method', 'var') || isempty(fit_method) || strcmp(fit_method, '')
    fit_method = 'ellipse';
end

% get sign correspondent to body side
[~, side_low] = bodySide2Sign(side_raw);

% inform user about settings
disp('---------------------')
disp('   GIBOC - TIBIA     '); 
disp('---------------------')
disp(['* Body Side   : ', upper(side_low)]);
disp(['* Fit Method  : ', fit_method]);
disp(['* Result Plots: ', convertBoolean2OnOff(result_plots)]);
disp(['* Debug  Plots: ', convertBoolean2OnOff(debug_plots)]);
disp(['* Triang Units: ', 'mm']);
disp('---------------------')
disp('Initializing method...')

% it is assumed that, even for partial geometries, the femoral bone is
% always provided as unique file. Previous versions of this function did
% use separated proximal and distal triangulations. Check Git history if
% you are interested in that.
[ U_DistToProx ]   = tibia_guess_CS(tibiaTri, debug_plots);
[ProxTibTri, DistTibTri] = cutLongBoneMesh(tibiaTri, U_DistToProx);

% Compute the coefficient for morphology operations
CoeffMorpho = computeTriCoeffMorpho(tibiaTri);

% Get inertial principal vectors V_all of the tibia geometry & volum center
[ V_all, CenterVol, InertiaMatrix ] = TriInertiaPpties( tibiaTri );

% Initial estimate of the Inf-Sup axis Z0 - Check that the distal tibia
% is 'below': the proximal tibia, invert Z0 direction otherwise;
Z0 = V_all(:,1);
Z0 = sign((mean(ProxTibTri.Points)-mean(DistTibTri.Points))*Z0)*Z0;

%-------------------------------------
% Initial Coordinate system (from inertial axes and femoral head):
% Z0: points upwards (inertial axis) 
%-------------------------------------
% store available geom info on CS
CS = struct();
CS.Z0 = Z0;
CS.CenterVol = CenterVol;
CS.V_all = V_all;
% CS.InertiaMatrix = InertiaMatrix;

% printout
disp('Computing centre of ankle joint...')

%--------- COMPUTE ANKLE CENTRE (USED BY SURF CENTROIDS) -----------
% compute centre of distal larger section to compute the mechanical Z axis
% within CS_tibia_ArtSurfCentroids.m
CS.CenterAnkleInside = GIBOC_tibia_DistMaxSectCentre(DistTibTri, Z0);

%--------- COMPUTE ANKLE CENTRE (USED BY OTHER ALGORITHMS) ---------
% Method to get ankle center : 
%  1) Fit a LS plan to the distal tibia art surface, 
%  2) Inset the plan 5mm
%  3) Get the center of section at the intersection with the plan 
%  4) Project this center back to original plan
%-------------------------------------
% extract the distal tibia articular surface
AnkleArtSurfTri = GIBOC_tibia_DistArtSurf(DistTibTri, Z0, V_all, CoeffMorpho);

% fit plane to points
plane_thick = 0.005 / dim_fact; % parameter
[oLSP_AAS, nAAS] = lsplane(AnkleArtSurfTri.Points, Z0);
Curves = TriPlanIntersect( DistTibTri, nAAS , (oLSP_AAS + plane_thick*nAAS') );

% this gets the larger area (allows fibula to be in the geometry)
[TibiaDistSection, N_curves, ~] = getLargerPlanarSect(Curves);

% ankle centre (considers only tibia)
Centre = PlanPolygonCentroid3D( TibiaDistSection.Pts );
CS.AnkleCenter = Centre - plane_thick * nAAS';

disp('Done.')

% check ankle centre section
if debug_plots == 1
    quickPlotTriang(DistTibTri,[],[],0.4); 
    quickPlotTriang(AnkleArtSurfTri, 'g');
    % check for tibia and fibula sections
    for nnn = 1:N_curves
        plot3(Curves(nnn).Pts(:,1),Curves(nnn).Pts(:,2),Curves(nnn).Pts(:,3));
    end
    title('Check Ankle ArtSurf (green) and joint centres');
    plotDot(CS.CenterAnkleInside, 'r', 2); text(CS.CenterAnkleInside(1),CS.CenterAnkleInside(2),CS.CenterAnkleInside(3),'    AnkleCenterInside','FontSize',8);
    plotDot(CS.AnkleCenter, 'k', 2); text(CS.AnkleCenter(1),CS.AnkleCenter(2),CS.AnkleCenter(3),'    AnkleCenter','FontSize',8);
    plot3(TibiaDistSection.Pts(:,1), TibiaDistSection.Pts(:,2), TibiaDistSection.Pts(:,3),'b','LineWidth',2); 
    hold on; axis equal
end

%% Find a pseudo medioLateral Axis
% DIFFERENT FROM ORIGINAL TOOLBOX
% NB: in GIBOC AnkleArtSurfProperties is calculated from the AnkleArtSurf
% BEFORE the last iteration and filters

% identify lateral direction
[U_tmp, MostDistalPt, just_tibia] = tibia_identify_lateral_direction(DistTibTri, Z0);
if just_tibia; plot_col = 'r'; else; plot_col = 'b';  end

% debug plot for the most distal point
if debug_plots == 1 
    plotDot(MostDistalPt,'k',3); 
    text(MostDistalPt(1),MostDistalPt(2),MostDistalPt(3),'    MostDistalMedialPoint', 'FontSize',8); 
end

% Make the vector U_tmp orthogonal to Z0 and normalize it
CS.Y0 = normalizeV(  U_tmp' - (U_tmp*Z0)*Z0  ); 

%% Proximal Tibia

% remove fibula from prox tibia
ProxTibTri = removeFibulaFromProxTibia(ProxTibTri, 'GIBOC_tibia.m');

% isolate tibia proximal epiphysis 
EpiTibTri = GIBOC_isolate_epiphysis(ProxTibTri, Z0, 'proximal');

% STEP1: Identify raw Articular Surfaces (AS) based on curvature
% parameters
angle_thresh = 35;% [deg]
curv_quartile = 0.25;

% printout
disp('Processing proximal tibia:')

% first approximation of tibial surface
disp('  Step #1: identify tibiofem artic surfaces')
[EpiTibASTri, oLSP, Ztp] = GIBOC_tibia_FullProxArtSurf(EpiTibTri, CS, CoeffMorpho, angle_thresh, curv_quartile);

% debug plots
if debug_plots == 1
    quickPlotTriang(EpiTibASTri, [], 1);hold on
    title('STEP1: Full proximal Articular Surface')
end

% STEP2: remove the ridge and the central part of the surface
disp('  Step #2: remove intercondilar ridge')
EpiTibASTri = GIBOC_tibia_ProxArtSurf_it1(ProxTibTri, EpiTibTri, EpiTibASTri, CS, Ztp , oLSP, CoeffMorpho);

% debug plots
if debug_plots == 1
    quickPlotTriang(EpiTibASTri, [], 1);hold on
    title('STEP2: Full proximal Articular Surface (central ridge removed)')
end

% Smooth current articular surface
EpiTibASTri = TriOpenMesh(EpiTibTri,EpiTibASTri, 15*CoeffMorpho);
EpiTibASTri = TriCloseMesh(EpiTibTri,EpiTibASTri, 30*CoeffMorpho);

% STEP3: identify medial and lateral articular surfaces
disp('  Step #3: split medial and lateral surfaces')
CS.Y0_GIBOC  = CS.Y0*-1;
[EpiTibASMedTri, EpiTibASLatTri, ~] = GIBOC_tibia_ProxArtSurf_it2(EpiTibTri, EpiTibASTri, CS, CoeffMorpho);

% build the final triangulation of the articular surfaces of the prox tibia
EpiTibArtSurfTri = TriUnite(EpiTibASMedTri, EpiTibASLatTri);

% exporting articular surfaces (more triangulations can be easily added
% commenting out the parts of interest
if nargout>3
    disp('Storing articular surfaces for export...')
    ArtSurf.(['prox_tibia_', side_raw])    = ProxTibTri;
    ArtSurf.(['dist_tibia_', side_raw])    = DistTibTri;
    ArtSurf.(['plateau_', side_raw])       = EpiTibArtSurfTri;
    ArtSurf.(['plateau_med_', side_raw])   = EpiTibASMedTri;
    ArtSurf.(['plateau_lat_', side_raw])   = EpiTibASLatTri;
    ArtSurf.(['tibiotalar_', side_raw])    = AnkleArtSurfTri;
end

% debug plots
if debug_plots == 1
    quickPlotTriang(EpiTibArtSurfTri, [], 1);hold on
    title('STEP3: Final Articular Surface (refined)')
end

% compute joint coord system
disp(['Fitting tibial proximal articular surfaces using ', fit_method, ' method.'])
switch fit_method
    case 'ellipse'
        % fit an ellipse to the articular surface
        [CS, JCS] = CS_tibia_Ellipse(EpiTibArtSurfTri, CS, side_raw);
    case 'centroids'
        % uses the centroid of the articular surfaces to define the Z axis
        [CS, JCS] = CS_tibia_ArtSurfCentroids(EpiTibASMedTri, EpiTibASLatTri, CS, side_raw);
    case 'plateau'
        [CS, JCS] = CS_tibia_PlateauLayer(EpiTibTri, EpiTibArtSurfTri, CS, side_raw);
    otherwise
        error('GIBOC_tibia.m ''method'' input has value: ''ellipse'', ''centroids'' or ''plateau''.')
end

% joint names (extracted from JCS defined in the fit_methods)
joint_name_list = fields(JCS);
knee_name  = joint_name_list{strncmp(joint_name_list, 'knee', 3)};
side_low = knee_name(end);

% define segment ref system
CS.V = JCS.(knee_name).V;
CS.Origin = CenterVol;

% landmark bone according to CS (only Origin and CS.V are used)
TibiaBL   = landmarkBoneGeom(tibiaTri, CS, ['tibia_', side_low]);
if just_tibia == 0
    TibiaBL.([upper(side_low), 'LM']) = MostDistalPt;
end

label_switch = 1;
if result_plots == 1
    figure('Name', ['GIBOC | bone: tibia | fit: ', fit_method,' | side: ', side_low])
    
    % plot entire tibia 
    subplot(2,2,[1,3])
    plotTriangLight(tibiaTri, CS, 0);
    quickPlotRefSystem(JCS.(knee_name))
    quickPlotTriang(EpiTibASMedTri,'r');
    quickPlotTriang(EpiTibASLatTri,'b');
    quickPlotTriang(AnkleArtSurfTri, 'g');
    % plot markers and labels
    plotBoneLandmarks(TibiaBL, label_switch);

    % plot proximal tibia
    subplot(2,2,2)
    alpha_ArtSurf = 1;
    plotTriangLight(ProxTibTri, CS, 0);
    switch fit_method
        case 'ellipse'
            quickPlotTriang(EpiTibArtSurfTri,'g', 0, alpha_ArtSurf );
            quickPlotRefSystem(JCS.(knee_name))
%             title('GIBOC Tibia - Ellipse fitting')
        case 'centroids'
            quickPlotTriang(EpiTibASMedTri,'r', 0, alpha_ArtSurf );
            quickPlotTriang(EpiTibASLatTri,'b',0, alpha_ArtSurf);
            plotDot(CS.Centroid_AS_lat, 'b', 4);
            plotDot(CS.Centroid_AS_med, 'r', 4);
            plotCylinder((CS.Centroid_AS_lat-CS.Centroid_AS_med)', 3, (CS.Centroid_AS_lat+CS.Centroid_AS_med)/2,...
                1.7*norm(CS.Centroid_AS_lat-CS.Centroid_AS_med), 1, 'k');
%             title('GIBOC Tibia - Centroids')
        case 'plateau'
            quickPlotTriang(EpiTibArtSurfTri,'g', 0, alpha_ArtSurf );
            quickPlotRefSystem(JCS.(knee_name))
%             title('GIBOC Tibia - Plateau')
    end

    % plot distal tibia
    subplot(2,2,4)
    plotTriangLight(DistTibTri, CS, 0);
    quickPlotTriang(AnkleArtSurfTri, 'g');
    switch fit_method
        case 'plateau'
            plotDot(CS.CenterAnkleInside, 'g', 4);
        otherwise
            plotDot(CS.AnkleCenter, 'g', 4);
    end
    plotDot(MostDistalPt,plot_col,3);
    text(MostDistalPt(1),MostDistalPt(2),MostDistalPt(3),'    MostDistPoint','FontSize',8);
end

% final printout
disp('Done.');

end


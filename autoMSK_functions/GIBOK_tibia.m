function [CSs, TrObjects] = GIBOK_tibia(Tibia, DistTib, in_mm)

% check units
if nargin<3;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% coordinate system structure to store results
CSs = struct();

% if this is an entire tibia then cut it in two parts
% but keep track of all geometries
if ~exist('DistTib','var')
     % Only one mesh, this is a long bone that should be cutted in two
     % parts
      [ProxTib, DistTib] = cutLongBoneMesh(Tibia);
else
    ProxTib = Tibia;
    % join two parts in one triangulation
    Tibia = TriUnite(DistTib, ProxTib);
end

% Get the mean edge length of the triangles composing the tibia
% This is necessary because the functions were originally developed for
% triangulation with constant mean edge lengths of 0.5 mm
PptiesTibia = TriMesh2DProperties( Tibia );

% Assume triangles are equilaterals
meanEdgeLength = sqrt( 4/sqrt(3) * PptiesTibia.TotalArea / Tibia.size(1) );

% Get the coefficient for morphology operations
CoeffMorpho = 0.5 / meanEdgeLength ;

% Get eigen vectors V_all of the Tibia 3D geometry and volumetric center
[ V_all, CenterVol, InertiaMatrix ] = TriInertiaPpties( Tibia );

% Initial estimate of the Inf-Sup axis Z0 - Check that the distal tibia
% is 'below': the proximal tibia, invert Z0 direction otherwise;
Z0 = V_all(:,1);
Z0 = sign((mean(ProxTib.Points)-mean(DistTib.Points))*Z0)*Z0;

% store approximate Z direction and centre of mass of triangulation
CSs.Z0 = Z0;
CSs.CenterVol = CenterVol;
CSs.InertiaMatrix = InertiaMatrix;
CSs.V_all = V_all;

% extract the tibia (used to compute the mechanical Z axis)
CSs.CenterAnkleInside = GIBOK_tibia_DistMaxSectCentre(DistTib, CSs);

% extract the distal tibia articular surface
AnkleArtSurf = GIBOK_tibia_DistArtSurf(DistTib, CSs, CoeffMorpho);

% Method to get ankle center : 
%  1) Fit a LS plan to the distal tibia art surface, 
%  2) Inset the plan 5mm
%  3) Get the center of section at the intersection with the plan 
%  4) Project this center Bback to original plan
%-----------
% parameters
%-----------
plane_thick = 5 * dim_fact; 
%-----------
[oLSP_AAS, nAAS] = lsplane(AnkleArtSurf.Points, Z0);
Curves           = TriPlanIntersect( DistTib, nAAS , (oLSP_AAS + plane_thick*nAAS') );

% this gets the larger area (allows tibia to be in the geometry)
[Curve, N_curves, ~] = GIBOK_getLargerPlanarSect(Curves);

% checks how many objects have been sliced
tibia_and_fibula=0;
if N_curves==2
    tibia_and_fibula=1;
    disp('Tibia and Fibula are detected in the triangulation.')
elseif N_curves>2
    warning(['There are ', num2str(N_curves), ' section areas.']);
    error('This should not be the case (only tibia and fibula should be there.')
end

% ankle centre
Centre = PlanPolygonCentroid3D( Curve.Pts );
CSs.AnkleCenter = Centre - plane_thick * nAAS';

%% Find a pseudo medioLateral Axis
% DIFFERENCE FROM ORIGINAL TOOLBOX
% NB: in GIBOK AnkleArtSurfProperties is calculated from the AnkleArtSurf
% BEFORE the last iteration and filters
AnkleArtSurfProperties = TriMesh2DProperties(AnkleArtSurf);

% Most Distal point of the medial malleolus (MDMMPt)
ZAnkleSurf = AnkleArtSurfProperties.meanNormal;
[~,I] = max(DistTib.Points*ZAnkleSurf);

% define a pseudo-medial axis
warning('==========================')
warning('THIS NEEDS PROPER TESTING')
warning('==========================')
quickPlotTriang(DistTib,'m',1); hold on
if tibia_and_fibula == 1
    % Vector between ankle center and the most Distal point (MDMMPt)
    MDMM_Pt = DistTib.Points(I,:);
    U_tmp = MDMM_Pt - CSs.AnkleCenter;
    % debug
    plotDot(MDMM_Pt,'k',3)
else
    % if fibula is there, the most distal point will be fibula tip. 
    % Adjusting for that case.
    MDLM_Pt = DistTib.Points(I,:);
    U_tmp = CSs.AnkleCenter - MDLM_Pt;
    % debug
    plotDot(MDLM_Pt,'k',3)
end

% Make the vector U_tmp orthogonal to Z0 and normalize it
Y0 = normalizeV(  U_tmp' - (U_tmp*Z0)*Z0  ); 
CSs.Y0 = Y0;

%% Proximal Tibia

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
[EpiTibAS, oLSP, Ztp] = GIBOK_tibia_FullProxArtSurf(EpiTib, CSs, CoeffMorpho, angle_thresh, curv_quartile);

% remove the ridge and the central part of the surface
EpiTibAS = GIBOK_tibia_ProxArtSurf_it1(ProxTib, EpiTibAS, CSs, Ztp , oLSP, CoeffMorpho);

% Smooth found ArtSurf
EpiTibAS = TriOpenMesh(EpiTib,EpiTibAS, 15*CoeffMorpho);
EpiTibAS = TriCloseMesh(EpiTib,EpiTibAS, 30*CoeffMorpho);

%==================
% ITERATION 2 & 3 
%==================
[EpiTibASMed, EpiTibASLat, ~] = GIBOK_tibia_ProxArtSurf_it2(EpiTib, EpiTibAS, CSs, CoeffMorpho);

% builld the triangulation
EpiTibAS3 = TriUnite(EpiTibASMed, EpiTibASLat);

% NOTE: EpiTibAS3 is the final mesh from the functions
EpiTibAS = EpiTibAS3;

% quick final check
quickPlotTriang(EpiTib,'y',1);hold on
quickPlotTriang(EpiTibASMed,'r')
quickPlotTriang(EpiTibASLat,'b')

% fit an ellipse to the articular surface
% CSs = MSK_tibia_ACS_Ellipse(EpiTibAS, CSs);

% uses the centroid of the articular surfaces to define the Z axis
% CSs = MSK_tibia_ACS_ArtSurfCentroids(EpiTibASMed, EpiTibASLat, CSs);

CSs = MSK_tibia_ACS_PlateauLayer(EpiTib, EpiTibAS, CSs);

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

if nargout>1
    TrObjects = struct();
    TrObjects.Tibia = Tibia;
    TrObjects.ProxTib = ProxTib;
    TrObjects.DistTib = DistTib;
    TrObjects.AnkleArtSurf = AnkleArtSurf;
    TrObjects.EpiTib = EpiTib;
    TrObjects.EpiTibASMed = EpiTibASMed;
    TrObjects.EpiTibASLat = EpiTibASLat;
end


end


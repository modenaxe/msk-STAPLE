function [CSs, TrObjects] = GIBOK_tibia(Tibia, DistTib, in_mm)

if nargin<3
    in_mm=1;
end

if in_mm == 0
    dim_fact = 0.001;
else
    dim_fact = 1;
end

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

% Get eigen vectors V_all of the Tibia 3D geometry and volumetric center
[ V_all, CenterVol, InertiaMatrix ] = TriInertiaPpties( Tibia );

% Initial estimate of the Inf-Sup axis Z0 - Check that the distal tibia
% is 'below': the proximal tibia, invert Z0 direction otherwise;
Z0 = V_all(:,1);
Z0 = sign((mean(ProxTib.Points)-mean(DistTib.Points))*Z0)*Z0;

CSs.Z0 = Z0;
CSs.CenterVol = CenterVol;
CSs.InertiaMatrix = InertiaMatrix;
CSs.V_all = V_all;

% extract the tibia (used to compute the mechanical Z axis)
CenterAnkleInside = GIBOK_tibia_DistMaxSectCentre(DistTib, CSs);

% extract the distal tibia articular surface
AnkleArtSurf = GIBOK_tibia_DistArtSurf(DistTib, CSs);

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
[oLSP_AAS,nAAS] = lsplane(AnkleArtSurf.Points, Z0);
Curves          = TriPlanIntersect( DistTib, nAAS , (oLSP_AAS + plane_thick*nAAS') );
% this gets the larger area (allows tibia to be in the geometry)
[Curve, N_curves] = GIBOK_getLargerPlanarSect(Curves);

% check on the objects that have been sliced
only_tibia=1;
if N_curves==2
    only_tibia=0;
elseif N_curves>2
    warning(['There are ', num2str(length(Curves)), ' section areas.']);
    error('This should not be the case (only tibia and fibular should be there.')
end
Centr           = PlanPolygonCentroid3D( Curve.Pts );

% ankle centre (stored later)
ankleCenter = Centr - plane_thick * nAAS';


BoneLandmarks.AJC = ankleCenter;

%% Find a pseudo medioLateral Axis
% DIFFERENCE FROM ORIGINAL TOOLBOX
% NB: in GIBOK AnkleArtSurfProperties is calculated from the AnkleArtSurf
% BEFORE the last iteration and filters
AnkleArtSurfProperties = TriMesh2DProperties(AnkleArtSurf);

% Most Distal point of the medial malleolus (MDMMPt)
ZAnkleSurf = AnkleArtSurfProperties.meanNormal;
[~,I] = max(DistTib.Points*ZAnkleSurf);

% define a pseudo-medial axis
if only_tibia == 1
    % Vector between ankle center and the most Distal point (MDMMPt)
    MDMM_Pt = DistTib.Points(I,:);
    U_tmp = MDMM_Pt - ankleCenter;
else
    % if fibular is there, the most distal will be fibula tip. Adjusting
    % for that case
    MDLM_Pt = DistTib.Points(I,:);
    U_tmp = ankleCenter - MDLM_Pt;
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
[EpiTibAS, oLSP, Ztp] = GIBOK_tibia_FullProxArtSurf_it1(EpiTib, CSs, angle_thresh, curv_quartile);

% remove the ridge and the central part of the surface
EpiTibAS = GIBOK_tibia_ProxArtSurf_it1(ProxTib, EpiTibAS, CSs, Ztp , oLSP);

warning('Needs a check on the filter')
% % Smooth found ArtSurf
% % makes the algorithm fail
try
    EpiTibAS = TriOpenMesh(EpiTib,EpiTibAS, 15);
    EpiTibAS = TriCloseMesh(EpiTib,EpiTibAS, 30);
catch
    warning('original GIBOK filters not working...relaxing them')
    EpiTibAS = TriOpenMesh(EpiTib,EpiTibAS, 7);
    EpiTibAS = TriCloseMesh(EpiTib,EpiTibAS, 15);
end
%==================
% ITERATION 2 & 3 
%==================
[EpiTibASMed, EpiTibASLat, ~] = GIBOK_tibia_ProxArtSurf_it2(EpiTib, EpiTibAS, CSs);
% builld the triangulation
EpiTibAS3 = TriUnite(EpiTibASMed, EpiTibASLat);

% NOTE: EpiTibAS3 is the final mesh from the functions
EpiTibAS = EpiTibAS3;

% quick final check
quickPlotTriang(EpiTib,'y',1);hold on
quickPlotTriang(EpiTibASMed,'r')
quickPlotTriang(EpiTibASLat,'b')

CSs = GIBOK_tibia_EllipseACS(EpiTibAS, CSs);

CSs = GIBOK_tibia_DoubleEllipseACS(EpiTibASMed, EpiTibASLat);

CSs = GIBOK_tibia_PlateauLayerACS(EpiTibAS, CSs);

%% Inertia Results
Yi = V_all(:,2); Yi = sign(Yi'*Y0)*Yi;
Xi = cross(Yi,Z0);

CSs.CenterAnkle2 = CenterAnkleInside;
CSs.CenterAnkle = ankleCenter;
CSs.Zinertia = Z0;
CSs.Yinertia = Yi;
CSs.Xinertia = Xi;
CSs.Minertia = [Xi Yi Z0];

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


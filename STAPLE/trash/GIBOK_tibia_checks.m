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

subplot(3,1,1)
quickPlotTriang(EpiTib);

%========================
% GROUP TOGETHER (ITER 1)
%========================
% ITERATION 1: Identify raw Articular Surfaces (AS) based on curvature
%--------------
% parameters
%--------------
angle_thresh = 35;% deg
curv_quartile = 0.25;
%--------------
[EpiTibAS, oLSP, Ztp] = GIBOK_tibia_FullProxArtSurf_it1(EpiTib, CSs, angle_thresh, curv_quartile);

% remove the ridge and the central part of the surface
EpiTibAS = GIBOK_tibia_ProxArtSurf_it1(ProxTib, EpiTibAS, CSs, Ztp , oLSP);

% debug plot
subplot(3,1,2)
quickPlotTriang(EpiTibAS);hold on
warning('Needs a check on the filter')

% % Smooth found ArtSurf
% % makes the algorithm fail
% EpiTibAS = TriOpenMesh(EpiTib,EpiTibAS, 15);
% EpiTibAS = TriCloseMesh(EpiTib,EpiTibAS, 30);
EpiTibAS = TriOpenMesh(EpiTib,EpiTibAS, 1);
EpiTibAS = TriCloseMesh(EpiTib,EpiTibAS, 2);
quickPlotTriang(EpiTibAS, 'g', 1);hold on

%========================
% GROUP TOGETHER (ITER 2)
%========================
[EpiTibASMed2, EpiTibASLat2, EpiTibAS2] = GIBOK_tibia_ProxArtSurf_it2(EpiTib, EpiTibAS, CSs);
EpiTibAS3 = TriUnite(EpiTibASMed2, EpiTibASLat2);

% % Update the AS and the fitted LS plane
[oLSP,Ztp] = lsplane(EpiTibAS.Points, Z0);
d = -oLSP * Ztp;
% 
% % Seperate Medial and lateral
[ Xel, Yel, ellipsePts , ellipsePpties] = ...
                        EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP);
a = ellipsePpties.a;
b = ellipsePpties.b;
Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Yel'*Y0)*Yel;

MedPtsInit = mean(ellipsePts) + 2/3*b*Yel';
LatPtsInit = mean(ellipsePts) - 2/3*b*Yel';

MedPtsInit = [MedPtsInit; MedPtsInit - 1/3*a*Xel'; MedPtsInit + 1/3*a*Xel'];
LatPtsInit = [LatPtsInit; LatPtsInit - 1/3*a*Xel'; LatPtsInit + 1/3*a*Xel'];
% 
EpiTibASMed = TriConnectedPatch( EpiTibAS, MedPtsInit);
EpiTibASLat = TriConnectedPatch( EpiTibAS, LatPtsInit );

%=============================
EpiTibASMedElmtsOK = find(abs(EpiTibASMed.incenter*Ztp+d) < 5 & ...
                              EpiTibASMed.faceNormal*Ztp > 0.9 );
EpiTibASMed = TriReduceMesh(EpiTibASMed,EpiTibASMedElmtsOK);
EpiTibASMed = TriOpenMesh(EpiTib,EpiTibASMed,2);
EpiTibASMed = TriConnectedPatch( EpiTibASMed, MedPtsInit );
EpiTibASMed = TriCloseMesh(EpiTib,EpiTibASMed,10);
%=============================
% exactly the same as above!
EpiTibASLatElmtsOK = find(abs(EpiTibASLat.incenter*Ztp+d)<5 & ...
                              EpiTibASLat.faceNormal*Ztp>0.9 );
EpiTibASLat = TriReduceMesh(EpiTibASLat,EpiTibASLatElmtsOK);
EpiTibASLat = TriOpenMesh(EpiTib,EpiTibASLat,2);
EpiTibASLat = TriConnectedPatch( EpiTibASLat, LatPtsInit );
EpiTibASLat = TriCloseMesh(EpiTib,EpiTibASLat,10);
%===============================================================
% quickPlotTriang(EpiTibASLat,'r');hold on
% quickPlotTriang(EpiTibASMed,'b');hold on
 
EpiTibAS = TriUnite(EpiTibASMed,EpiTibASLat);
% check
max(EpiTibAS.Points-EpiTibAS2.Points)

%========================
% GROUP TOGETHER (ITER 3)
%========================

%========================================

% check against this
[oLSP,Ztp] = lsplane(EpiTibAS.Points,  Z0);
d = -oLSP*Ztp;
EpiTibASMedElmtsOK = find(abs(EpiTibASMed.incenter  *Ztp+d)<5 & ...
                              EpiTibASMed.faceNormal*Ztp>0.95 );
EpiTibASMed = TriReduceMesh(EpiTibASMed,EpiTibASMedElmtsOK);
EpiTibASMed = TriOpenMesh(EpiTib,EpiTibASMed,2);
EpiTibASMed = TriConnectedPatch( EpiTibASMed, MedPtsInit );
EpiTibASMed = TriCloseMesh(EpiTib,EpiTibASMed,10);

EpiTibASLatElmtsOK = find(abs(EpiTibASLat.incenter*Ztp+d)<3 & ...
                              EpiTibASLat.faceNormal*Ztp>0.95 );
EpiTibASLat = TriReduceMesh(EpiTibASLat,EpiTibASLatElmtsOK);
EpiTibASLat = TriOpenMesh(EpiTib,EpiTibASLat,2);
EpiTibASLat = TriConnectedPatch( EpiTibASLat, LatPtsInit );
EpiTibASLat = TriCloseMesh(EpiTib,EpiTibASLat,10);

EpiTibAS = TriUnite(EpiTibASMed,EpiTibASLat);
quickPlotTriang(EpiTibAS)
%===========================================================
% comparison
max(EpiTibAS.Points-EpiTibAS3.Points)


% NOTE: EpiTibAS3 is the final mesh from the functions
EpiTibAS = EpiTibAS3;
%% BETTER TO INCLUDE IN INDIVIDUAL FUNCTIONS
% final fit
% fit a plane to the resulting tibial epiPhysis 
[oLSP, Ztp] = lsplane(EpiTibAS.Points,Z0);


%% Technic 1 : Fitted Ellipse
[ Xel, Yel, ellipsePts ] = EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP );
Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Yel'*Y0)*Yel;

Pt_Knee = mean(ellipsePts);

Zmech = Pt_Knee - ankleCenter; 
Zmech = Zmech' / norm(Zmech);

% Final ACS
Xend = cross(Yel,Zmech)/norm(cross(Yel,Zmech));
Yend = cross(Zmech,Xend);

Yend = sign(Yend'*Y0)*Yend;
Zend = Zmech;
Xend = cross(Yend,Zend);

Vend = [Xend Yend Zend];

% Result write
CSs.ECASE.CenterVol = CenterVol;
CSs.ECASE.CenterAnkle = ankleCenter;
CSs.ECASE.CenterKnee = Pt_Knee;
CSs.ECASE.Z0 = Z0;
CSs.ECASE.Ztp = Ztp;
CSs.ECASE.Zmech = Zmech;

CSs.ECASE.Origin = Pt_Knee;
CSs.ECASE.X = Xend;
CSs.ECASE.Y = Yend;
CSs.ECASE.Z = Zend;

CSs.ECASE.Origin = Pt_Knee;
CSs.ECASE.V = Vend;


%% Technic 2 : Center of medial & lateral condyles

[ TibArtLat_ppt ] = TriMesh2DProperties( EpiTibASLat );
[ TibArtMed_ppt ] = TriMesh2DProperties( EpiTibASMed );
Pt_Knee = 0.5*TibArtMed_ppt.Center + 0.5*TibArtLat_ppt.Center;

Zmech = normalizeV(Pt_Knee-ankleCenter);

Y2 = TibArtMed_ppt.Center - TibArtLat_ppt.Center;
Y2 = Y2' / norm(Y2);

% Final ACS
Xend = cross(Y2,Zmech)/norm(cross(Y2,Zmech));
Yend = cross(Zmech,Xend);

Xend = sign(Xend'*Y0)*Xend;
Yend = sign(Yend'*Y0)*Yend;
Zend = Zmech;
Xend = cross(Yend,Zend);

Vend = [Xend Yend Zend];

% Result write
CSs.CASC.CenterVol = CenterVol;
CSs.CASC.CenterAnkle = ankleCenter;
CSs.CASC.CenterKnee = Pt_Knee;
CSs.CASC.Z0 = Z0;
CSs.CASC.Ztp = Ztp;

CSs.CASC.Origin = Pt_Knee;
CSs.CASC.X = Xend;
CSs.CASC.Y = Yend;
CSs.CASC.Z = Zend;

CSs.CASC.V  = Vend ;


%% Technic 3 : Compute the inertial axis of a slice of the tp plateau
% 10% below and the 5% above : Fill it with equally spaced points to
% simulate inside volume
%
[ Xel, Yel, ellipsePts ] = EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP );
Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Yel'*Y0)*Yel;

H = 0.1 * sqrt(4*0.75*max(Area)/pi);

Alt_TP = linspace( -d-H ,-d+0.5*H, 20);
PointSpace = mean(diff(Alt_TP));
TPLayerPts = zeros(round(length(Alt_TP)*1.1*max(Area)/PointSpace^2),3);
j=0;
i=0;
for alt = -Alt_TP
    [ Curves , ~ , ~ ] = TriPlanIntersect( EpiTib, Ztp , alt );
    for c=1:length(Curves)
        
        Pts_Tmp = Curves(c).Pts*[Xel Yel Ztp];
        xmg = min(Pts_Tmp(:,1)) -0.1 : PointSpace : max(Pts_Tmp(:,1)) +0.1 ;
        ymg = min(Pts_Tmp(:,2)) -0.1 : PointSpace : max(Pts_Tmp(:,2)) +0.1;
        [XXmg , YYmg] = meshgrid(xmg,ymg);
        in = inpolygon(XXmg(:),YYmg(:),Pts_Tmp(:,1),Pts_Tmp(:,2));
        Iin = find(in, 1);
        if ~isempty(Iin)
            i = j+1;
            j=i+length(find(in))-1;
            TPLayerPts(i:j,:) = transpose([Xel Yel Ztp]*[XXmg(in),YYmg(in),ones(length(find(in)),1)*alt]');
        end
    end
    
end

TPLayerPts(j+1:end,:) = [];

[V,~] = eig(cov(TPLayerPts));

Xtp = V(:,2); Ytp = V(:,3);
Xtp = sign(Xtp'*Y0)*Xtp;
Ytp = sign(Ytp'*Y0)*Ytp;

idx = kmeans(TPLayerPts,2);

[ CenterMed ] = ProjectOnPlan( mean(TPLayerPts(idx==1,:)) , Ztp , d );
[ CenterLat ] = ProjectOnPlan( mean(TPLayerPts(idx==2,:)) , Ztp , d );

CenterKnee = 0.5*( CenterMed + CenterLat);

Zmech = CenterKnee - CenterAnkleInside; Zmech = Zmech' / norm(Zmech);

% Final ACS
Xend = cross(Ytp,Zmech)/norm(cross(Ytp,Zmech));
Yend = cross(Zmech,Xend);


Yend = sign(Yend'*Y0)*Yend;
Zend = Zmech;
Xend = cross(Yend,Zend);

Vend = [Xend Yend Zend];

% Result write
CSs.PIAASL.CenterVol = CenterVol;
CSs.PIAASL.CenterAnkle = ankleCenter;
CSs.PIAASL.CenterKnee = CenterKnee;
CSs.PIAASL.Z0 = Z0;
CSs.PIAASL.Ztp = Ztp;
CSs.PIAASL.Ytp = Ytp;
CSs.PIAASL.Xtp = Xtp;

CSs.PIAASL.Origin = CenterKnee;
CSs.PIAASL.X = Xend;
CSs.PIAASL.Y = Yend;
CSs.PIAASL.Z = Zend;

CSs.PIAASL.V = Vend;
CSs.PIAASL.Name='ArtSurfPIA';


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


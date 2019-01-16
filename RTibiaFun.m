function [ CSs, TrObjects ] = RTibiaFun( ProxTib , DistTib)
% Fit an ACS on a Tibia composed of the proximal tibia and the tibial part of
% the ankle

addpath(genpath(strcat(pwd,'/SubFunctions')));
CSs = struct();


%% Get initial Coordinate system and volumetric center
Tibia = TriUnite(ProxTib,DistTib);

% Get eigen vectors V_all of the Tibia 3D geometry and volumetric center
[ V_all, CenterVol, InertiaMatrix ] = TriInertiaPpties( Tibia );


% Initial estimate of the Inf-Sup axis Z0 - Check that the distal tibia
% is 'below': the proximal tibia, invert Z0 direction otherwise;
Z0 = V_all(:,1);
Z0 = sign((mean(ProxTib.Points)-mean(DistTib.Points))*Z0)*Z0;

CSs.Z0 = Z0;
CSs.CenterVol = CenterVol;
CSs.InertiaMatrix = InertiaMatrix;

%% Distal Tibia -> Identified ankle center 
% 1st : Find triangles with less than 30° relative to the tibia principal
% inertia axis (longitudinal) and low curvature then smooth the result with close
% morphology operation

Alt =  min(DistTib.Points*Z0)+1 : 0.3 : max(DistTib.Points*Z0)-1;
Area = zeros(size(Alt));
i=0;
for d = -Alt
    i = i + 1;
    [ ~ , Area(i), ~ ] = TriPlanIntersect( DistTib, Z0 , d );
end
[~,Imax] = max(Area);
Curves = TriPlanIntersect( DistTib, Z0 , -Alt(Imax) );

CenterAnkleInside = PlanPolygonCentroid3D( Curves.Pts);

% Get mean curvature of Distal Tibia
Cmean = TriCurvature(DistTib,false);

AnkleArtSurfNodesOK0 =  find(Cmean>quantile(Cmean,0.65) & ...
    Cmean<quantile(Cmean,0.95) & ...
    rad2deg(acos(-DistTib.vertexNormal*Z0))<30);

AnkleArtSurf0 = TriReduceMesh(DistTib,[],double(AnkleArtSurfNodesOK0));
AnkleArtSurf0 = TriCloseMesh(DistTib,AnkleArtSurf0,6);
AnkleArtSurf0 = TriOpenMesh(DistTib,AnkleArtSurf0,4);
AnkleArtSurf0 = TriConnectedPatch( AnkleArtSurf0, mean(AnkleArtSurf0.Points));

% 2nd : fit a polynomial surface to it AND 
%   exclude points that are two far (1mm) from the fitted surface,
%   then smooth the results with open & close morphology operations
TibiaElmtsIDOK = AnkleSurfFit( AnkleArtSurf0, DistTib, V_all );
AnkleArtSurf = TriReduceMesh(DistTib , TibiaElmtsIDOK);
AnkleArtSurf = TriErodeMesh(AnkleArtSurf,2);
AnkleArtSurf = TriCloseMesh(DistTib,AnkleArtSurf,6);
AnkleArtSurf = TriOpenMesh(DistTib,AnkleArtSurf,4);
AnkleArtSurf = TriCloseMesh(DistTib,AnkleArtSurf,2);

% Filter elements that are not oriented towards the "axis" of the AS
AnkleArtSurfProperties = TriMesh2DProperties( AnkleArtSurf );
ZAnkleSurf = AnkleArtSurfProperties.meanNormal;
CAnkle = AnkleArtSurfProperties.onMeshCenter;
AnkleArtSurfElmtsOK = find(rad2deg(acos(AnkleArtSurf.faceNormal*ZAnkleSurf))<35 & ...
    sum(bsxfun(@minus,AnkleArtSurf.incenter,CAnkle).*AnkleArtSurf.faceNormal,2)./...
    sqrt(sum(bsxfun(@minus,AnkleArtSurf.incenter,CAnkle).^2,2))<0.1);
AnkleArtSurf = TriReduceMesh(AnkleArtSurf,AnkleArtSurfElmtsOK);
AnkleArtSurf = TriOpenMesh(DistTib,AnkleArtSurf,4);
AnkleArtSurf = TriCloseMesh(DistTib,AnkleArtSurf,10);

% Method to get ankle center : 
%   1) Fit a LS plan to the art surface, 
%   2) Inset the plan 5mm
%   3) Get the center of section at the intersection with the plan 
%   4) Project this center Bback to original plan

[oLSP_AAS,nAAS] = lsplane(AnkleArtSurf.Points, Z0);

Curves = TriPlanIntersect( DistTib, nAAS , (oLSP_AAS + 5*nAAS') );
Centr = PlanPolygonCentroid3D( Curves.Pts );

ankleCenter = Centr -5*nAAS';

%% Find a pseudo medioLateral Axis :
% Most Distal point of the medial malleolus (MDMMPt)
ZAnkleSurf = AnkleArtSurfProperties.meanNormal;
[~,I] = max(DistTib.Points*ZAnkleSurf);
MDMMPt = DistTib.Points(I,:);

% Vector between ankle center and the most Distal point (MDMMPt)
U_tmp = MDMMPt - ankleCenter;

%Make the vector U_tmp orthogonal to Z0 and normalize it
Y0 = normalizeV(  U_tmp' - (U_tmp*Z0)*Z0  ); 



%% Proximal Tibia, Separate epiphysis from diaphysis
% Get the evolution of the cross section area along the longitudinal axis

% First 0.5 mm in Start and End are not accounted for, for stability.
Alt = linspace( min(ProxTib.Points*Z0)+0.5 ,max(ProxTib.Points*Z0)-0.5, 100);
Area=[];
for d = -Alt
    [ ~ , Area(end+1), ~ ] = TriPlanIntersect( ProxTib, Z0 , d );
end
AltAtMax = Alt(Area==max(Area));

[ZdiaphF,Zepi,Zdirection] = FitCSA(Alt, Area);

ElmtsEpi = find(ProxTib.incenter*Z0>Zepi);
EpiTib = TriReduceMesh( ProxTib, ElmtsEpi );

%% Identified a first raw Articular Surfaces (AS)
% Get curvature "intensity"
[Cmean,Cgaussian]=TriCurvature(EpiTib,false);
Curvtr = sqrt(4*Cmean.^2-2*Cgaussian);

% Keep only the elements that respect both criteria :
%   1) Make an angle inferior to 35° with Z0
%   2) Within the 1st quartile of curvature "intensity"
NodesEpiAS_OK = find(   rad2deg(acos(EpiTib.vertexNormal*Z0))<35 &...
                            Curvtr<quantile(Curvtr,0.25)) ;
Pcondyle = EpiTib.Points(NodesEpiAS_OK,:);

% Smooth results and fit a LS plane oriented in the same direction as Z0
EpiTibAS = TriReduceMesh( EpiTib, [] , NodesEpiAS_OK );
EpiTibAS = TriCloseMesh( EpiTib, EpiTibAS, 6 );
[oLSP,Ztp] = lsplane(Pcondyle, Z0); 

% Fit an ellipse on proximal AS to get an initial Ml and AP axis
[ Xel, Yel, ellipsePts , ellipsePpties] = EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP );
a = ellipsePpties.a;
b = ellipsePpties.b;
Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Y0'*Yel)*Yel;

% Compute seed points to get a patch of AS on each condyle
MedPtsInit = mean(ellipsePts) + 2/3*b*Yel';
MedPtsInit = [MedPtsInit; MedPtsInit - 1/3*a*Xel'; MedPtsInit + 1/3*a*Xel'];
EpiTibASMed = TriConnectedPatch( EpiTibAS, MedPtsInit );

LatPtsInit = mean(ellipsePts) - 2/3*b*Yel';
LatPtsInit = [LatPtsInit; LatPtsInit - 1/3*a*Xel'; LatPtsInit + 1/3*a*Xel'];
EpiTibASLat = TriConnectedPatch( EpiTibAS, LatPtsInit );

% Update the AS and the fitted LS plane
EpiTibAS = TriUnite(EpiTibASMed,EpiTibASLat);

[oLSP,Ztp] = lsplane(Pcondyle, Z0);

%% Remove between ridges part from the AS
% Identify an anterior region between the medial and lateral ridges
[ Xel, Yel, ellipsePts, ellipsePpties] = EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP);
a = ellipsePpties.a;
b = ellipsePpties.b;

Xel = sign(Xel'*Y0)*Xel ;
Yel = sign(Yel'*Y0)*Yel ;

% Find highest point on medial ridge on an anterior section of the plateau
d = -(mean(ellipsePts)*Xel + 0.5*a);
Curves = TriPlanIntersect( ProxTib, Xel , d );
MedialPts_tmp = Curves(1).Pts(bsxfun(@minus,Curves(1).Pts,mean(ellipsePts))*Yel>0,:);
[~,IDPtsMax] = max(MedialPts_tmp*Z0);
PtsMax = MedialPts_tmp(IDPtsMax,:);

% Get normal of the plan containing the highest point, the ellipse center
% and Z0 (initial Distal-To-Proximal axis) 
U_tmp =  PtsMax'-mean(ellipsePts)';

np = cross(U_tmp,Ztp); 
np = normalizeV(  sign(cross(Xel,Yel)'*Z0)*np  );
dp = -mean(ellipsePts)*np;

nm = Yel;
dm = -mean(ellipsePts)*nm;
% Identify the point contained between this plan and ellipse middle plan
NodesOnCenterID = find(sign(EpiTib.Points*np+dp) + sign(EpiTib.Points*nm+dm)>0.1);
EpiTibCenterRidgeMed = TriReduceMesh( EpiTib, [] , NodesOnCenterID );

% Find highest point on lateral ridge on an anterior section of the plateau
LateralPts_tmp = Curves(1).Pts(bsxfun(@minus,Curves(1).Pts,mean(ellipsePts))*Yel<0 & ...
    bsxfun(@minus,Curves(1).Pts,mean(ellipsePts))*Yel>-b/3&...
    abs(bsxfun(@minus,Curves(1).Pts,mean(ellipsePts))*Z0)<a/2,:);
[~,IDPtsMax] = min(LateralPts_tmp*Z0);
PtsMax = LateralPts_tmp(IDPtsMax,:); %+mean(ellipsePts);

U_tmp =  transpose(PtsMax-mean(ellipsePts));

np = cross(U_tmp,Ztp); 
np = normalizeV(  -sign(cross(Xel,Yel)'*Z0)*np  );
dp = -mean(ellipsePts)*np;

nm = -Yel;
dm = -mean(ellipsePts)*nm;

% Identify the point contained between this plan and ellipse middle plan
NodesOnCenterID = find(sign(EpiTib.Points*np+dp) + sign(EpiTib.Points*nm+dm)>0.1);
EpiTibCenterRidgeLat = TriReduceMesh( EpiTib, [] , NodesOnCenterID );
EpiTibCenterRidgeLat = TriDilateMesh(EpiTib, EpiTibCenterRidgeLat,5);


EpiTibCenterRidge = TriUnite(EpiTibCenterRidgeLat,EpiTibCenterRidgeMed);

%% Refine and seperate medial and lateral AS region
% Compute seed points to get a patch of AS on each condyle
MedPtsInit = mean(ellipsePts) + 2/3*b*Yel';
MedPtsInit = [MedPtsInit; MedPtsInit - 1/3*a*Xel'; MedPtsInit + 1/3*a*Xel'];
LatPtsInit = mean(ellipsePts) - 2/3*b*Yel';
LatPtsInit = [LatPtsInit; LatPtsInit - 1/3*a*Xel'; LatPtsInit + 1/3*a*Xel'];

% Remove between ridge points from identified AS points
EpiTibAS = TriDifferenceMesh(EpiTibAS , EpiTibCenterRidge);
EpiTibAS = TriConnectedPatch( EpiTibAS , [MedPtsInit ; LatPtsInit] );
% Smooth found AS
EpiTibAS = TriOpenMesh(EpiTib,EpiTibAS, 15);
EpiTibAS = TriCloseMesh(EpiTib,EpiTibAS, 30);

% Update the AS and the fitted LS plane
[oLSP,Ztp] = lsplane(EpiTibAS.Points,Z0);
d = -oLSP*Ztp;

% Seperate Medial and lateral
[ Xel, Yel, ellipsePts , ellipsePpties] = ...
                        EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP);
a = ellipsePpties.a;
b = ellipsePpties.b;
Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Yel'*Y0)*Yel;

MedPtsInit = mean(ellipsePts) + 2/3*b*Yel';
MedPtsInit = [MedPtsInit; MedPtsInit - 1/3*a*Xel'; MedPtsInit + 1/3*a*Xel'];
LatPtsInit = mean(ellipsePts) - 2/3*b*Yel';
LatPtsInit = [LatPtsInit; LatPtsInit - 1/3*a*Xel'; LatPtsInit + 1/3*a*Xel'];


EpiTibASMed = TriConnectedPatch( EpiTibAS, MedPtsInit);
EpiTibASLat = TriConnectedPatch( EpiTibAS, LatPtsInit );

% Filter out element with wrong normal or too far from LS plane + Smoothing
EpiTibASMedElmtsOK = find(abs(EpiTibASMed.incenter*Ztp+d) < 5 & ...
    EpiTibASMed.faceNormal*Ztp > 0.9 );
EpiTibASMed = TriReduceMesh(EpiTibASMed,EpiTibASMedElmtsOK);
EpiTibASMed = TriOpenMesh(EpiTib,EpiTibASMed,2);
EpiTibASMed = TriConnectedPatch( EpiTibASMed, MedPtsInit );
EpiTibASMed = TriCloseMesh(EpiTib,EpiTibASMed,10);

EpiTibASLatElmtsOK = find(abs(EpiTibASLat.incenter*Ztp+d)<5 & ...
    EpiTibASLat.faceNormal*Ztp>0.9 );
EpiTibASLat = TriReduceMesh(EpiTibASLat,EpiTibASLatElmtsOK);
EpiTibASLat = TriOpenMesh(EpiTib,EpiTibASLat,2);
EpiTibASLat = TriConnectedPatch( EpiTibASLat, LatPtsInit );
EpiTibASLat = TriCloseMesh(EpiTib,EpiTibASLat,10);

EpiTibAS = TriUnite(EpiTibASMed,EpiTibASLat);

[oLSP,Ztp] = lsplane(EpiTibAS.Points,Z0);
d = -oLSP*Ztp;

EpiTibASMedElmtsOK = find(abs(EpiTibASMed.incenter*Ztp+d)<5 & ...
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

[oLSP,Ztp] = lsplane(EpiTibAS.Points,Z0);


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

Zmech = Pt_Knee - ankleCenter; Zmech = Zmech' / norm(Zmech);

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

%% Technic 4 fitted, Ellipse at the the largest cross section area
%--------------------- Kai et Al. 2014 technic ----------------------------
Alt = AltAtMax-0.6:0.05:AltAtMax+0.6;
Area=[];
for d = -Alt
    [ ~ , Area(end+1), ~ ] = TriPlanIntersect( ProxTib, Z0 , d );
end

% Get the bone outline at maximal CSA
AltAtMax = Alt(Area==max(Area));
[ Curves , ~, ~ ] = TriPlanIntersect( ProxTib, Z0 , -AltAtMax );


% Move the outline curve points in the PIA CS
PtsCurves = vertcat(Curves(:).Pts)*V_all;

% Fit an ellipse to the moved points and move back to the original CS
FittedEllipse = fit_ellipse( PtsCurves(:,2),PtsCurves(:,3));
CenterEllipse = transpose(V_all*[mean(PtsCurves(:,1));FittedEllipse.X0_in;FittedEllipse.Y0_in]);

YElpsMax = V_all*[0;cos(FittedEllipse.phi);-sin(FittedEllipse.phi)]; 
YElpsMax = sign(Y0'*YElpsMax)*YElpsMax;


EllipsePts = transpose(V_all*[ones(length(FittedEllipse.data),1)*PtsCurves(1) FittedEllipse.data']');

% Construct the Kai et Al. 2014 CS
Zend = Z0;
Xend = normalizeV( cross(YElpsMax,Zend) );
Yend = cross(Zend,Xend);

Yend = normalizeV( sign(Yend'*Y0)*Yend );
Xend = cross(Yend,Zend);

% Result write
CSs.KAI2014.CenterVol = CenterVol;
CSs.KAI2014.CenterKnee = CenterEllipse;
CSs.KAI2014.YElpsMax = YElpsMax;

CSs.KAI2014.Origin = CenterEllipse;
CSs.KAI2014.X = Xend;
CSs.KAI2014.Y = Yend;
CSs.KAI2014.Z = Zend;

CSs.KAI2014.V = [Xend Yend Zend];
CSs.KAI2014.ElpsPts = EllipsePts;


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


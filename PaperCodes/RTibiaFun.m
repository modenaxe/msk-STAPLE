function [ Results ] = RTibiaFun( name , oprtr , RATM_on)
% Fit an ACS on a Tibia composed of the proximal tibia and the tibial part of
% the ankle

addpath(strcat(pwd,'\SubFonctions'));
addpath(strcat(pwd,'\SubFonctions\SurFit'));

Results = struct();

% Piece of code to generate a random affine transformation matrix

%% Read the 3D bone model mesh
% Read the Proximal Tibia (TIB) 3d bone model
XYZELMTS = py.txt2mtlb.read_meshGMSH(strcat('\Repere3DData\',name,'_TIB',oprtr,'05.msh'));
Pts2D = [cell2mat(cell(XYZELMTS{'X'}))' cell2mat(cell(XYZELMTS{'Y'}))' cell2mat(cell(XYZELMTS{'Z'}))'];
Elmts2D = double([cell2mat(cell(XYZELMTS{'N1'}))' cell2mat(cell(XYZELMTS{'N2'}))' cell2mat(cell(XYZELMTS{'N3'}))']);
if RATM_on
    % Get a random affine transformation matrix (Roto-Translation)
    [ Matm , Vatm , Tatm, angles ] = randomATM;
    Results.RATM.ATM = Matm;
    Results.RATM.R = Vatm;
    Results.RATM.T = Tatm;
    Results.RATM.Angles = angles;
	
	% Update Proximal Tibia vertices loacation with rATM
    Pts2D = bsxfun(@plus,Pts2D*Vatm , Tatm');
end

% Verify that normal are outward-pointing and fix if not
Elmts2D = fixNormals( Pts2D, Elmts2D );
ProxTib = triangulation(Elmts2D,Pts2D);

% Read the Distal Tibia (ANK) 3d bone model
XYZELMTS = py.txt2mtlb.read_meshGMSH(strcat('\Repere3DData\',name,'_ANK',oprtr,'05.msh'));Pts2D = [cell2mat(cell(XYZELMTS{'X'}))' cell2mat(cell(XYZELMTS{'Y'}))' cell2mat(cell(XYZELMTS{'Z'}))'];
Elmts2D = double([cell2mat(cell(XYZELMTS{'N1'}))' cell2mat(cell(XYZELMTS{'N2'}))' cell2mat(cell(XYZELMTS{'N3'}))']);
if RATM_on
    % Update Distal Tibia vertices loacation with rATM
    Pts2D = bsxfun(@plus,Pts2D*Vatm , Tatm');
end

% Verify that normal are outward-pointing and fix if not
Elmts2D = fixNormals( Pts2D, Elmts2D );
DistTib = triangulation(Elmts2D,Pts2D);

% Unite both distal and proximal tibia mesh
Tibia = triangulationUnite(ProxTib,DistTib);

[ InertiaMatrix, Center ] = InertiaProperties( Tibia.Points, Tibia.ConnectivityList );
[V_all,D] = eig(InertiaMatrix);
Center0 = Center;


% Initial estimate of the Inf-Sup axis Z0 - Check that the distal tibia
% is 'below': the proximal tibia, invert Z0 direction otherwise;
Z0 = V_all(:,1);
V_all(:,2) = sign((mean(ProxTib.Points)-mean(DistTib.Points))*Z0)*V_all(:,2);
Z0 = sign((mean(ProxTib.Points)-mean(DistTib.Points))*Z0)*Z0;
V_all(:,1) = Z0;


Minertia = V_all;



%% Distal Tibia

% 1st : Find triangles with less than 30° relative to the tibia principal
% inertia axis (longitudinal) and low curvature then smooth the result with close
% morphology operation

Alt =  min(DistTib.Points*Z0)+1 : 0.3 : max(DistTib.Points*Z0)-1;
Area=[];
for d = Alt
    [ ~ , Area(end+1), ~ ] = TriPlanIntersect( DistTib.Points, DistTib.ConnectivityList, Z0 , d );
end
[~,Imax] = max(Area);
[ Curves ,  ~ , ~ ] = TriPlanIntersect( DistTib.Points, DistTib.ConnectivityList, Z0 , Alt(Imax) );

CenterAnkleInside = PlanPolygonCentroid3D( Curves.Pts);


[Cmean,Cgaussian,Dir1,Dir2,Lambda1,Lambda2]=meshCurvature(DistTib,false);

AnkleArtSurfNodesOK0 =  find(Cmean>quantile(Cmean,0.65) & ...
    Cmean<quantile(Cmean,0.95) & ...
    rad2deg(acos(-DistTib.vertexNormal*Z0))<30);

AnkleArtSurf0 = TriReduceMesh(DistTib,[],double(AnkleArtSurfNodesOK0));
AnkleArtSurf0 = TriCloseMesh(DistTib,AnkleArtSurf0,6);
AnkleArtSurf0 = TriOpenMesh(DistTib,AnkleArtSurf0,4);
AnkleArtSurf0 = TriConnectedPatch( AnkleArtSurf0, mean(AnkleArtSurf0.Points));

% 2nd : fit a polynomial surface to it AND Exclude points that are two far (1mm) from the fitted surface,
% then smooth the results with open & close morphology operations
TibiaElmtsIDOK = AnkleSurfFit( AnkleArtSurf0, DistTib, V_all );
AnkleArtSurf = TriReduceMesh(DistTib , TibiaElmtsIDOK);
AnkleArtSurf = TriErodeMesh(AnkleArtSurf,2);
AnkleArtSurf = TriCloseMesh(DistTib,AnkleArtSurf,6);
AnkleArtSurf = TriOpenMesh(DistTib,AnkleArtSurf,4);
AnkleArtSurf = TriCloseMesh(DistTib,AnkleArtSurf,2);


% Filter Elmts that are not
AnkleArtSurfProperties = TriMesh2DProperties( AnkleArtSurf );
ZAnkleSurf = AnkleArtSurfProperties.meanNormal;
CAnkle = AnkleArtSurfProperties.onMeshCenter;
AnkleArtSurfElmtsOK = find(rad2deg(acos(AnkleArtSurf.faceNormal*ZAnkleSurf))<35 & ...
    sum(bsxfun(@minus,AnkleArtSurf.incenter,CAnkle).*AnkleArtSurf.faceNormal,2)./...
    sqrt(sum(bsxfun(@minus,AnkleArtSurf.incenter,CAnkle).^2,2))<0.1);
AnkleArtSurf = TriReduceMesh(AnkleArtSurf,AnkleArtSurfElmtsOK);
AnkleArtSurf = TriOpenMesh(DistTib,AnkleArtSurf,4);
AnkleArtSurf = TriCloseMesh(DistTib,AnkleArtSurf,10);

AnkleArtSurfProperties = TriMesh2DProperties( AnkleArtSurf );

% End of the Method : 
% 1) Fit a LS plan to the art surface, 
% 2) Inset the plan 5mm
% 3) Get the center of Shape with shape intersection 
% 4) Project Center Back

[nAAS,dAAS] = PlanMC(AnkleArtSurf.Points);
dAAS = sign(nAAS'*Z0)*dAAS; nAAS = sign(nAAS'*Z0)*nAAS;
[ Curves , ~, ~ ] = TriPlanIntersect( DistTib.Points, DistTib.ConnectivityList, nAAS , -dAAS+5 );
Centr = PlanPolygonCentroid3D( Curves.Pts );
CenterAnkle = Centr -5*nAAS';

%% Find a pseudo medioLateral Axis :
% Most Distal point of the medial malleolus (MDMMPt)
ZAnkleSurf = AnkleArtSurfProperties.meanNormal;
[~,I] = max(DistTib.Points*ZAnkleSurf);
MDMMPt = DistTib.Points(I,:);

U_tmp = MDMMPt - CenterAnkle;
Y0 = U_tmp' - (U_tmp*Z0)*Z0; Y0=Y0/norm(Y0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%  END OF DISTAL TIBIA %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Proximal Tibia

% First 0.5 mm in Start and End are not accounted for, for stability.

Alt = linspace( min(ProxTib.Points*Z0)+0.5 ,max(ProxTib.Points*Z0)-0.5, 100);
Area=[];
for d = Alt
    [ ~ , Area(end+1), ~ ] = TriPlanIntersect( ProxTib.Points, ProxTib.ConnectivityList, Z0 , d );
end
AltAtMax = Alt(Area==max(Area));

[ZdiaphF,Zepi,Zdirection] = FitArea(Alt, Area);

ElmtsEpi = find(ProxTib.incenter*Z0>Zepi); % & rad2deg(acos(ProxTib.faceNormal*Z0))<45;
EpiTib = TriReduceMesh( ProxTib, ElmtsEpi );


[Cmean,Cgaussian,Dir1,Dir2,Lambda1,Lambda2]=meshCurvature(EpiTib,false);

Curvtr = sqrt(4*Cmean.^2-2*Cgaussian);

NodesEpiArtSurfOK = find(rad2deg(acos(EpiTib.vertexNormal*Z0))<35 &...
    Curvtr<quantile(Curvtr,0.25)) ;
Pcondyle = EpiTib.Points(NodesEpiArtSurfOK,:);
EpiTibArt = TriReduceMesh( EpiTib, [] , NodesEpiArtSurfOK );
EpiTibArt = TriCloseMesh( EpiTib, EpiTibArt, 6 );
[Ztp,d] = PlanMC(Pcondyle);
d = sign(Z0'*Ztp)*d;
Ztp = sign(Z0'*Ztp)*Ztp;


[ Xel, Yel, ellipsePts , ellipsePpties] = EllipseOnEdge( EpiTibArt, Ztp , d );
a = ellipsePpties.a;
b = ellipsePpties.b;


MedPtsInit = mean(ellipsePts) + 2/3*b*Yel';
MedPtsInit = [MedPtsInit; MedPtsInit - 1/3*a*Xel'; MedPtsInit + 1/3*a*Xel'];
LatPtsInit = mean(ellipsePts) - 2/3*b*Yel';
LatPtsInit = [LatPtsInit; LatPtsInit - 1/3*a*Xel'; LatPtsInit + 1/3*a*Xel'];

EpiTibArtMed = TriConnectedPatch( EpiTibArt, MedPtsInit );
EpiTibArtLat = TriConnectedPatch( EpiTibArt, LatPtsInit );
EpiTibArt = triangulationUnite(EpiTibArtMed,EpiTibArtLat);
[Ztp,d] = PlanMC(EpiTibArt.Points);
d = sign(Z0'*Ztp)*d;
Ztp = sign(Z0'*Ztp)*Ztp;

[ Xel, Yel, ellipsePts , ellipsePpties] = EllipseOnEdge( EpiTibArt, Ztp , d );
a = ellipsePpties.a;
b = ellipsePpties.b;


Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Yel'*Y0)*Yel;

d = mean(ellipsePts)*Xel+0.5*a;

[ Curves , ~, ~ ] = TriPlanIntersect( ProxTib.Points, ProxTib.ConnectivityList, Xel , d );

MedialPts_tmp = Curves(1).Pts(bsxfun(@minus,Curves(1).Pts,mean(ellipsePts))*Yel>0,:);
[~,IDPtsMax] = max(MedialPts_tmp*Z0);
PtsMax = MedialPts_tmp(IDPtsMax,:); %+mean(ellipsePts);

U_tmp =  transpose(PtsMax-mean(ellipsePts));

np = cross(U_tmp,Ztp); np = sign(cross(Xel,Yel)'*Z0)*np/norm(np);
dp = mean(ellipsePts)*np;

nm = Yel;
dm = mean(ellipsePts)*nm;

NodesOnCenterID = find(sign(EpiTib.Points*np-dp) + sign(EpiTib.Points*nm-dm)>0.1);
EpiTibCenterRidgeMed = TriReduceMesh( EpiTib, [] , NodesOnCenterID );


LateralPts_tmp = Curves(1).Pts(bsxfun(@minus,Curves(1).Pts,mean(ellipsePts))*Yel<0 & ...
    bsxfun(@minus,Curves(1).Pts,mean(ellipsePts))*Yel>-b/3&...
    abs(bsxfun(@minus,Curves(1).Pts,mean(ellipsePts))*Z0)<a/2,:);
[~,IDPtsMax] = min(LateralPts_tmp*Z0);
PtsMax = LateralPts_tmp(IDPtsMax,:); %+mean(ellipsePts);

U_tmp =  transpose(PtsMax-mean(ellipsePts));

np = cross(U_tmp,Ztp); np = -sign(cross(Xel,Yel)'*Z0)*np/norm(np);
dp = mean(ellipsePts)*np;

nm = -Yel;
dm = mean(ellipsePts)*nm;

NodesOnCenterID = find(sign(EpiTib.Points*np-dp) + sign(EpiTib.Points*nm-dm)>0.1);
EpiTibCenterRidgeLat = TriReduceMesh( EpiTib, [] , NodesOnCenterID );
EpiTibCenterRidgeLat = TriDilateMesh(EpiTib, EpiTibCenterRidgeLat,5);


EpiTibCenterRidge = triangulationUnite(EpiTibCenterRidgeLat,EpiTibCenterRidgeMed);


MedPtsInit = mean(ellipsePts) + 2/3*b*Yel';
MedPtsInit = [MedPtsInit; MedPtsInit - 1/3*a*Xel'; MedPtsInit + 1/3*a*Xel'];
LatPtsInit = mean(ellipsePts) - 2/3*b*Yel';
LatPtsInit = [LatPtsInit; LatPtsInit - 1/3*a*Xel'; LatPtsInit + 1/3*a*Xel'];


EpiTibArt = TriDifferenceMesh(EpiTibArt,EpiTibCenterRidge);
EpiTibArt = TriDifferenceMesh(EpiTibArt,EpiTibCenterRidge);
EpiTibArtMed = TriConnectedPatch( EpiTibArt, MedPtsInit );
EpiTibArtLat = TriConnectedPatch( EpiTibArt, LatPtsInit );
EpiTibArt = triangulationUnite(EpiTibArtMed,EpiTibArtLat);
EpiTibArt = TriOpenMesh(EpiTib,EpiTibArt, 15);
EpiTibArt = TriCloseMesh(EpiTib,EpiTibArt, 30);




[Ztp,d] = PlanMC(EpiTibArt.Points);
d = sign(Z0'*Ztp)*d;
Ztp = sign(Z0'*Ztp)*Ztp;

[ Xel, Yel, ellipsePts , ellipsePpties] = EllipseOnEdge( EpiTibArt, Ztp , d );
a = ellipsePpties.a;
b = ellipsePpties.b;
Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Yel'*Y0)*Yel;
MedPtsInit = mean(ellipsePts) + 2/3*b*Yel';
MedPtsInit = [MedPtsInit; MedPtsInit - 1/3*a*Xel'; MedPtsInit + 1/3*a*Xel'];
LatPtsInit = mean(ellipsePts) - 2/3*b*Yel';
LatPtsInit = [LatPtsInit; LatPtsInit - 1/3*a*Xel'; LatPtsInit + 1/3*a*Xel'];


EpiTibArtMed = TriConnectedPatch( EpiTibArt, MedPtsInit);
EpiTibArtLat = TriConnectedPatch( EpiTibArt, LatPtsInit );

EpiTibArtMedElmtsOK = find(abs(EpiTibArtMed.incenter*Ztp+d)<5 & ...
    EpiTibArtMed.faceNormal*Ztp>0.9 );
EpiTibArtMed = TriReduceMesh(EpiTibArtMed,EpiTibArtMedElmtsOK);
EpiTibArtMed = TriOpenMesh(EpiTib,EpiTibArtMed,2);
EpiTibArtMed = TriConnectedPatch( EpiTibArtMed, MedPtsInit );
EpiTibArtMed = TriCloseMesh(EpiTib,EpiTibArtMed,10);

EpiTibArtLatElmtsOK = find(abs(EpiTibArtLat.incenter*Ztp+d)<5 & ...
    EpiTibArtLat.faceNormal*Ztp>0.9 );
EpiTibArtLat = TriReduceMesh(EpiTibArtLat,EpiTibArtLatElmtsOK);
EpiTibArtLat = TriOpenMesh(EpiTib,EpiTibArtLat,2);
EpiTibArtLat = TriConnectedPatch( EpiTibArtLat, LatPtsInit );
EpiTibArtLat = TriCloseMesh(EpiTib,EpiTibArtLat,10);

EpiTibArt = triangulationUnite(EpiTibArtMed,EpiTibArtLat);

[Ztp,d] = PlanMC(EpiTibArt.Points);
d = sign(Z0'*Ztp)*d;
Ztp = sign(Z0'*Ztp)*Ztp;

[ Xel, Yel, ellipsePts , ellipsePpties] = EllipseOnEdge( EpiTibArt, Ztp , d );
a = ellipsePpties.a;
b = ellipsePpties.b;
Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Yel'*Y0)*Yel;

EpiTibArtMedElmtsOK = find(abs(EpiTibArtMed.incenter*Ztp+d)<5 & ...
    EpiTibArtMed.faceNormal*Ztp>0.95 );
EpiTibArtMed = TriReduceMesh(EpiTibArtMed,EpiTibArtMedElmtsOK);
EpiTibArtMed = TriOpenMesh(EpiTib,EpiTibArtMed,2);
EpiTibArtMed = TriConnectedPatch( EpiTibArtMed, MedPtsInit );
EpiTibArtMed = TriCloseMesh(EpiTib,EpiTibArtMed,10);

EpiTibArtLatElmtsOK = find(abs(EpiTibArtLat.incenter*Ztp+d)<3 & ...
    EpiTibArtLat.faceNormal*Ztp>0.95 );
EpiTibArtLat = TriReduceMesh(EpiTibArtLat,EpiTibArtLatElmtsOK);
EpiTibArtLat = TriOpenMesh(EpiTib,EpiTibArtLat,2);
EpiTibArtLat = TriConnectedPatch( EpiTibArtLat, LatPtsInit );
EpiTibArtLat = TriCloseMesh(EpiTib,EpiTibArtLat,10);

EpiTibArt = triangulationUnite(EpiTibArtMed,EpiTibArtLat);

[Ztp,d] = PlanMC(EpiTibArt.Points);
d = sign(Z0'*Ztp)*d;
Ztp = sign(Z0'*Ztp)*Ztp;

[ Xel, Yel, ellipsePts , ellipsePpties] = EllipseOnEdge( EpiTibArt, Ztp , d );
a = ellipsePpties.a;
b = ellipsePpties.b;
Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Yel'*Y0)*Yel;


%% Technic 1 : Fitted Ellipse
Pt_Knee = mean(ellipsePts);

Zmech = Pt_Knee - CenterAnkle; Zmech = Zmech' / norm(Zmech);


% Final ACS
Xend = cross(Yel,Zmech)/norm(cross(Yel,Zmech));
Yend = cross(Zmech,Xend);

Xend = sign(Xend'*Y0)*Xend;
Yend = sign(Yend'*Y0)*Yend;
Zend = Zmech;
Xend = cross(Yend,Zend);

Vend = [Xend Yend Zend];

% Result write
Results.tech1.Center0 = Center0;
Results.tech1.CenterAnkle = CenterAnkle;
Results.tech1.CenterKnee = Pt_Knee;
Results.tech1.Z0 = Z0;
Results.tech1.Ztp = Ztp;
Results.tech1.Zmech = Zmech;
Results.tech1.Xend = Xend;
Results.tech1.Yend = Yend;
Results.tech1.Zend = Zend;
Results.tech1.V = Vend;





%% Technic 2 : Center of medial & lateral condyles

[ TibArtLat_ppt ] = TriMesh2DProperties( EpiTibArtLat );
[ TibArtMed_ppt ] = TriMesh2DProperties( EpiTibArtMed );
Pt_Knee = 0.5*TibArtMed_ppt.Center + 0.5*TibArtLat_ppt.Center;

Zmech = Pt_Knee - CenterAnkle; Zmech = Zmech' / norm(Zmech);

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
Results.tech2.Center0 = Center0;
Results.tech2.CenterAnkle = CenterAnkle;
Results.tech2.CenterKnee = Pt_Knee;
Results.tech2.Z0 = Z0;
Results.tech2.Ztp = Ztp;
Results.tech2.Xend = Xend;
Results.tech2.Yend = Yend;
Results.tech2.Zend = Zend;
Results.tech2.V  = Vend ;






%% Technic 3 : Compute the inertial axis of a slice of the tp plateau
% 10% below and the 5% above : Fill it with equally spaced points to
% simulate inside volume
%

H = 0.1 * sqrt(4*0.75*max(Area)/pi);

ElmtsTP = find(EpiTib.incenter*Ztp>-d-H);
TPTib0 = TriReduceMesh( EpiTib, ElmtsTP ); % Tibial Plateau
TPTib0 = TriFillPlanarHoles(TPTib0);

ElmtsTP = find(TPTib0.incenter*Ztp<-d+0.5*H);
TPTib = TriReduceMesh( TPTib0, ElmtsTP ); % Tibial Plateau
TPTib = TriFillPlanarHoles(TPTib);



[ TPTib_InertiaMatrix, TPTib_Center ] = InertiaProperties( TPTib.Points, TPTib.ConnectivityList );
[V_TPTib,~] = eig(TPTib_InertiaMatrix);

Xtp = V_TPTib(:,2); Ytp = V_TPTib(:,1);
Xtp = sign(Xtp'*Y0)*Xtp;
Ytp = sign(Ytp'*Y0)*Ytp;

CenterKnee = TPTib_Center';


% Alt_TP = linspace( -d-H ,-d+0.5*H, 20);
% PointSpace = mean(diff(Alt_TP));
% TPLayerPts = zeros(round(length(Alt_TP)*1.1*max(Area)/PointSpace^2),3);
% j=0;
% i=0;
% for alt = Alt_TP
%     [ Curves , ~ , ~ ] = TriPlanIntersect( EpiTib.Points, EpiTib.ConnectivityList, Ztp , alt );
%     for c=1:length(Curves)
%         
%         Pts_Tmp = Curves(c).Pts*[Xel Yel Ztp];
%         xmg = min(Pts_Tmp(:,1)) -0.1 : PointSpace : max(Pts_Tmp(:,1)) +0.1 ;
%         ymg = min(Pts_Tmp(:,2)) -0.1 : PointSpace : max(Pts_Tmp(:,2)) +0.1;
%         [XXmg , YYmg] = meshgrid(xmg,ymg);
%         in = inpolygon(XXmg(:),YYmg(:),Pts_Tmp(:,1),Pts_Tmp(:,2));
%         Iin = find(in, 1);
%         if ~isempty(Iin)
%             i = j+1;
%             j=i+length(find(in))-1;
%             TPLayerPts(i:j,:) = transpose([Xel Yel Ztp]*[XXmg(in),YYmg(in),ones(length(find(in)),1)*alt]');
%         end
%     end
%     
% end
% 
% TPLayerPts(j+1:end,:) = [];
% 
% [V,~] = eig(cov(TPLayerPts));
% 
% Xtp = V(:,2); Ytp = V(:,3);
% Xtp = sign(Xtp'*Y0)*Xtp;
% Ytp = sign(Ytp'*Y0)*Ytp;
% 
% idx = kmeans(TPLayerPts,2);
% 
% [ CenterMed ] = ProjectOnPlan( mean(TPLayerPts(idx==1,:)) , Ztp , d );
% [ CenterLat ] = ProjectOnPlan( mean(TPLayerPts(idx==2,:)) , Ztp , d );
% 
% CenterKnee = 0.5*( CenterMed + CenterLat);
% 
Zmech = CenterKnee - CenterAnkleInside; Zmech = Zmech' / norm(Zmech);


% Final ACS
Xend = cross(Ytp,Zmech)/norm(cross(Ytp,Zmech));
Yend = cross(Zmech,Xend);

Xend = sign(Xend'*Y0)*Xend;
Yend = sign(Yend'*Y0)*Yend;
Zend = Zmech;
Xend = cross(Yend,Zend);

Vend = [Xend Yend Zend];

% Result write
Results.tech3.CenterAnkle = CenterAnkle;
Results.tech3.CenterKnee = CenterKnee;
Results.tech3.Z0 = Z0;
Results.tech3.Ztp = Ztp;
Results.tech3.Ytp = Ytp;
Results.tech3.Xtp = Xtp;
Results.tech3.Xend = Xend;
Results.tech3.Yend = Yend;
Results.tech3.Zend = Zend;
Results.tech3.V = Vend;
Results.tech3.Name='ArtSurfPIA';

%% Technic 4 fitted,Ellipse at the the largest area and 1st PIA. Kai 2014 JoB
Alt = AltAtMax-0.6:0.05:AltAtMax+0.6;
Area=[];
for d = Alt
    [ ~ , Area(end+1), ~ ] = TriPlanIntersect( ProxTib.Points, ProxTib.ConnectivityList, Z0 , d );
end

AltAtMax = Alt(Area==max(Area));
[ Curves , ~, ~ ] = TriPlanIntersect( ProxTib.Points, ProxTib.ConnectivityList, Z0 , AltAtMax );

PtsCurves = vertcat(Curves(:).Pts)*V_all;

FittedEllipse = fit_ellipse( PtsCurves(:,2),PtsCurves(:,3));

CenterEllipse = transpose(V_all*[mean(PtsCurves(:,1));FittedEllipse.X0_in;FittedEllipse.Y0_in]);

YElpsMax = V_all*[0;cos(FittedEllipse.phi);-sin(FittedEllipse.phi)]; YElpsMax = sign(Y0'*YElpsMax)*YElpsMax;
% XElpsMax = V_all*[0;sin(FittedEllipse.phi);cos(FittedEllipse.phi)];

EllipsePts = transpose(V_all*[ones(length(FittedEllipse.data),1)*PtsCurves(1) FittedEllipse.data']');

% Zend = CenterEllipse - CenterAnkleInside; Zend = Zend'/norm(Zend);
Zend = Z0;
Xend = cross(YElpsMax,Zend)/norm(cross(YElpsMax,Zend));
Yend = cross(Zend,Xend); Yend = Yend / norm(Yend);

Yend = sign(Yend'*Y0)*Yend; Yend = Yend / norm(Yend);
Xend = cross(Yend,Zend);

% Result write
Results.Kai.CenterAnkle = CenterAnkleInside;
Results.Kai.CenterKnee = CenterEllipse;
Results.Kai.YElpsMax = YElpsMax;
Results.Kai.Xend = Xend;
Results.Kai.Yend = Yend  
Results.Kai.Zend = Zend;
Results.Kai.V = [Xend Yend Zend];
Results.Kai.ElpsPts = EllipsePts; 




%% Inertia Results

Yi = V_all(:,2); Yi = sign(Yi'*Y0)*Yi;
Xi = cross(Yi,Z0);


Results.CenterAnkle1 = CenterAnkle;
Results.CenterAnkle2 = CenterAnkleInside;
Results.CenterAnkle3 = CenterAnkle3;
Results.Zinertia = Z0;
Results.Yinertia = Yi;
Results.Xinertia = Xi;
Results.Minertia = [Xi Yi Z0];


end


function [ CSs, TrObjects ] = RFemurFun( DistFem , ProxFem)
%Fit an ACS on a femur composed of the distal femur and the femoral head

% coordinate system structure to store results
CSs = struct();

% if this is an entire femur then cut it in two parts
if ~exist('ProxFem','var')
      [ProxFem, DistFem] = cutLongBoneMesh(DistFem);
end

%% Get initial Coordinate system and volumetric center
% join two parts in one triangulation
Femur = TriUnite(DistFem,ProxFem);

% Get eigen vectors V_all of the Femur 3D geometry and volumetric center
[ V_all, CenterVol ] = TriInertiaPpties( Femur );

% Initial estimate of the Distal-to-Proximal (DP) axis Z0
% Check that the distal femur is 'below' the proximal femur,
% invert Z0 direction otherwise
Z0 = V_all(:,1);
Z0 = sign((mean(ProxFem.Points)-mean(DistFem.Points))*Z0)*Z0;

% store approximate Z direction and centre of mass of triangulation
CSs.Z0 = Z0;
CSs.CenterVol = CenterVol;

%% Find Femoral Head Center
CSs = findFemoralHead(ProxFem, CSs);

%% Distal Femur Analysis
% this cell shortens the shaft, separating diaphysis and epiphysis.

% First 0.5 mm in Start and End are not accounted for, for stability.
Alt = linspace( min(DistFem.Points*Z0)+0.5 ,max(DistFem.Points*Z0)-0.5, 100);
Area= zeros(size(Alt));
i=0;
for d = -Alt
    i = i + 1;
    [ ~ , Area(i), ~ ] = TriPlanIntersect(DistFem, Z0 , d );
end
[~ , Zepi, ~] = FitCSA(Alt, Area);
ElmtsEpi = find(DistFem.incenter*Z0<Zepi);
EpiFem = TriReduceMesh( DistFem, ElmtsEpi);

% % quick check to see what's going on
% subplot(1,2,1); quickPlotTriang(DistFem);title('distal femur')
% subplot(1,2,2); quickPlotTriang(EpiFem);title('epiFem')

%% Analyze epiphysis to traces of condyles (lines running on them - plots)
% extracts:
% * ind of points on condyles
% * well oriented M-L axes joining these points
% * Orientations ?
[IdCdlPts, U_Axes, Orientation] = processFemoralEpiPhysis(EpiFem, CSs, V_all);

% Assign Points on Lateral or Medial Condyles
if Orientation < 0
    IdxPtsCondylesLat = IdCdlPts(:,1);
    IdxPtsCondylesMed = IdCdlPts(:,2);
else
    IdxPtsCondylesMed = IdCdlPts(:,1);
    IdxPtsCondylesLat = IdCdlPts(:,2);
end

% These are points, almost lines that "walk" on the condyles
PtsCondylesMed = EpiFem.Points(IdxPtsCondylesMed,:);
PtsCondylesLat = EpiFem.Points(IdxPtsCondylesLat,:);

% % debugging plots
% quickPlotTriang(EpiFem);title('epiFem'); hold on
% plot3(PtsCondylesLat(:,1), PtsCondylesLat(:,2), PtsCondylesLat(:,3),'ko');
% plot3(PtsCondylesLat(:,1), PtsCondylesLat(:,2), PtsCondylesLat(:,3),'k-', 'Linewidth', 3);
% axis equal; hold on
% plot3(PtsCondylesMed(:,1), PtsCondylesMed(:,2), PtsCondylesMed(:,3),'ro');
% plot3(PtsCondylesMed(:,1), PtsCondylesMed(:,2), PtsCondylesMed(:,3),'r-', 'Linewidth', 3);
% axis equal

%% Construct a new temporary Coordinate system with a new ML axis guess
% The intercondyle distance being larger posteriorly the mean center of
% 50% longest edges connecting the condyles is located posteriorly :
PtPosterCondyle = mean( 1/2 * EpiFem.Points(IdCdlPts(1:ceil(end/2),1),:)+...
    1/2 * EpiFem.Points(IdCdlPts(1:ceil(end/2),2),:));

% 2nd ACS guess
Y1 = normalizeV( (sum(U_Axes,1))' );
X1 = normalizeV( cross(Y1,Z0) );
Z1 = cross(X1,Y1);
VC = [X1 Y1 Z1];

% stored for use in functions
CSs.Y1 = Y1;

% Select Post Condyle points :
% Med & Lat Points is the most distal-Posterior on the condyles
X1 = sign((mean(EpiFem.Points)-PtPosterCondyle)*X1)*X1;
U =  normalizeV( 3*Z0 - X1 );

% Add ONE point (top one) on each proximal edges of each condyle that might
% have been excluded from the initial selection
PtMedTopCondyle = getFemoralCondyleMostProxPoint(EpiFem, CSs, PtsCondylesMed, U);
PtLatTopCondyle = getFemoralCondyleMostProxPoint(EpiFem, CSs, PtsCondylesLat, U);

% % [LM] plotting for debugging
% plot3(PtMedTopCondyle(:,1), PtMedTopCondyle(:,2), PtMedTopCondyle(:,3),'go');
% plot3(PtLatTopCondyle(:,1), PtLatTopCondyle(:,2), PtLatTopCondyle(:,3),'go');

%% Separate medial and lateral condyles points
% The middle point of all edges connecting the condyles is
% located distally :
PtMiddleCondyle = mean( 1/2 * EpiFem.Points(IdCdlPts(:,1),:) + ...
    1/2 * EpiFem.Points(IdCdlPts(:,2),:));

% Identify condyles points by fitting an ellipse on Long Convexhull
% edges extremities
Pt_AxisOnSurf_proj = PtMiddleCondyle*VC ;

Epiphysis_Pts_DF_2D_RC = EpiFem.Points*VC ;
%   Pts_Proj_C = Epiphysis_Pts_DF_2D_RC(IdxPtsCondylesLat,:);

% Lateral Condyles
Pts_Proj_CLat = [PtsCondylesLat;PtLatTopCondyle;PtLatTopCondyle]*VC;
C1_Pts_DF_2D_RC = Epiphysis_Pts_DF_2D_RC(...
    Epiphysis_Pts_DF_2D_RC(:,2)-Pt_AxisOnSurf_proj(2)<0,:);

PtsCondyle_Lat = transpose(VC*PtsOnCondylesFemur( Pts_Proj_CLat , C1_Pts_DF_2D_RC ,10, 0.6)');
Pts_0_C1 = transpose(VC*Pts_Proj_CLat');

% Medial Condyles
Pts_Proj_CMed = [PtsCondylesMed;PtMedTopCondyle;PtMedTopCondyle]*VC;
C2_Pts_DF_2D_RC = Epiphysis_Pts_DF_2D_RC(...
    Epiphysis_Pts_DF_2D_RC(:,2)-Pt_AxisOnSurf_proj(2)>0,:);

PtsCondyle_Med = transpose(VC*PtsOnCondylesFemur( Pts_Proj_CMed , C2_Pts_DF_2D_RC ,25, 0.6)');
Pts_0_C2 = transpose(VC*Pts_Proj_CMed');

% Select notch point :
% Notch Points is the most distal-anterior point wich normal points
% posterior-distally
PtsCondyle = [PtsCondyle_Lat;PtsCondyle_Med];
X1 = sign((mean(EpiFem.Points)-mean(PtsCondyle))*X1)*X1;
U =  normalizeV( -Z0 - 3*X1 );
NodesOk = EpiFem.Points(EpiFem.vertexNormal*U>0.98,:);

U =  normalizeV( Z0 - 3*X1 );
[~,IMax] = min(NodesOk*U);
PtNotch = NodesOk(IMax,:);

% Delete Points that are anterior to Notch
PtsCondyle_Lat(PtsCondyle_Lat*X1>PtNotch*X1,:)=[];
Pts_0_C1(Pts_0_C1*X1>PtNotch*X1,:)=[];

PtsCondyle_Med(PtsCondyle_Med*X1>PtNotch*X1,:)=[];
Pts_0_C2(Pts_0_C2*X1>PtNotch*X1,:)=[];

%% Fit the Cylinder on the Femur Condyles

% Filter Lat condyles art surface with curvature and normal orientation
Condyle_1_end = filterFemoralCondyleSurf(EpiFem, CSs, PtsCondyle_Lat, Pts_0_C1);

% Filter Med condyles art surface
Condyle_2_end = filterFemoralCondyleSurf(EpiFem, CSs, PtsCondyle_Med, Pts_0_C2);


%% Fit 2 Spheres on AS Technic
[Center1,Radius1] = sphereFit(Condyle_1_end.Points);
[Center2,Radius2] = sphereFit(Condyle_2_end.Points);
PtsCondyle = [Condyle_1_end.Points;Condyle_2_end.Points];

Axe0 = transpose(Center1 - Center2);
Center0 = transpose(0.5*Center1 + 0.5*Center2);
Radius0 = 0.5*Radius1 + 0.5*Radius2;

Ysph =  normalizeV( Axe0 );
Ysph = sign(Ysph'*Y0)*Ysph;

KneeCenterSph = Center0;

Zend_sph =  normalizeV( CenterFH' - KneeCenterSph );
Xend_sph =  normalizeV( cross(Ysph,Zend_sph) );
Yend_sph = cross(Zend_sph,Xend_sph);

% Write Found ACS
CSs.PCS.Ysph = Ysph;
CSs.PCS.Origin = KneeCenterSph;
CSs.PCS.X = Xend_sph;
CSs.PCS.Y = Yend_sph;
CSs.PCS.Z = Zend_sph;

%% Fit Cylinder on articular surface and get center
% Fit the condyles with a cylinder
[x0n, an, rn] = lscylinder(PtsCondyle, Center0, Axe0, Radius0, 0.001, 0.001);
Y2 =  normalizeV( an );

% Get the center as the middle point between the center of each condyle AS
% projected onto the cylinder axis.
PptiesLat = TriMesh2DProperties( Condyle_1_end );
CenterPtsLat = PptiesLat.Center;

PptiesMed = TriMesh2DProperties( Condyle_2_end );
CenterPtsMed = PptiesMed.Center;

OnAxisPtLat = x0n' + ((CenterPtsLat-x0n')*Y2) * Y2';
OnAxisPtMed = x0n' + ((CenterPtsMed-x0n')*Y2) * Y2';

Pt_Knee = 0.5*OnAxisPtLat + 0.5*OnAxisPtMed;

% Alternative way to define the CS origin ?
% Define the Knee point by using the range of the articular surfaces
%   projected on the articular surfaces
PtsCondyldeOnCylAxis = bsxfun(@plus,(bsxfun(@minus,PtsCondyle,x0n')*Y2)*Y2',x0n');
[~,Itmp] = min(PtsCondyldeOnCylAxis*Y2) ; Pt_tmp = PtsCondyldeOnCylAxis(Itmp,:);
Pt_Knee0 = Pt_tmp + range(PtsCondyldeOnCylAxis*Y2)/2*Y2';%(mean(PtsCondyldeOnCylAxis*Y2) - minTmp)
Z2 =  normalizeV( Z0 - Z0'*Y2*Y2 );
Pt_Knee0 = Pt_Knee0 - rn*Z2';

% Final steps to construct direct ACS
Zmech =  normalizeV( CenterFH - Pt_Knee );

Xend =  normalizeV( cross(Y2,Zmech) );
Yend = cross(Zmech,Xend);
Yend = sign(Yend'*Yend_sph)*Yend;
Zend = Zmech;
Xend = cross(Yend,Zend);
VFem = [Xend Yend Zend];

% Write Found ACS
CSs.PCC.YCvxHull = Y1;
CSs.PCC.Ycyl = Y2;
CSs.PCC.Ptcyl = x0n;
CSs.PCC.Rcyl = rn;
CSs.PCC.Rangecyl = range(PtsCondyldeOnCylAxis*Y2);
CSs.PCC.Origin = Pt_Knee;
CSs.PCC.CenterKneeRange = Pt_Knee0;
CSs.PCC.X = Xend;
CSs.PCC.Y = Yend;
CSs.PCC.Z = Zend;
CSs.PCC.V = VFem;

%% Ellipsoid Technic

% Identify on condyles points by fitting an ellipse on Long Convexhull
% edges extremities
Pt_AxisOnSurf_proj = PtMiddleCondyle*VC ;

Epiphysis_Pts_DF_2D_RC = EpiFem.Points*VC ;
%     Pts_Proj_C = Epiphysis_Pts_DF_2D_RC(IdxPtsCondylesLat,:);

% Lateral Condyles
Pts_Proj_CLat = [PtsCondylesLat;PtLatTopCondyle;PtLatTopCondyle]*VC;
C1_Pts_DF_2D_RC = Epiphysis_Pts_DF_2D_RC(...
    Epiphysis_Pts_DF_2D_RC(:,2)-Pt_AxisOnSurf_proj(2)<0,:);
PtsCondyle_Lat = transpose(VC*PtsOnCondylesFemur( Pts_Proj_CLat , C1_Pts_DF_2D_RC ,70, 0.8)');

% Medial Condyles
Pts_Proj_CMed = [PtsCondylesMed;PtMedTopCondyle;PtMedTopCondyle]*VC;
C2_Pts_DF_2D_RC = Epiphysis_Pts_DF_2D_RC(...
    Epiphysis_Pts_DF_2D_RC(:,2)-Pt_AxisOnSurf_proj(2)>0,:);
PtsCondyle_Med = transpose(VC*PtsOnCondylesFemur( Pts_Proj_CMed , C2_Pts_DF_2D_RC ,85, 0.8)');

% Smooth Results
[ Condyle_1 ] = TriReduceMesh( EpiFem, [], PtsCondyle_Lat );
Condyle_1 = TriCloseMesh(EpiFem,Condyle_1,5);
Condyle_1 = TriOpenMesh(EpiFem,Condyle_1,15);


[ Condyle_2 ] = TriReduceMesh( EpiFem, [], PtsCondyle_Med );
Condyle_2 = TriCloseMesh(EpiFem,Condyle_2,5);
Condyle_2 = TriOpenMesh(EpiFem,Condyle_2,15);

center1 = ellipsoid_fit( Condyle_1.Points , '' );

center2 = ellipsoid_fit( Condyle_2.Points , '' );

Yelpsd =  normalizeV( center2-center1 );
Yelpsd = sign(Yelpsd'*Y0)*Yelpsd;

KneeCenterElpsd = 0.5*center2 + 0.5*center1;

Zend_elpsd =  normalizeV( CenterFH - KneeCenterElpsd');
Xend_elpsd =  normalizeV( cross(Yelpsd,Zend_elpsd) );
Yend_elpsd = cross(Zend_elpsd,Xend_elpsd);
Yend_elpsd = sign(Yend_elpsd'*Yend_sph)*Yend_elpsd;
Xend_elpsd = cross(Yend_elpsd,Zend_elpsd);


% Result write
CSs.CE.Yelpsd = Yelpsd;
CSs.CE.Origin = KneeCenterElpsd;
CSs.CE.X = Xend_elpsd;
CSs.CE.Y = Yend_elpsd;
CSs.CE.Z = Zend_elpsd;

%% Results General
CSs.PtNotch = PtNotch;
CSs.Xinertia = sign(V_all(:,3)'*Xend)*V_all(:,3);
CSs.Yinertia = sign(V_all(:,2)'*Yend)*V_all(:,2);
CSs.Zinertia = Z0;
CSs.Minertia = [CSs.Xinertia,CSs.Yinertia,Z0];

%% Output triangulation objects
if nargout>1
    TrObjects = struct();
    TrObjects.Femur = Femur;
    
    TrObjects.ProxFem = ProxFem;
    TrObjects.DistFem = DistFem;
    
    TrObjects.FemHead = FemHead;
    
    TrObjects.EpiFem = EpiFem;
    
    TrObjects.EpiFemASLat = Condyle_1_end;
    TrObjects.EpiFemASMed = Condyle_2_end;
end

end


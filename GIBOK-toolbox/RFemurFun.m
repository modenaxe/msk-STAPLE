function [ CSs, TrObjects ] = RFemurFun( DistFem , ProxFem)

%TODO: change _1 and _2 in lateral and medial 
% coordinate system structure to store results
CSs = struct();

% if this is an entire femur then cut it in two parts
if ~exist('ProxFem','var')
      [ProxFem, DistFem] = cutLongBoneMesh(DistFem);
end

% join two parts in one triangulation
Femur = TriUnite(DistFem,ProxFem);

%% Initial Coordinate system (from inertial axes + HJC)
% The reference system:
%-------------------------------------
% Z0: points upwards (inertial axis) 
% Y0: points posteriorly (from OT and Z0 in findFemoralHead.m)
% X0: unused
%-------------------------------------

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

% Find Femoral Head Center
% NB adds a CSs.Y0, pointing A-P direction POSTERIORLY directed
CSs = findFemoralHead(ProxFem, CSs);

%% Isolates the epiphysis
% Operations:
% 1. shortens the shaft and removes points too distal

% First 0.5 mm in Start and End are not accounted for, for stability.
Alt = linspace( min(DistFem.Points*Z0)+0.5 ,max(DistFem.Points*Z0)-0.5, 100);
Area= zeros(size(Alt));
it=0;
for d = -Alt
    it = it + 1;
    [ ~ , Area(it), ~ ] = TriPlanIntersect(DistFem, Z0 , d );
end
% removes mesh above the limit of epiphysis (Zepi)
[~ , Zepi, ~] = FitCSA(Alt, Area);
ElmtsEpi = find(DistFem.incenter*Z0<Zepi);
EpiFem = TriReduceMesh( DistFem, ElmtsEpi);

% debugging plot
% subplot(1,2,1); quickPlotTriang(DistFem);title('distal femur')
% subplot(1,2,2); quickPlotTriang(EpiFem);title('epiFem')

%% Analyze epiphysis to traces of condyles (lines running on them - plots)
% extracts:
% * ind of points on condyles (lines running on them)
% * well oriented M-L axes joining these points
% * med_lat_ind: indices [1,2] or [2, 1]. 1st comp is medial cond, 2nd lateral.
%============
% PARAMETERS
%============
edge_threshold = 0.5; % used also for new coord syst below
axes_dev_thresh = 0.75;
%============

[IdCdlPts, U_Axes, med_lat_ind] = processFemoralEpiPhysis(EpiFem, CSs, V_all,...
                                  edge_threshold, axes_dev_thresh);

% Assign indices of points on Lateral or Medial Condyles Variable
% These are points, almost lines that "walk" on the condyles
PtsCondylesMed = EpiFem.Points(IdCdlPts(:,med_lat_ind(1)),:);
PtsCondylesLat = EpiFem.Points(IdCdlPts(:,med_lat_ind(2)),:);

% % debugging plots
% quickPlotTriang(EpiFem);title('epiFem'); hold on
% plot3(PtsCondylesLat(:,1), PtsCondylesLat(:,2), PtsCondylesLat(:,3),'ko');
% plot3(PtsCondylesLat(:,1), PtsCondylesLat(:,2), PtsCondylesLat(:,3),'k-', 'Linewidth', 3);
% axis equal; hold on
% plot3(PtsCondylesMed(:,1), PtsCondylesMed(:,2), PtsCondylesMed(:,3),'ro');
% plot3(PtsCondylesMed(:,1), PtsCondylesMed(:,2), PtsCondylesMed(:,3),'r-', 'Linewidth', 3);
% axis equal

%% New temporary coordinate system (new ML axis guess)
% The reference system:
%-------------------------------------
% Y1: based on U_Axes (MED-LAT??)
% X1: cross(Y1, Z0), with Z0 being the upwards inertial axis
% Z1: cross product of prev
%-------------------------------------
Y1 = normalizeV( (sum(U_Axes,1))' );
X1 = normalizeV( cross(Y1,Z0) );
Z1 = cross(X1,Y1);
VC = [X1 Y1 Z1];

% stored for use in functions
CSs.Y1 = Y1;

% The intercondyle distance being larger posteriorly the mean center of
% 50% longest edges connecting the condyles is located posteriorly.
% NB edge threshold is customizable!
n_in = ceil(size(IdCdlPts,1)*edge_threshold);
PtPosterCondyle = mean(0.5*(PtsCondylesMed(1:n_in,:)+PtsCondylesLat(1:n_in,:)));

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
PtMiddleCondyle         = mean(0.5*(PtsCondylesMed+PtsCondylesLat));

% transformations on the new refernce system: x_n = (R*x')'=x*R' [TO CHECK]
Pt_AxisOnSurf_proj      = PtMiddleCondyle*VC; % middle point
Epiphysis_Pts_DF_2D_RC  = EpiFem.Points*VC; % distal femur
Pts_Proj_CLat           = [PtsCondylesLat;PtLatTopCondyle;PtLatTopCondyle]*VC;
Pts_Proj_CMed           = [PtsCondylesMed;PtMedTopCondyle;PtMedTopCondyle]*VC;

Pts_0_C1                = Pts_Proj_CLat*VC';
Pts_0_C2                = Pts_Proj_CMed*VC';

% divides the epiphesis in med and lat based on where they stand wrt the
% midpoint identified above
C1_Pts_DF_2D_RC = Epiphysis_Pts_DF_2D_RC(Epiphysis_Pts_DF_2D_RC(:,2)-Pt_AxisOnSurf_proj(2)<0,:);
C2_Pts_DF_2D_RC = Epiphysis_Pts_DF_2D_RC(Epiphysis_Pts_DF_2D_RC(:,2)-Pt_AxisOnSurf_proj(2)>0,:);

% Identify condyles points (posterior part) by fitting an ellipse on 
% long convexhull edges extremities
%============
% PARAMETERS
%============
CutAngle_Lat = 10; 
CutAngle_Med = 25;
InSetRatio = 0.6;
%============
PtsCondyle_Lat = PtsOnCondylesFemur( Pts_Proj_CLat , C1_Pts_DF_2D_RC ,CutAngle_Lat, InSetRatio)*VC';
PtsCondyle_Med = PtsOnCondylesFemur( Pts_Proj_CMed , C2_Pts_DF_2D_RC ,CutAngle_Med, InSetRatio)*VC';
%============
% % plots the midpoint of all edges
% plot3(Pt_AxisOnSurf_proj(1), Pt_AxisOnSurf_proj(2), Pt_AxisOnSurf_proj(3),'ko', 'Linewidth', 5); axis equal; hold on
% % plots condiles split in medial and lateral
% plot3(C1_Pts_DF_2D_RC(:,1), C1_Pts_DF_2D_RC(:,2),C1_Pts_DF_2D_RC(:,3),'g*'); axis equal; hold on
% plot3(C2_Pts_DF_2D_RC(:,1), C2_Pts_DF_2D_RC(:,2),C2_Pts_DF_2D_RC(:,3),'b*'); axis equal; hold on
% % plots medial and lateral posterior surface on the VC ref system
% plot3(PtsCondyle_Lat(:,1), PtsCondyle_Lat(:,2),PtsCondyle_Lat(:,3),'g.'); axis equal; hold on
% plot3(PtsCondyle_Med(:,1), PtsCondyle_Med(:,2),PtsCondyle_Med(:,3),'b.'); axis equal; hold on
% plot3(PtMiddleCondyle(1), PtMiddleCondyle(2), PtMiddleCondyle(3),'ro', 'Linewidth', 5); axis equal; hold on
% plot3(Pts_0_C1(:,1), Pts_0_C1(:,2),Pts_0_C1(:,3),'rs', 'Linewidth', 5); axis equal; hold on

% Identify notch point as the most distal-anterior point with normal points
% posterior-distally
PtsCondyle = [PtsCondyle_Lat; PtsCondyle_Med];
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

% Filter Lat condyles art surface with curvature and normal orientation so
% that only the posterior part remains
Condyle_1_end = filterFemoralCondyleSurf(EpiFem, CSs, PtsCondyle_Lat, Pts_0_C1);

% Filter Med condyles art surface with curvature and normal orientation so
% that only the posterior part remains
Condyle_2_end = filterFemoralCondyleSurf(EpiFem, CSs, PtsCondyle_Med, Pts_0_C2);


%% Fit 2 Spheres on AS Technic
% function fit_spheres(Condyle_1_end, Condyle_2_end)

[Center1,Radius1] = sphereFit(Condyle_1_end.Points); %lat
[Center2,Radius2] = sphereFit(Condyle_2_end.Points); %med

%============= to remove =======================
Axe0 = transpose(Center1-Center2);
Center0 = transpose(0.5*Center1 + 0.5*Center2);
Radius0 = 0.5*Radius1 + 0.5*Radius2;
%====================================
Ysph =  normalizeV(Center1-Center2);
Ysph = sign(Ysph'*CSs.Y0)*Ysph;

KneeCenterSph = 0.5*(Center1+Center2);

Zend_sph =  normalizeV( CSs.CenterFH - KneeCenterSph );
Xend_sph =  normalizeV( cross(Ysph,Zend_sph) );
Yend_sph = cross(Zend_sph, Xend_sph);

% Write Found ACS
CSs.PCS.Ysph = Ysph;
CSs.PCS.Origin = KneeCenterSph;
CSs.PCS.X = Xend_sph;
CSs.PCS.Y = Yend_sph;
CSs.PCS.Z = Zend_sph;
% end
%% Fit Cylinder on articular surface and get center
% Fit the condyles with a cylinder
PtsCondyle = [Condyle_1_end.Points;Condyle_2_end.Points];
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
Zmech =  normalizeV( CSs.CenterFH - Pt_Knee );

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
Yelpsd = sign(Yelpsd'*CSs.Y0)*Yelpsd;

KneeCenterElpsd = 0.5*center2 + 0.5*center1;

Zend_elpsd =  normalizeV( CSs.CenterFH - KneeCenterElpsd');
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
    
%     TrObjects.FemHead = CSs.FemHead;
    TrObjects.FemHead = CSs.CenterFH;
    
    TrObjects.EpiFem = EpiFem;
    
    TrObjects.EpiFemASLat = Condyle_1_end;
    TrObjects.EpiFemASMed = Condyle_2_end;
end

end


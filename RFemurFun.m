function [ CSs, TrObjects ] = RFemurFun( DistFem , ProxFem)
%Fit an ACS on a femur composed of the distal femur and the femoral head

addpath(genpath(strcat(pwd,'/SubFunctions')));
CSs = struct();

%% Get initial Coordinate system and volumetric center

Femur = TriUnite(DistFem,ProxFem);

% Get eigen vectors V_all of the Femur 3D geometry and volumetric center
[ V_all, CenterVol ] = TriInertiaPpties( Femur );


% Initial estimate of the Distal-to-Proximal (DP) axis Z0
% Check that the distal tibia is 'below' the proximal tibia,
% invert Z0 direction otherwise
Z0 = V_all(:,1);
Z0 = sign((mean(ProxFem.Points)-mean(DistFem.Points))*Z0)*Z0;

CSs.Z0 = Z0;
CSs.CenterVol = CenterVol;

%% Find Femur Head Center

% Find the most proximal on femur top head
[~ , I_Top_FH] = max( ProxFem.incenter*Z0 );
I_Top_FH = [I_Top_FH ProxFem.neighbors(I_Top_FH)];
Face_Top_FH = TriReduceMesh(ProxFem,I_Top_FH);
[ Patch_Top_FH ] = TriDilateMesh( ProxFem ,Face_Top_FH , 40 );

% Get an initial ML Axis Y0
OT = mean(Patch_Top_FH.Points)' - CenterVol;
Y0 = normalizeV(  cross(cross(Z0,OT),Z0)  );

% Find a the most medial (MM) point on the femoral head (FH)
[~ , I_MM_FH] = max( ProxFem.incenter*Y0 );
I_MM_FH = [I_MM_FH ProxFem.neighbors(I_MM_FH)];
Face_MM_FH = TriReduceMesh(ProxFem,I_MM_FH);
[ Patch_MM_FH ] = TriDilateMesh( ProxFem ,Face_MM_FH , 40 );

FemHead0 = TriUnite(Patch_MM_FH,Patch_Top_FH);

% Initial sphere fit
[~,Radius] = sphereFit(FemHead0.Points);
[ FemHead1] = TriDilateMesh( ProxFem ,FemHead0 , round(1.5*Radius) );
[CenterFH,Radius] = sphereFit(FemHead1.Points);

CSs.CenterFH0 = CenterFH;

% Theorial Normal of the face
CPts_PF_2D  = bsxfun(@minus,FemHead1.incenter,CenterFH);
normal_CPts_PF_2D = CPts_PF_2D./repmat(sqrt(sum(CPts_PF_2D.^2,2)),1,3);

% Keep points that display a less than 10° difference between the actual
% normals and the sphere simulated normals &
Cond1 = sum((normal_CPts_PF_2D.*FemHead1.faceNormal),2)>0.975 ;
% Delete points far from sphere surface outside [90%*Radius 110%*Radius]
Cond2 = abs(sqrt(sum(bsxfun(@minus,FemHead1.incenter,CenterFH).^2,2))...
    -1*Radius)<0.1*Radius ;

Face_ID_PF_2D_onSphere = find(Cond1 & Cond2);
FemHead = TriReduceMesh(FemHead1,Face_ID_PF_2D_onSphere);
FemHead = TriOpenMesh(ProxFem ,FemHead,3);

% Fit the last Sphere
[CenterFH,Radius] = sphereFit(FemHead.Points);

% Write to the results struct
CSs.CenterFH = CenterFH;
CSs.RadiusFH = Radius;

%% Distal Femur Analysis ? Separate diaphysis and epiphysis

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

%% Analyze epiphysis to extract nodes lying on the condyles
[ IdxPointsPair , Edges ] = LargestEdgeConvHull(  EpiFem.Points );
Idx_Epiphysis_Pts_DF_Slice = unique(EpiFem.freeBoundary);

i=0;
Ikept = [];

% Keep elements that are not connected to the proximal cut and that are
% longer than half of the longest Edge
while length(Ikept) ~= sum(Edges>0.5*Edges(1))
    i=i+1;
    if ~any(IdxPointsPair(i,1)==Idx_Epiphysis_Pts_DF_Slice) &&...
            ~any(IdxPointsPair(i,2)==Idx_Epiphysis_Pts_DF_Slice)
        Ikept(end+1) = i;
    end
end

%Index of nodes identified on condyles:
IdCdlPts = IdxPointsPair(Ikept,:);

% Axes vector of points pairs
Axes = EpiFem.Points(IdCdlPts(:,1),:)-EpiFem.Points(IdCdlPts(:,2),:);

I_Axes_duplicate = find(Axes*Axes(round(length(Axes)/2),:)'<0);

% Delete duplicate but inverted Axes
IdCdlPts(I_Axes_duplicate,:)=[];
Axes(I_Axes_duplicate,:)=[];
U_Axes = Axes./repmat(sqrt(sum(Axes.^2,2)),1,3);

% Make all the axes point in the Laterat -> Medial direction
Orientation = round(mean(sign(U_Axes*Y0)));
U_Axes = Orientation*U_Axes;
Axes = Orientation*Axes;


% delete if too far from inertial medio-Lat axis;
IdCdlPts(abs(U_Axes*V_all(:,2))<0.75,:) = [];
U_Axes(abs(U_Axes*V_all(:,2))<0.75,:) = [];

[ U_Axes_Good] = PCRegionGrowing(U_Axes, normalizeV( mean(U_Axes) )', 0.1);
LIA = ismember(U_Axes,U_Axes_Good,'rows');
U_Axes(~LIA,:) = [];
Axes(~LIA,:) = [];
IdCdlPts(~LIA,:) = [];

% Assign Points on Lateral or Medial Condyles
if Orientation < 0
    IdxPtsCondylesLat = IdCdlPts(:,1);
    IdxPtsCondylesMed = IdCdlPts(:,2);
else
    IdxPtsCondylesMed = IdCdlPts(:,1);
    IdxPtsCondylesLat = IdCdlPts(:,2);
end

PtsCondylesMed = EpiFem.Points(IdxPtsCondylesMed,:);
PtsCondylesLat = EpiFem.Points(IdxPtsCondylesLat,:);

%% Construct a new temporary Coordinate system with a new ML axis guess
% The intercondyle distance being larger posteriorly the mean center of
% 50% longest edges connecting the condyles is located posteriorly :
PtPosterCondyle = mean( 1/2 * EpiFem.Points(IdCdlPts(1:ceil(end/2),1),:)+...
    1/2 * EpiFem.Points(IdCdlPts(1:ceil(end/2),2),:));

% While the middle point of all edges connecting the condyles is
% located distally :
PtMiddleCondyle = mean( 1/2 * EpiFem.Points(IdCdlPts(:,1),:) + ...
    1/2 * EpiFem.Points(IdCdlPts(:,2),:));

% 2nd ACS guess
Y1 = normalizeV( (sum(U_Axes,1))' );
X1 = normalizeV( cross(Y1,Z0) );
Z1 = cross(X1,Y1);

VC = [X1 Y1 Z1];

% Select Post Condyle points :
% Med & Lat Points is the most distal-Posterior on the condyles
X1 = sign((mean(EpiFem.Points)-PtPosterCondyle)*X1)*X1;
U =  normalizeV( 3*Z0 - X1 );

% Add points on the poximal edges of each condyle that might have been
% excluded from the initial selection:
%Med
[oLSP, nMed] = lsplane(PtsCondylesMed);
dMed = -oLSP*nMed;
IonPlan = find(abs(EpiFem.Points*nMed+dMed)<2.5 & ...
    EpiFem.Points*Z0>max(PtsCondylesMed*Z0-2.5));
IonC = rangesearch(EpiFem.Points,PtsCondylesMed,7.5);
IOK = intersect(IonPlan,unique([IonC{:}]'));
[~,Imax] = max(EpiFem.vertexNormal(IOK)*U);
PtMedTopCondyle = EpiFem.Points(IOK(Imax),:);

%Lat
[oLSP, nLat] = lsplane(PtsCondylesLat);
dLat = -oLSP*nLat;
IonPlan = find(abs(EpiFem.Points*nLat+dLat)<2.5 & ...
    EpiFem.Points*Z0>max(PtsCondylesLat*Z0-2.5));
IonC = rangesearch(EpiFem.Points,PtsCondylesLat,7.5);
IOK = intersect(IonPlan,unique([IonC{:}]'));
[~,Imax] = max(EpiFem.vertexNormal(IOK)*U);
PtLatTopCondyle = EpiFem.Points(IOK(Imax),:);

%% Separate medial and lateral condyles points
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

%% Filter Lat condyles art surface with curvature and normal orientation
%-----------------
% Lateral Condyles
%-----------------
[Center1, Radius1] = sphereFit(PtsCondyle_Lat);

[ Condyle_1 ] = TriReduceMesh( EpiFem, [], PtsCondyle_Lat );
Condyle_1 = TriCloseMesh(EpiFem,Condyle_1,4);

% Get Curvature
[Cmean,Cgaussian,~,~,~,~]=TriCurvature(Condyle_1,false);
% Compute a Curvtr norm
Curvtr = sqrt(4*Cmean.^2-2*Cgaussian);

% Calculate the "probability" of a vertex to be on an edge, depends on :
% - Difference in normal orientation from fitted cylinder
% - Curvature Intensity
% - Orientation relative to Distal Proximal axis

CylPts = bsxfun(@minus,Condyle_1.Points,Center1);
Ui = (CylPts - (CylPts*Y1)*Y1');
Ui = Ui ./ repmat(sqrt(sum(Ui.^2,2)),1,3);

AlphaAngle = abs(90-rad2deg(acos(sum(Condyle_1.vertexNormal.*Ui,2))));
GammaAngle = rad2deg(acos(Condyle_1.vertexNormal*Z0));

% Sigmoids functions to compute probability of vertex to be on an edge
Prob_Edge_Angle = 1 ./ (1 + exp((AlphaAngle-50)/10));
Prob_Edge_Angle = Prob_Edge_Angle / max(Prob_Edge_Angle);

Prob_Edge_Curv =  1 ./ ( 1 + exp( - ( Curvtr - 0.25)/0.05));
Prob_Edge_Curv = Prob_Edge_Curv / max(Prob_Edge_Curv);

Prob_FaceUp = 1 ./ (1 + exp((GammaAngle-45)/15));
Prob_FaceUp = Prob_FaceUp / max(Prob_FaceUp);

Prob_Edge = 0.6*sqrt(Prob_Edge_Angle.*Prob_Edge_Curv) +...
    0.05*Prob_Edge_Curv +...
    0.15*Prob_Edge_Angle +...
    0.2*Prob_FaceUp;

Condyle_1_edges = TriReduceMesh(Condyle_1,[],find(Prob_Edge_Curv.*Prob_Edge_Angle>0.5));

Condyle_1_end = TriReduceMesh(Condyle_1,[],find(Prob_Edge<0.20));
[ Condyle_1_end ] = TriConnectedPatch( Condyle_1_end, Pts_0_C1  );
Condyle_1_end = TriCloseMesh(EpiFem,Condyle_1_end,10);
[ Condyle_1_end ] = TriKeepLargestPatch( Condyle_1_end );
[ Condyle_1_end ] = TriDifferenceMesh( Condyle_1_end , Condyle_1_edges );

%% Filter Med condyles art surface
%-------------------------
% Idem as Lateral for Medial Condyles
%-------------------------
[Center2, Radius2] = sphereFit(PtsCondyle_Med);

[ Condyle_2 ] = TriReduceMesh( EpiFem, [], PtsCondyle_Med );
Condyle_2 = TriCloseMesh(EpiFem,Condyle_2,4);

[Cmean,Cgaussian,~,~,~,~]=TriCurvature(Condyle_2,false);
Curvtr = sqrt(4*Cmean.^2-2*Cgaussian);

CylPts = bsxfun(@minus,Condyle_2.Points,Center2);
Ui = (CylPts - (CylPts*Y1)*Y1');
Ui = Ui ./ repmat(sqrt(sum(Ui.^2,2)),1,3);

AlphaAngle = abs(90-rad2deg(acos(sum(Condyle_2.vertexNormal.*Ui,2))));
GammaAngle = rad2deg(acos(Condyle_2.vertexNormal*Z0));

% Sigmoids functions to compute probability of vertex to be on an edge
Prob_Edge_Angle = 1 ./ (1 + exp((AlphaAngle-50)/10));
Prob_Edge_Angle = Prob_Edge_Angle / max(Prob_Edge_Angle);

Prob_Edge_Curv =  1 ./ ( 1 + exp( - ( Curvtr - 0.25)/0.05));
Prob_Edge_Curv = Prob_Edge_Curv / max(Prob_Edge_Curv);

Prob_FaceUp = 1 ./ (1 + exp((GammaAngle-45)/15));
Prob_FaceUp = Prob_FaceUp / max(Prob_FaceUp);

Prob_Edge = 0.6*sqrt(Prob_Edge_Angle.*Prob_Edge_Curv) +  0.05*Prob_Edge_Curv + 0.15*Prob_Edge_Angle +  0.2*Prob_FaceUp; % + 0.25*Prob_Edge_Curv; % + 0.05*Prob_Edge_Curv + 0.05*Prob_Edge_Angle;

Condyle_2_edges = TriReduceMesh(Condyle_2,[],find(Prob_Edge_Curv.*Prob_Edge_Angle>0.5));

Condyle_2_end = TriReduceMesh(Condyle_2,[],find(Prob_Edge<0.20));
[ Condyle_2_end ] = TriConnectedPatch( Condyle_2_end, Pts_0_C2  );
Condyle_2_end = TriCloseMesh(EpiFem,Condyle_2_end,10);
[ Condyle_2_end ] = TriDifferenceMesh( Condyle_2_end , Condyle_2_edges );
[ Condyle_2_end ] = TriKeepLargestPatch( Condyle_2_end );

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


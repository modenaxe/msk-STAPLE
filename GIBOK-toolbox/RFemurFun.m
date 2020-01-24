function [ CSs, TrObjects ] = RFemurFun( DistFem , ProxFem)

% TODO: use a projectOnTo.m for lines like: Pts_0_C1*X1>PtNotch*X1
% TODO: I think there is a transformation back adn forth from VC that can
% be esliminated

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
[CSs, FemHead] = findFemoralHead(ProxFem, CSs);

%% Isolates the epiphysis
% First 0.5 mm in Start and End are removed for stability.
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

%% Analyze epiphysis to traces of condyles (lines running on them - plots)
% extracts:
% * indices of points on condyles (lines running on them)
% * well oriented M-L axes joining these points
% * med_lat_ind: indices [1,2] or [2, 1]. 1st comp is medial cond, 2nd lateral.
%============
% PARAMETERS
%============
edge_threshold = 0.5; % used also for new coord syst below
axes_dev_thresh = 0.75;

[IdCdlPts, U_Axes, med_lat_ind] = processFemoralEpiPhysis(EpiFem, CSs, V_all,...
                                  edge_threshold, axes_dev_thresh);
%============
% Assign indices of points on Lateral or Medial Condyles Variable
% These are points, almost lines that "walk" on the condyles
PtsCondylesMed = EpiFem.Points(IdCdlPts(:,med_lat_ind(1)),:);
PtsCondylesLat = EpiFem.Points(IdCdlPts(:,med_lat_ind(2)),:);

% % debugging plots: plotting the lines between the points identified
% plot3(PtsCondylesLat(:,1), PtsCondylesLat(:,2), PtsCondylesLat(:,3),'ko');hold on
% plot3(PtsCondylesMed(:,1), PtsCondylesMed(:,2), PtsCondylesMed(:,3),'ro');
% N=size(PtsCondylesLat,1)*2;
% xP(1:2:N,:) = PtsCondylesLat; xP(2:2:N,:) = PtsCondylesMed;
% for n= 1:N-1
%     plot3(xP(n:n+1,1), xP(n:n+1,2), xP(n:n+1,3), 'k-', 'LineWidth', 2)
% end

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
MidPtPosterCondyle = mean(0.5*(PtsCondylesMed(1:n_in,:)+PtsCondylesLat(1:n_in,:)));

% centroid of all points in the epiphysis
MidPtEpiFem = mean(EpiFem.Points);

% Select Post Condyle points :
% Med & Lat Points is the most distal-Posterior on the condyles
X1 = sign((MidPtEpiFem-MidPtPosterCondyle)*X1)*X1;
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

%% Identify full articular surface of condyles (points)
% by fitting an ellipse on long convexhull edges extremities

%============
% PARAMETERS
%============
CutAngle_Lat = 70; 
CutAngle_Med = 85;
InSetRatio = 0.8;
ellip_dilat_fact = 0.025;
%============
% extract full condyle
PtsFullCondyle_Lat = PtsOnCondylesFemur( Pts_Proj_CLat , C1_Pts_DF_2D_RC ,...
                        CutAngle_Lat, InSetRatio, ellip_dilat_fact)*VC';
PtsFullCondyle_Med = PtsOnCondylesFemur( Pts_Proj_CMed , C2_Pts_DF_2D_RC,...
                        CutAngle_Med, InSetRatio, ellip_dilat_fact)*VC';
% Smooth Results
fullCondyle_Lat = smoothFemoralCondyles(EpiFem, PtsFullCondyle_Lat);
fullCondyle_Med = smoothFemoralCondyles(EpiFem, PtsFullCondyle_Med);

% plot3(PtsFullCondyle_Lat(:,1),PtsFullCondyle_Lat(:,2),PtsFullCondyle_Lat(:,3),'r.');hold on
% plot3(PtsFullCondyle_Med(:,1),PtsFullCondyle_Med(:,2),PtsFullCondyle_Med(:,3),'b.')
 
%% Identify posterior part of condyles (points)
% by fitting an ellipse on long convexhull edges extremities
%============
% PARAMETERS
%============
CutAngle_Lat = 10; 
CutAngle_Med = 25;
InSetRatio = 0.6;
ellip_dilat_fact = 0.025;
%============
% posterior
PtsCondyle_Lat = PtsOnCondylesFemur( Pts_Proj_CLat , C1_Pts_DF_2D_RC ,...
                        CutAngle_Lat, InSetRatio, ellip_dilat_fact)*VC';
PtsCondyle_Med = PtsOnCondylesFemur( Pts_Proj_CMed , C2_Pts_DF_2D_RC,...
                        CutAngle_Med, InSetRatio, ellip_dilat_fact)*VC';

%% Identify notch point 
% as the most distal-anterior point with normal points posterior-distally

%=========== DUPLICATED CODE =========
MidPtPosterCondyleIt2 = mean([PtsCondyle_Lat; PtsCondyle_Med]);
X1 = sign((MidPtEpiFem-MidPtPosterCondyleIt2)*X1)*X1;
U =  normalizeV( -Z0 - 3*X1 );
%======================================
NodesOk = EpiFem.Points(EpiFem.vertexNormal*U>0.98,:);
U =  normalizeV( Z0 - 3*X1 );
[~,IMax] = min(NodesOk*U);
PtNotch = NodesOk(IMax,:);

%% Generating patellar groove triangulations (med and lat)
% initial estimations of anterior patellar groove (anterior to mid point)
% (points)
ant_lat = C1_Pts_DF_2D_RC(C1_Pts_DF_2D_RC(:,1)-Pt_AxisOnSurf_proj(1)>0,:)*VC';
ant_med = C2_Pts_DF_2D_RC(C2_Pts_DF_2D_RC(:,1)-Pt_AxisOnSurf_proj(1)>0,:)*VC';
% anterior to notch (points)
PtsGroove_Lat = ant_lat(ant_lat*X1>PtNotch*X1,:);
PtsGroove_Med = ant_med(ant_med*X1>PtNotch*X1,:);
% triangulations of medial and lateral patellar groove surfaces
Groove_Lat = filterFemoralCondyleSurf(EpiFem, CSs, PtsGroove_Lat, Pts_0_C1);
Groove_Med = filterFemoralCondyleSurf(EpiFem, CSs, PtsGroove_Med, Pts_0_C1);

%% Generating posterior condyle triangulations (med and lat)
% Delete points that are anterior to Notch
PtsCondyle_Lat(PtsCondyle_Lat*X1>PtNotch*X1,:)=[];
PtsCondyle_Med(PtsCondyle_Med*X1>PtNotch*X1,:)=[];

Pts_0_C1(Pts_0_C1*X1>PtNotch*X1,:)=[];
Pts_0_C2(Pts_0_C2*X1>PtNotch*X1,:)=[];

% Filter with curvature and normal orientation to keep only the post parts
% these are triangulations
postCondyle_Lat_end = filterFemoralCondyleSurf(EpiFem, CSs, PtsCondyle_Lat, Pts_0_C1);
postCondyle_Med_end = filterFemoralCondyleSurf(EpiFem, CSs, PtsCondyle_Med, Pts_0_C2);

%% building reference systems
% Fit two spheres on articular surfaces of posterior condyles
try 
    CSs = createFemurCoordSystSpheresOnCondyles(postCondyle_Lat_end, postCondyle_Med_end, CSs);
catch EM                
    warning('Sphere fitting on posterior femoral condyles could not be performed. Please double check your mesh and error logs.');
    disp(EM.message);
end

% Fit the posterior condyles with a cylinder
try 
   CSs = createFemurCoordSystCylinderOnCondyles(postCondyle_Lat_end, postCondyle_Med_end, CSs);
catch EM                
    warning('Cylinder fitting on posterior femoral condyles could not be performed. Please double check your mesh and error logs.');
    disp(EM.message);
end

% Fit the entire condyles with an ellipsoid
try 
   CSs = createFemurCoordSystEllipsoidOnCondyles(fullCondyle_Lat, fullCondyle_Med, CSs);
catch EM                
    warning('Cylinder fitting on posterior femoral condyles could not be performed. Please double check your mesh and error logs.');
    disp(EM.message);
end

%% Store bone landmarks
CSs.PtNotch = PtNotch;

% %% Store adjusted inertial axes for output if required
% CSs.Xinertia = sign(V_all(:,3)'*Xend)*V_all(:,3);
% CSs.Yinertia = sign(V_all(:,2)'*Yend)*V_all(:,2);
% CSs.Zinertia = Z0;
% CSs.Minertia = [CSs.Xinertia,CSs.Yinertia,Z0];

%% Store triangulation objects for output if required
if nargout>1
    TrObjects = struct();
    % store triangulations
    TrObjects.Femur         = Femur; % full femur
    TrObjects.ProxFem       = ProxFem; % proximal
    TrObjects.DistFem       = DistFem; % distal
    % store pieces used throughout the processing
    TrObjects.FemHead       = FemHead;
    TrObjects.EpiFem        = EpiFem;
    TrObjects.EpiFemASLat   = postCondyle_Lat_end;
    TrObjects.EpiFemASMed   = postCondyle_Med_end;
    TrObjects.PatGrooveLat  = Groove_Lat;
    TrObjects.PatGrooveMed  = Groove_Med;
end

end


function [DesiredArtSurfMed_Tri, DesiredArtSurfLat_Tri, CSs] = femur_ArticSurf(EpiFem, CSs, CoeffMorpho, art_surface)

debug_plots = 0;
V_all = CSs.V_all;
Z0 = CSs.Z0;

switch art_surface
    case 'full_condyles'
        % Identify full articular surface of condyles (points)
        % PARAMETERS
        CutAngle_Lat = 70;
        CutAngle_Med = 85;
        InSetRatio = 0.8;
        ellip_dilat_fact = 0.025;
    case 'post_condyles'
        % Identify posterior part of condyles (points)
        % PARAMETERS
        CutAngle_Lat = 10;
        CutAngle_Med = 25;
        InSetRatio = 0.6;
        ellip_dilat_fact = 0.025;
    case 'pat_groove'
        % same as posterior
        CutAngle_Lat = 10;
        CutAngle_Med = 25;
        InSetRatio = 0.6;
        ellip_dilat_fact = 0.025;
    otherwise
end

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

[IdCdlPts, U_Axes, med_lat_ind] = femur_processEpiPhysis(EpiFem, CSs, V_all,...
                                  edge_threshold, axes_dev_thresh);
%============
% Assign indices of points on Lateral or Medial Condyles Variable
% These are points, almost lines that "walk" on the condyles
PtsCondylesMed = EpiFem.Points(IdCdlPts(:,med_lat_ind(1)),:);
PtsCondylesLat = EpiFem.Points(IdCdlPts(:,med_lat_ind(2)),:);

% % debugging plots: plotting the lines between the points identified
if debug_plots
    plot3(PtsCondylesLat(:,1), PtsCondylesLat(:,2), PtsCondylesLat(:,3),'ko');hold on
    plot3(PtsCondylesMed(:,1), PtsCondylesMed(:,2), PtsCondylesMed(:,3),'ro');
    N=size(PtsCondylesLat,1)*2;
    xP(1:2:N,:) = PtsCondylesLat; xP(2:2:N,:) = PtsCondylesMed;
    for n= 1:N-1
        plot3(xP(n:n+1,1), xP(n:n+1,2), xP(n:n+1,3), 'k-', 'LineWidth', 2)
    end
end

%% New temporary coordinate system (new ML axis guess)
% The reference system:
%-------------------------------------
% Y1: based on U_Axes (MED-LAT??)
% X1: cross(Y1, Z0), with Z0 being the upwards inertial axis
% Z1: cross product of prev
%-------------------------------------
Y1 = normalizeV( (sum(U_Axes,1))' );
X1 = normalizeV( cross(Y1, Z0) );
Z1 = cross(X1,Y1);
VC = [X1 Y1 Z1];

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
PtMedTopCondyle = femur_getCondyleMostProxPoint(EpiFem, CSs, PtsCondylesMed, U);
PtLatTopCondyle = femur_getCondyleMostProxPoint(EpiFem, CSs, PtsCondylesLat, U);

% % [LM] plotting for debugging
if debug_plots
    plot3(PtMedTopCondyle(:,1), PtMedTopCondyle(:,2), PtMedTopCondyle(:,3),'go');
    plot3(PtLatTopCondyle(:,1), PtLatTopCondyle(:,2), PtLatTopCondyle(:,3),'go');
end
%% Separate medial and lateral condyles points
% The middle point of all edges connecting the condyles is
% located distally :
PtMiddleCondyle         = mean(0.5*(PtsCondylesMed+PtsCondylesLat));

% transformations on the new refernce system: x_n = (R*x')'=x*R' [TO CHECK]
Pt_AxisOnSurf_proj      = PtMiddleCondyle*VC; % middle point
Epiphysis_Pts_DF_2D_RC  = EpiFem.Points*VC; % distal femur

% THESE TRANSFORMATION ARE INVERSE - DOESN'T MAKE MUCH SENSE [LM]
%============================
Pts_Proj_CLat           = [PtsCondylesLat;PtLatTopCondyle;PtLatTopCondyle]*VC;
Pts_Proj_CMed           = [PtsCondylesMed;PtMedTopCondyle;PtMedTopCondyle]*VC;
Pts_0_C1                = Pts_Proj_CLat*VC';
Pts_0_C2                = Pts_Proj_CMed*VC';
%============================

% divides the epiphysis in med and lat based on where they stand wrt the
% midpoint identified above
C1_Pts_DF_2D_RC = Epiphysis_Pts_DF_2D_RC(Epiphysis_Pts_DF_2D_RC(:,2)-Pt_AxisOnSurf_proj(2)<0,:);
C2_Pts_DF_2D_RC = Epiphysis_Pts_DF_2D_RC(Epiphysis_Pts_DF_2D_RC(:,2)-Pt_AxisOnSurf_proj(2)>0,:);

% Identify full articular surface of condyles (points)
% by fitting an ellipse on long convexhull edges extremities
ArticularSurface_Lat = PtsOnCondylesFemur( Pts_Proj_CLat , C1_Pts_DF_2D_RC ,...
                        CutAngle_Lat, InSetRatio, ellip_dilat_fact)*VC';
ArticularSurface_Med = PtsOnCondylesFemur( Pts_Proj_CMed , C2_Pts_DF_2D_RC,...
    CutAngle_Med, InSetRatio, ellip_dilat_fact)*VC';

% if strcmp(art_surface, 'pat_groove')
%     % same as posterior
%     CutAngle_Lat = 110;
%     CutAngle_Med = 110;
%     InSetRatio = 0.9;
%     ellip_dilat_fact = 0.4;
%     ArticularSurface_Ant_Med = PtsOnCondylesFemur( Pts_Proj_CMed , C2_Pts_DF_2D_RC,...
%         CutAngle_Med, InSetRatio, ellip_dilat_fact)*VC';
%     ArticularSurface_Ant_Lat = PtsOnCondylesFemur( Pts_Proj_CLat , C1_Pts_DF_2D_RC,...
%         CutAngle_Lat, InSetRatio, ellip_dilat_fact)*VC';
%     
%     quickPlotTriang(EpiFem); hold on
%     plot3(ArticularSurface_Med(:,1), ArticularSurface_Med(:,2),ArticularSurface_Med(:,3),'r.')
%     plot3(ArticularSurface_Ant(:,1), ArticularSurface_Ant(:,2),ArticularSurface_Ant(:,3),'r.')
%     plot3(Pts_Proj_CMed(:,1), Pts_Proj_CMed(:,2),Pts_Proj_CMed(:,3),'g.')
% end

% locate notch using updated estimation of X1
MidPtPosterCondyleIt2 = mean([ArticularSurface_Lat; ArticularSurface_Med]);
X1 = sign((MidPtEpiFem-MidPtPosterCondyleIt2)*X1)*X1;
U =  normalizeV( -Z0 - 3*X1 );
NodesOk = EpiFem.Points(EpiFem.vertexNormal*U>0.98,:);
U =  normalizeV( Z0 - 3*X1 );
[~,IMax] = min(NodesOk*U);
PtNotch = NodesOk(IMax,:);

% store geometrical elements useful externally
CSs.BL.PtNotch = PtNotch;

% stored for use in functions (cylinder ref system)
CSs.X1 = X1;
CSs.Y1 = Y1; % axis guess for cyl ref system
CSs.Z1 = Z1;

switch art_surface
    case 'full_condyles'
        % if output is full condyles then just filter and create triang
        DesiredArtSurfLat_Tri = femur_smoothCondyles(EpiFem, ArticularSurface_Lat, CoeffMorpho);
        DesiredArtSurfMed_Tri = femur_smoothCondyles(EpiFem, ArticularSurface_Med, CoeffMorpho);
        
    case 'post_condyles'
        % Delete points that are anterior to Notch
        ArticularSurface_Lat(ArticularSurface_Lat*X1>PtNotch*X1,:)=[];
        ArticularSurface_Med(ArticularSurface_Med*X1>PtNotch*X1,:)=[];
        Pts_0_C1(Pts_0_C1*X1>PtNotch*X1,:)=[];
        Pts_0_C2(Pts_0_C2*X1>PtNotch*X1,:)=[];
        
        % Filter with curvature and normal orientation to keep only the post parts
        % these are triangulations
        DesiredArtSurfLat_Tri = femur_filterCondyleSurf(EpiFem, CSs, ArticularSurface_Lat, Pts_0_C1, CoeffMorpho);
        DesiredArtSurfMed_Tri = femur_filterCondyleSurf(EpiFem, CSs, ArticularSurface_Med, Pts_0_C2, CoeffMorpho);
    case 'pat_groove'
        % Generating patellar groove triangulations (med and lat)
        % initial estimations of anterior patellar groove (anterior to mid point)
        % (points)
        ant_lat = C1_Pts_DF_2D_RC(C1_Pts_DF_2D_RC(:,1)-Pt_AxisOnSurf_proj(1)>0,:)*VC';
        ant_med = C2_Pts_DF_2D_RC(C2_Pts_DF_2D_RC(:,1)-Pt_AxisOnSurf_proj(1)>0,:)*VC';
        % anterior to notch (points)
        PtsGroove_Lat = ant_lat(ant_lat*X1>PtNotch*X1,:);
        PtsGroove_Med = ant_med(ant_med*X1>PtNotch*X1,:);
        % triangulations of medial and lateral patellar groove surfaces
        DesiredArtSurfLat_Tri = femur_filterCondyleSurf(EpiFem, CSs, PtsGroove_Lat, Pts_0_C1, CoeffMorpho);
        DesiredArtSurfMed_Tri = femur_filterCondyleSurf(EpiFem, CSs, PtsGroove_Med, Pts_0_C1, CoeffMorpho);
    otherwise
end
end
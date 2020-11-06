function [CS, TlCcnAS1, TlNvc_AS] = CS_talus_subtalarSpheres(Talus, side, CS, alt_TlNvc_start, alt_TlNeck_start, CoeffMorpho)

% get sign correspondent to body side
[sign_side, ~] = bodySide2Sign(side);

alt_TlNvc_end = max(Talus.incenter*CS.X0);
TlNvc_length = alt_TlNvc_end-alt_TlNvc_start;


% 2.2 First guess at the TlNvc articular surface (AS)
ElmtsTlNvc = find(Talus.incenter*CS.X0 > (alt_TlNvc_start+0.25*TlNvc_length));
TlNvc_AS = TriReduceMesh( Talus, ElmtsTlNvc );

% refine articular area
% the area is very large (larger than AS) unless just the -Z points are considered
% Translate the point by T
Pts_T = bsxfun(@minus , TlNvc_AS.Points , CS.CenterVol');
V = [CS.X0 CS.Y0 CS.Z0];
Pts_T_R = Pts_T * V;
ID_Pts_keep = find(Pts_T_R(:,3)<0);
TlNvc_AS_refined = bsxfun(@plus ,Pts_T_R(ID_Pts_keep, :) * V' , CS.CenterVol');
% 2.3 Fit sphere to the refine surface
[Center_TlNvc, Radius_TlNvc,~] = sphereFit(TlNvc_AS_refined);

% get an articular surface for the identified points (NB, some points will
% be eliminated to ensure triangulation, so fitting TlNvc_AS.Points will
% give SLIGHTLY different results).
TlNvc_AS = TriReduceMesh( TlNvc_AS, [], ID_Pts_keep );

% stlWrite('talo_nav_AS.stl', TlNvc_AS.ConnectivityList, TlNvc_AS.Points)
% [Center_TlNvc, Radius_TlNvc,~] = sphereFit(TlNvc_AS.Points) ;


%% 3. Identification of the talocalcaneal sphere
% Assumptions :
%   - Z0 is grossly a distalo-proximal axis oriented proximally
%   - ...
% % 3.1 plot the talus

% 3.2 Similar technique as for the tibial ankle AS 
% Get mean curvature of the Talus
[Cmean, Cgaussian, ~, ~, k1, k2] = TriCurvature(Talus,false);
% maxAbsCurv =  max(abs(k1), abs(k2));

% Estimated mean direction of the normals of the talocalcaneal surface
U1 = - CS.Z0 + 0.5*CS.Y0 - 0.4*CS.X0;
U1 = normalizeV(U1);

U2 = - CS.Z0 - 0.5*CS.Y0 - 0.3*CS.X0;
U2 = normalizeV(U2);

% First guess of the nodes that should be on the surface based on normal
% orientation relative to the estimated directions U1 and U2
TlCcnASNodesOK0 =  find(k2 > quantile(k2,0.33) &...
    (acosd(Talus.vertexNormal*U1)<30 | acosd(Talus.vertexNormal*U2)<30) &...
    Talus.Points*CS.X0<CS.CenterVol'*CS.X0 &...
    Talus.vertexNormal*CS.Z0 < 0);
TlCcnAS0 = TriReduceMesh(Talus,[],double(TlCcnASNodesOK0));
TlCcnAS0 = TriKeepLargestPatch( TlCcnAS0 ) ;

% Get the centroid of the identified points
TlCcnASCenter0 = mean(TlCcnAS0.Points);

% Select the good vector between U1 and U2
U_TlCcnASCenter0 = TlCcnASCenter0 - CS.CenterVol';
U_TlCcnASCenter0 = normalizeV(U_TlCcnASCenter0');
U1U2 = [U1, U2];
[~,i] = max(U1U2'*U_TlCcnASCenter0);
U = U1U2(:,i);

% Translate the centroid along U
TlCcnASCenter = TlCcnASCenter0 + 1.0*U';

% Theorical Normal of the face
CPts  = bsxfun(@minus, Talus.Points, TlCcnASCenter);
normal_CPts = -CPts./repmat(sqrt(sum(CPts.^2,2)),1,3);

% Second and final guess of the Talo-Calcaneal articular surface 
TlCcnASNodesOK1 =  find(k2 > quantile(k2,0.33) &...
    acosd(Talus.vertexNormal*U)<60 &...
    sum(Talus.vertexNormal.*normal_CPts,2)>0 &...
    Talus.vertexNormal*CS.Z0 < 0 &...
    Talus.Points*CS.X0 < alt_TlNeck_start);

TlCcnAS1 = TriReduceMesh(Talus, [], TlCcnASNodesOK1);
TlCcnAS1 = TriKeepLargestPatch( TlCcnAS1 ) ;
TlCcnAS1 = TriCloseMesh(Talus,TlCcnAS1,2 * CoeffMorpho);

% % Add surface to previous plot
% trisurf(TlCcnAS1,'Facecolor','c','FaceAlpha',1,'edgecolor','none');

% 3.3 Fit a sphere to approximate AS
[Center_TlCcn, Radius_TlCcn, ErrorDist] = sphereFit(TlCcnAS1.incenter) ;
% stlWrite('AS2.stl', TlCcnAS1.ConnectivityList, TlCcnAS1.Points)

%% 4. Compute the "subtalar-axis"
u_SubtalarAxis = normalizeV(Center_TlNvc-Center_TlCcn);


%% 5. Save reference system details
% these axes (IN GIBOK CONVENTIONS) are used by throcheaCylinder
CS.X1 = u_SubtalarAxis; % approx anter-post
CS.Z1 = normalizeV(cross(CS.X1,CS.Y0)) * sign_side; % attempt of adjusting for side based on debugplot
CS.Y1 = normalizeV(cross(CS.Z1,CS.X1));

% check axes in GIBOK conventions
debug_plots = 0;
if debug_plots == 1
    figure
    quickPlotTriang(Talus); hold on
    T.X=CS.X1; T.Y=CS.Y1; T.Z=CS.Z1;T.Origin=CS.CenterVol;
    quickPlotRefSystem(T)
end

% store info about talo-navicular artic surf
CS.V_subtalar = [CS.Y1 CS.Z1 CS.X1];
CS.subtalar_axis   = u_SubtalarAxis;
CS.subtalar_axis_centre = (Center_TlNvc+Center_TlCcn)/2;
CS.subtalar_axis_length = norm((Center_TlNvc-Center_TlCcn));
CS.talocalc_centre = Center_TlCcn;
CS.talocalc_radius = Radius_TlCcn;
CS.talonav_centre  = Center_TlNvc;
CS.talonav_radius  = Radius_TlNvc;

end
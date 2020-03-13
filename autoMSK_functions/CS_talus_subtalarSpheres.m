function [CS, TlCcnAS1, TlNvc_AS] = CS_talus_subtalarSpheres(Talus, CS, alt_TlNvc_start, alt_TlNeck_start)


alt_TlNvc_end = max(Talus.incenter*CS.X0);
TlNvc_length = alt_TlNvc_end-alt_TlNvc_start;


% 2.2 First guess at the TlNvc articular surface (AS)
ElmtsTlNvc = find(Talus.incenter*CS.X0 > (alt_TlNvc_start+0.25*TlNvc_length));
TlNvc_AS = TriReduceMesh( Talus, ElmtsTlNvc );

% 2.3 Fit a initial sphere on the TlNvc AS
[Center_TlNvc, Radius_TlNvc,~] = sphereFit(TlNvc_AS.Points) ;

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
TlCcnAS1 = TriCloseMesh(Talus,TlCcnAS1,2);

% % Add surface to previous plot
% trisurf(TlCcnAS1,'Facecolor','c','FaceAlpha',1,'edgecolor','none');

% 3.3 Fit a sphere to approximate AS
[Center_TlCcn, Radius_TlCcn, ErrorDist] = sphereFit(TlCcnAS1.incenter) ;


%% 4. Compute the "subtalar-axis"
u_SubtalarAxis = normalizeV(Center_TlNvc-Center_TlCcn);


%% 5. Save reference system details
% these axes (IN GIBOK CONVENTIONS) are used by throcheaCylinder
CS.X1 = u_SubtalarAxis; % approx anter-post
CS.Z1 = normalizeV(cross(CS.X1,CS.Y0));
CS.Y1 = cross(CS.Z1,CS.X1);

% store info about talo-navicular artic surf
CS.V_subtalar_r = [CS.Y1 CS.Z1 CS.X1];
CS.subtalar_axis   = u_SubtalarAxis;
CS.subtalar_axis_centre = (Center_TlNvc+Center_TlCcn)/2;
CS.subtalar_axis_length = norm((Center_TlNvc-Center_TlCcn));
CS.talocalc_centre = Center_TlCcn;
CS.talocalc_radius = Radius_TlCcn;
CS.talonav_centre  = Center_TlNvc;
CS.talonav_radius  = Radius_TlNvc;

end
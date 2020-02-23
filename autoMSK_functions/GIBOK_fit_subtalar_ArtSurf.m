function CS = GIBOK_fit_subtalar_ArtSurf(Talus)

% switch th efinal fitting plot
debug_plot = 1;
fit_debug_plot = 0;

% structure to store ref system info
CS = struct;


%% 1. Indentify the inertia axis of the Talus
% Get eigen vectors V_all of the Talus 3D geometry and volumetric center
[ V_all, CenterVol, InertiaMatrix, D ] = TriInertiaPpties( Talus );

% X0 can be seen as a initial antero-posterior or postero-anterior axis,
% the orientation of Y0 and Z0 can be inconsistent accross subjects because
% the value of their Moment of inertia are quite close (~15% difference. So
% another function is used to initiliaze Z0 and Y0. It fits a quadrilateral
% on the Talus projected onto a plan perpendicular to X0, the edge
% corresponding to the superior face is identified and provide the
% inferior-superior direction intial guess (Z0). Y0 is made perpendicular
% to X0 and Z0.
X0 = V_all(:,1); 

[Z0,Y0] = fitQuadriTalus(Talus, V_all, fit_debug_plot);

%% 2. Identification of the talonavicular sphere
% 2.1 Evolution of the cross section area (CSA) along the X0 axis 
slice_thickness = 0.3;
Alt =  min(Talus.Points*X0)+0.3 : slice_thickness : max(Talus.Points*X0)-0.3;
Area = zeros(size(Alt));
i=0;
for d = -Alt
    i = i + 1;
    [ ~ , Area(i), ~ ] = TriPlanIntersect( Talus, X0 , d );
end

% Plot the curves CSA = f(Alt), Alt : Altitude of the section along X0
% figure()
% plot(Alt,Area,'-*')

% Given the shape of the curve we can fit a bi-gaussian curve to identify
% the two maxima of the Area = f(Alt) curve
%   "or" the orientation parameter is positive if X0 is oriented from 
%   posterior to anterior and negative otherwise
%
%   alt_TlNvc_start, gives the altitude along X0 at wich the CSA is maximal
%   and where the TaloNavicular (TlNvc) articular surface could start.
%   
%   alt_TlNeck_start, gives the altitude along x0 at the approximate start
%   of talus neck
%
%   alt_TlTib_start, gives the altitude along X0 at wich articular surface
%   with the tibia can start

[or, alt_TlNvc_start, alt_TlNeck_start, alt_TlTib_start] = ...
                                                    FitCSATalus(Alt, Area);

% Change X0 orientation if necessary ( or = +/- 1 )
X0 = or*X0;
Y0 = or*Y0;
alt_TlNvc_end = max(Talus.incenter*X0);
TlNvc_length = alt_TlNvc_end-alt_TlNvc_start;


% 2.2 First guess at the TlNvc articular surface (AS)
ElmtsTlNvc = find(Talus.incenter*X0 > (alt_TlNvc_start+0.25*TlNvc_length));
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
U1 = - Z0 + 0.5*Y0 - 0.4*X0;
U1 = normalizeV(U1);

U2 = - Z0 - 0.5*Y0 - 0.3*X0;
U2 = normalizeV(U2);

% First guess of the nodes that should be on the surface based on normal
% orientation relative to the estimated directions U1 and U2
TlCcnASNodesOK0 =  find(k2 > quantile(k2,0.33) &...
    (acosd(Talus.vertexNormal*U1)<30 | acosd(Talus.vertexNormal*U2)<30) &...
    Talus.Points*X0<CenterVol'*X0 &...
    Talus.vertexNormal*Z0 < 0);
TlCcnAS0 = TriReduceMesh(Talus,[],double(TlCcnASNodesOK0));
TlCcnAS0 = TriKeepLargestPatch( TlCcnAS0 ) ;

% Get the centroid of the identified points
TlCcnASCenter0 = mean(TlCcnAS0.Points);

% Select the good vector between U1 and U2
U_TlCcnASCenter0 = TlCcnASCenter0 - CenterVol';
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
    Talus.vertexNormal*Z0 < 0 &...
    Talus.Points*X0 < alt_TlNeck_start);

TlCcnAS1 = TriReduceMesh(Talus, [], TlCcnASNodesOK1);
TlCcnAS1 = TriKeepLargestPatch( TlCcnAS1 ) ;
TlCcnAS1 = TriCloseMesh(Talus,TlCcnAS1,2);

% % Add surface to previous plot
% trisurf(TlCcnAS1,'Facecolor','c','FaceAlpha',1,'edgecolor','none');

% 3.3 Fit a sphere to approximate AS
[Center_TlCcn, Radius_TlCcn, ErrorDist] = sphereFit(TlCcnAS1.incenter) ;


%% 4. Compute the "subtalar-axis"
u_SubAxis = normalizeV(Center_TlNvc-Center_TlCcn);
length_SubAxis =  norm(Center_TlCcn-Center_TlNvc);
center_SubAxis = (Center_TlCcn+Center_TlNvc)/2;


%% 5. Save reference system details
X1 = u_SubAxis;
Z1 = normalizeV(cross(X1,Y0));
Y1 = cross(Z1,X1);

% store info about talo-navicular artic surf
CS.TaloCalc_centre = Center_TlCcn;
CS.TaloCalc_radius = Radius_TlCcn;
% store info about talo-navicular artic surf
CS.TaloNav_centre = Center_TlNvc;
CS.TaloNav_radius = Radius_TlNvc;
% ref system
CS.SubTal_axis = u_SubAxis;
CS.Origin = Center_TlCcn;
CS.Z = X1;
CS.Y = Z1;
CS.X = Y1;
CS.V = [CS.X CS.Y CS.Z];

if debug_plot
    % plot the results figure :
    %Visually check the Inertia Axis orientation relative to the Talus geometry
    figure()
    % Plot the whole talus, here Talus is a Matlab triangulation object
    trisurf(Talus,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',.7,'edgecolor','none');
    hold on
    axis equal
    
    % handle lighting of objects
    light('Position',CenterVol' + 500*Y0' + 500*X0','Style','local')
    light('Position',CenterVol' + 500*Y0' - 500*X0','Style','local')
    light('Position',CenterVol' - 500*Y0' + 500*X0' - 500*Z0','Style','local')
    light('Position',CenterVol' - 500*Y0' - 500*X0' + 500*Z0','Style','local')
    lighting gouraud
    
    % Remove grid
    grid off
    
    %Plot the inertia Axis & Volumic center
    plotDot( CenterVol', 'k', 2 )
    plotArrow( X0, 1, CenterVol, 40, 1, 'r')
    plotArrow( Y0, 1, CenterVol, 40*D(1,1)/D(2,2), 1, 'g')
    plotArrow( Z0, 1, CenterVol, 40*D(1,1)/D(3,3), 1, 'b')
    
    %Plot the Tl Nvc part
    trisurf(TlNvc_AS,'Facecolor','m','FaceAlpha',1,'edgecolor','none');
    plotSphere( Center_TlNvc, Radius_TlNvc , 'm' , 0.3)
    plotDot( Center_TlNvc, 'm', 2 )
    
    %Plot the Tl Ccn part
    trisurf(TlCcnAS1,'Facecolor','c','FaceAlpha',1,'edgecolor','none');
    plotSphere( Center_TlCcn, Radius_TlCcn , 'c' , 0.3)
    plotDot( Center_TlCcn, 'c', 2 )
    
    %Plot the axis
    plotCylinder( u_SubAxis, 0.75, center_SubAxis, length_SubAxis, 1, 'k')
    
    axis off
end

end
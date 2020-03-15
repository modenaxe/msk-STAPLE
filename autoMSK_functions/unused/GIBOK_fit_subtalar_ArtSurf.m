function SubtalarCS = GIBOK_fit_subtalar_ArtSurf(Talus, X0, Y0, debug_plot)

% structure to store ref system info
SubtalarCS = struct;

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
SubtalarCS.TaloCalc_centre = Center_TlCcn;
SubtalarCS.TaloCalc_radius = Radius_TlCcn;
% store info about talo-navicular artic surf
SubtalarCS.TaloNav_centre = Center_TlNvc;
SubtalarCS.TaloNav_radius = Radius_TlNvc;
% ref system
SubtalarCS.SubTal_axis = u_SubAxis;
SubtalarCS.Origin = Center_TlCcn;
SubtalarCS.Z = X1;
SubtalarCS.Y = Z1;
SubtalarCS.X = Y1;
SubtalarCS.V = [SubtalarCS.X SubtalarCS.Y SubtalarCS.Z];

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
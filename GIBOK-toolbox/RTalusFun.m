function [CSs, TrObjects] = RTalusFun(Talus)
% Function RTalusFun( Talus)
% Fit an ACS on a Talus
% Input : 
%   - Talus : A triangulation object of the talus
% 
% Output : 
%   - CSs : a structure containing the axis of points of the coordinate
%   system of the talus
%   - TrObjects : a structure containing the identifie region of the talus
%   that are used to identify the axis and points to construct the
%   coordinate system

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
[Z0,Y0] = fitQuadriTalus(Talus, V_all, 1);


% quickPlotTriang(Talus, V_all, CenterVol)

%% 2. Identification of the talonavicular sphere
% 2.1 Evolution of the cross section area (CSA) along the X0 axis 

Alt =  min(Talus.Points*X0)+0.3 : 0.3 : max(Talus.Points*X0)-0.3;
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

% Plot of the first guess axis orientation relative to the Talus geometry
figure()
% Plot the whole talus, here Talus is a Matlab triangulation object
trisurf(Talus,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',.8,'edgecolor','none');
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
plotArrow( X0, 1, CenterVol, 40, 0.5, 'r')
plotArrow( Y0, 1, CenterVol, 40*D(1,1)/D(2,2), 0.5, 'g')
plotArrow( Z0, 1, CenterVol, 40*D(1,1)/D(3,3), 0.5, 'b')

% 2.2 First guess at the TlNvc articular surface (AS)
ElmtsTlNvc = find(Talus.incenter*X0 > (alt_TlNvc_start+0.25*TlNvc_length));
TlNvc_AS = TriReduceMesh( Talus, ElmtsTlNvc );

% copy initial figure and add identified TlNvc AS
% Same figure with identified Talo-Navecular articular surface
a1 = gca ;
f2 = figure ;
a2 = copyobj(a1,f2) ;
hold on
trisurf(TlNvc_AS,'Facecolor','m','FaceAlpha',1,'edgecolor','none');
%Plot the inertia Axis & Volumic center
plotDot( CenterVol', 'k', 2 )
plotArrow( X0, 1, CenterVol, 40, 1, 'm')
plotArrow( Y0, 1, CenterVol, 40*D(1,1)/D(2,2), 1, 'g')
plotArrow( Z0, 1, CenterVol, 40*D(1,1)/D(3,3), 1, 'b')

% 2.3 Fit a initial sphere on the TlNvc AS
[Center_TlNvc,Radius_TlNvc,~] = sphereFit(TlNvc_AS.Points) ;

% copy previous figure and add sphere
a1 = gca ;
f2 = figure ;
a2 = copyobj(a1,f2) ;
hold on
plotSphere( Center_TlNvc, Radius_TlNvc , 'm' , 0.4)
plotDot( Center_TlNvc, 'm', 2 )

%% 3. Identification of the talocalcaneal sphere
% Assumptions :
%   - Z0 is grossly a distalo-proximal axis oriented proximally
%   - ...
% 3.1 plot the talus
figure()
trisurf(Talus,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',.8,'edgecolor','none');
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

% 3.2 Similar technique as for the tibial ankle AS 
% Get mean curvature of the Talus
[Cmean, Cgaussian, ~, ~, k1, k2] = TriCurvature(Talus,false);
maxAbsCurv =  max(abs(k1), abs(k2));

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

% Add surface to previous plot
trisurf(TlCcnAS1,'Facecolor','c','FaceAlpha',1,'edgecolor','none');

% 3.3 Fit a sphere to approximate AS
[Center_TlCcn,Radius_TlCcn,ErrorDist] = sphereFit(TlCcnAS1.incenter) ;

% copy previous figure and add sphere
a1 = gca ;
f2 = figure ;
a2 = copyobj(a1,f2) ;
hold on
plotSphere( Center_TlCcn, Radius_TlCcn , 'c' , 0.4)
plotDot( Center_TlCcn, 'c', 2 )

%% 4. Compute the "sub-axis"
u_SubAxis = normalizeV(Center_TlNvc-Center_TlCcn);
length_SubAxis =  norm(Center_TlCcn-Center_TlNvc);
center_SubAxis = (Center_TlCcn+Center_TlNvc)/2; 

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

%% 5. Identification of the ankle joint cylinder
% 5.1 Get a new CS from the subaxis 
X1 = u_SubAxis;
Z1 = normalizeV(cross(X1,Y0));
Y1 = cross(Z1,X1);

% 5.2 Identify the 'articular surfaces' of the ankle joint
TlTrcASNodesOK0 =  find(maxAbsCurv<quantile(maxAbsCurv,0.5) & ...
    rad2deg(acos(Talus.vertexNormal*Z0))<60 & ...
    rad2deg(acos(Talus.vertexNormal*Y1))>60 &...
    Talus.Points*X0 < alt_TlNeck_start);

TlTrcASNodesOK1 =  find(maxAbsCurv<quantile(maxAbsCurv,0.5) & ...
    rad2deg(acos(Talus.vertexNormal*Z1))<60 & ...
    rad2deg(acos(Talus.vertexNormal*Y1))>60 &...
    Talus.Points*X0 < alt_TlNeck_start);

TlTrcASNodesOK = unique([TlTrcASNodesOK0;TlTrcASNodesOK1],'rows');
TlTrcAS0 = TriReduceMesh(Talus,[],double(TlTrcASNodesOK));

% Keep largest connected region and smooth results
TlTrcAS0 = TriCloseMesh(Talus,TlTrcAS0,1);
TlTrcAS0 = TriKeepLargestPatch( TlTrcAS0 );
TlTrcAS0 = TriErodeMesh(TlTrcAS0,2);
TlTrcAS0 = TriKeepLargestPatch( TlTrcAS0 );
TlTrcAS0 = TriCloseMesh(Talus,TlTrcAS0,3);
TlTrcAS0 = TriDilateMesh(Talus,TlTrcAS0,2);

% 5.3 Get the first cylinder 
% Fit a sphere to a get an initial guess at the radius and a point on the
% axis

[Center_TlTrc_0,Radius_TlTrc_0] = sphereFit(TlTrcAS0.incenter) ;
[x0n, an, rn, d] = lscylinder( TlTrcAS0.incenter, Center_TlTrc_0', Y1,...
                            Radius_TlTrc_0, 0.001, 0.001);
Y2 =  normalizeV( an );

% 5.4 Refine the articular surface 
% Remove elements that are too for from from initial cylinder fit
%   more than 5% of radius inside or more than 10% outside
% Also remove elements that are too posterior
TlTrcASElmtsOK =  find(d > -0.05*rn & abs(d) < 0.1*rn &...
                TlTrcAS0.incenter*X0 > alt_TlTib_start);
TlTrcAS1 = TriReduceMesh(TlTrcAS0, TlTrcASElmtsOK);
% TlTrcAS1 = TriCloseMesh(TlTrcAS0, TlTrcAS1, 3);
TlTrcAS1 = TriKeepLargestPatch( TlTrcAS1 );

TlTrcAS = TlTrcAS1 ;

[x0n, an, rn] = lscylinder( TlTrcAS1.incenter, x0n, Y2,...
                            rn, 0.001, 0.001);
Y2 =  normalizeV( an );


% 5.5 Plot the results
figure()
trisurf(Talus,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',.6,'edgecolor','none');
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
plotArrow( X1, 1, CenterVol, 40, 1, 'r')
plotArrow( Y1, 1, CenterVol, 40*D(1,1)/D(2,2), 1, 'g')
plotArrow( Z1, 1, CenterVol, 40*D(1,1)/D(3,3), 1, 'b')

%Plot the  talar trochlea articular surface
% trisurf(TlTrcAS0,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
trisurf(TlTrcAS,'Facecolor','k','FaceAlpha',1,'edgecolor','none');

%Plot the Cylinder and its axis
plotCylinder( Y2, rn, x0n, 40, 0.4, 'r')
plotArrow( Y2, 1, x0n, 40, 1, 'r')
plotDot( x0n', 'r', 2 )

%% 6 Final results and plots
% 6.1 Plot the "articular surface" and the associated geomletries
figure()
% Plot the whole talus, here Talus is a Matlab triangulation object
Talus_NoAS = TriDifferenceMesh( Talus , TlNvc_AS );
Talus_NoAS = TriDifferenceMesh( Talus_NoAS , TlCcnAS1 );
Talus_NoAS = TriDifferenceMesh( Talus_NoAS , TlTrcAS );
Talus_NoAS = TriDilateMesh(Talus, Talus_NoAS, 1);
trisurf(Talus_NoAS,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',.8,'edgecolor','none');
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

%Plot the Tl Nvc part
trisurf(TlNvc_AS,'Facecolor','m','FaceAlpha',1,'edgecolor','none');
% plotSphere( Center_TlNvc, Radius_TlNvc , 'm' , 0.3)
plotDot( Center_TlNvc, 'm', 2 )

%Plot the TlCcn part
trisurf(TlCcnAS1,'Facecolor','c','FaceAlpha',1,'edgecolor','none');
% plotSphere( Center_TlCcn, Radius_TlCcn , 'c' , 0.3)
plotDot( Center_TlCcn, 'c', 2 )

%Plot the sub-axis
plotCylinder( u_SubAxis, 0.75, center_SubAxis, length_SubAxis, 1, 'k')

%Plot the ankle joint cylinder and AS
trisurf(TlTrcAS,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
% plotCylinder( Y2, rn, x0n, 40, 0.4, 'r')
plotArrow( Y2, 1, x0n, 40, 1, 'r')
plotDot( x0n', 'r', 2 )

axis off
% copy previous figure and add spheres and cylinders
a1 = gca ;
f2 = figure ;
a2 = copyobj(a1,f2) ;

plotCylinder( Y2, rn, x0n, 40, 0.4, 'r')
plotSphere( Center_TlCcn, Radius_TlCcn , 'c' , 0.3)
plotDot( Center_TlCcn, 'c', 2 )
plotSphere( Center_TlNvc, Radius_TlNvc , 'm' , 0.3)
plotDot( Center_TlNvc, 'm', 2 )

%% Write CS
% Initial inertia based coordinate system
CSs.CS0 = [X0,Y0,Z0];
CSs.UCyl = Y2;
CSs.USubAxis = u_SubAxis;
CSs.CenterNavicularSphere = Center_TlNvc;
CSs.CenterCalcanearSphere = Center_TlCcn;

%% Write TrObjetcs
TrObjects.Talus = Talus;
TrObjects.TalusWithoutAS = Talus_NoAS;
TrObjects.TaloCalcanearAS = TlCcnAS1;
TrObjects.TaloNavicularAS = TlNvc_AS;
TrObjects.TaloTibialAS = TlTrcAS;
TrObjects.FinalPlot = f2;


end
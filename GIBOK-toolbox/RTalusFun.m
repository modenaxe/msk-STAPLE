%% Initial Set up 
clearvars
close all
addpath(genpath(strcat(pwd,'/SubFunctions')));

%% Read the mesh of the Talus file
%'../test_geometries/MRI_P0/talus_r.stl'
%'../test_geometries/MRI_P0_smooth/talus_r.stl'
%'../test_geometries/JIA_CSm6/talus_r.stl'
%'../test_geometries/TLEM2/talus_r.stl'
% [Talus] = ReadMesh('../test_geometries/MRI_P0_smooth/talus_r.stl');

% testing mat import
[Imported] = load('../test_geometries/P0_MRI_tri/talus_r.mat');
Talus = Imported.curr_triang;

% function [ CSs, TrObjects ] = RTalusFun( Talus)
% Fit an ACS on a Talus

%% 1. Indentify the inertia axis of the Talus
% Get eigen vectors V_all of the Talus 3D geometry and volumetric center
[ V_all, CenterVol, InertiaMatrix, D ] = TriInertiaPpties( Talus );

quickPlotTriang(Talus, V_all, CenterVol)

X0 = V_all(:,1); 
Y0 = V_all(:,2); 
Z0 = V_all(:,3);


%Visually check the Inertia Axis orientation relative to the Talus geometry
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
plotArrow( X0, 1, CenterVol, 40, 1, 'r')
plotArrow( Y0, 1, CenterVol, 40*D(1,1)/D(2,2), 1, 'g')
plotArrow( Z0, 1, CenterVol, 40*D(1,1)/D(3,3), 1, 'b')

% X0 can be seen as a initial antero-posterior axis, not sure if the
% orientation of Y0 and Z0 are consistent accross subject because the value
% of their Moment of inertia are quite close (~15% difference)

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
figure()
plot(Alt,Area,'-*')

% Given the shape of the curve we can fit a bi gaussian curve to identify
% the two summits
%   "or" the orientation parameter is positive if X0 is oriented from 
%   posterior to anterior and negative otherwise
%
%   alt_TlNvc_start, gives the altitude along X0 at wich the CSA is maximal
%   and where the TaloNavicular (TlNvc) articular surface could start

[or, alt_TlNvc_start, alt_TlNeck_start] = FitCSATalus(Alt, Area);

% Change X0 orientation if necessary :
X0 = or*X0;
alt_TlNvc_end = max(Talus.incenter*X0);
TlNvc_length = alt_TlNvc_end-alt_TlNvc_start;


% 2.2 First guess at the TlNvc articular surface (AS)
ElmtsTlNvc = find(Talus.incenter*X0> (alt_TlNvc_start+0.25*TlNvc_length));
TlNvc_AS = TriReduceMesh( Talus, ElmtsTlNvc );

% copy initial figure and add identified TlNvc AS
figure(1)
a1 = gca ;
f2 = figure ;
a2 = copyobj(a1,f2) ;
hold on
trisurf(TlNvc_AS,'Facecolor','m','FaceAlpha',1,'edgecolor','none');

% 2.3 Fit a initial sphere on the TlNvc AS
[Center_TlNvc,Radius_TlNvc,ErrorDist] = sphereFit(TlNvc_AS.Points) ;

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
Cmean = TriCurvature(Talus,false);

% Identify nodes that should be on the surface based on surface and mean
% curvature
TlCcnASNodesOK0 =  find(Cmean>quantile(Cmean,0.25) & ...
    Cmean<quantile(Cmean,0.90) & ...
    rad2deg(acos(-Talus.vertexNormal*Z0))<40 &...
    Talus.Points*X0<alt_TlNeck_start);

TlCcnAS0 = TriReduceMesh(Talus,[],double(TlCcnASNodesOK0));

% Keep largest connected region and smooth results
TlCcnAS0 = TriKeepLargestPatch( TlCcnAS0 ) ;
TlCcnAS0 = TriCloseMesh(Talus,TlCcnAS0,2);
TlCcnAS0 = TriOpenMesh(Talus,TlCcnAS0,1);
TlCcnAS0 = TriCloseMesh(Talus,TlCcnAS0,2);

% remove elements that are on the wrong side of the AS edges
TlCcnASElmtsOK1 =  find(abs(TlCcnAS0.faceNormal*X0)<0.5);
TlCcnAS1 = TriReduceMesh(TlCcnAS0,TlCcnASElmtsOK1);
TlCcnAS1 = TriKeepLargestPatch( TlCcnAS1 ) ;
TlCcnAS1 = TriCloseMesh(TlCcnAS0,TlCcnAS1,1);

% Add surface to previous plot
trisurf(TlCcnAS1,'Facecolor','c','FaceAlpha',1,'edgecolor','none');

% 3.3 Fit a sphere to approximate AS
[Center_TlCcn,Radius_TlCcn,ErrorDist] = sphereFit(TlCcnAS0.incenter) ;

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
TlTrcASNodesOK0 =  find(Cmean>quantile(Cmean,0.10) & ...
    Cmean<quantile(Cmean,0.80) & ...
    rad2deg(acos(Talus.vertexNormal*Z0))<45 & ...
    abs(Talus.vertexNormal*Y0)<0.4);

TlTrcASNodesOK1 =  find(Cmean>quantile(Cmean,0.10) & ...
    Cmean<quantile(Cmean,0.80) & ...
    rad2deg(acos(Talus.vertexNormal*Z1))<45 & ...
    abs(Talus.vertexNormal*Y1)<0.4);

TlTrcASNodesOK = unique([TlTrcASNodesOK0;TlTrcASNodesOK1],'rows');
TlTrcAS0 = TriReduceMesh(Talus,[],double(TlTrcASNodesOK));

% Keep largest connected region and smooth results
TlTrcAS0 = TriKeepLargestPatch( TlTrcAS0 ) ;
TlTrcAS0 = TriErodeMesh(TlTrcAS0,3);
TlTrcAS0 = TriKeepLargestPatch( TlTrcAS0 ) ;
TlTrcAS0 = TriDilateMesh(Talus,TlTrcAS0,3);

% 5.3 Get the cylinder 
% Fit a sphere to a get an initial guess at the radius and a point on the
% axis

[Center_TlTrc_0,Radius_TlTrc_0] = sphereFit(TlTrcAS0.incenter) ;
[x0n, an, rn] = lscylinder( TlTrcAS0.incenter, Center_TlTrc_0', Y1,...
                            Radius_TlTrc_0, 0.001, 0.001);
Y2 =  normalizeV( an );

% 5.4 Plot the results
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
trisurf(TlTrcAS0,'Facecolor','r','FaceAlpha',1,'edgecolor','none');

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
Talus_NoAS = TriDifferenceMesh( Talus_NoAS , TlTrcAS0 );
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
trisurf(TlTrcAS0,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
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




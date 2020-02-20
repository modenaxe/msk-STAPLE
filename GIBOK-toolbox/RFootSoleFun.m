%% Initial Set up 
clearvars
close all
addpath(genpath(strcat(pwd,'/SubFunctions')));

%% Read the mesh of the Foot file

% [Foot] = ReadMesh('../test_geometries/TLEM2/foot_r.stl');
% [Foot] = ReadMesh('../test_geometries/LHDL_CT/calcn_r.stl');

cwd = 'C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries';
% load( strcat(cwd, '\TLEM2_MRI_tri\calcn_l.mat') )
% load( strcat(cwd, '\TLEM2_MRI_tri\calcn_r.mat') )
% load( strcat(cwd, '\TLEM2_CT_tri\calcn_l.mat') )
% load( strcat(cwd, '\TLEM2_CT_tri\calcn_r.mat') )
% load( strcat(cwd, '\P0_MRI_tri\calcn_r.mat') )
% load( strcat(cwd, '\LHDL_CT_tri\calcn_l.mat') )
load( strcat(cwd, '\LHDL_CT_tri\calcn_r.mat') )

Foot = curr_triang;
% Foot = ReadMesh(strcat(cwd,'\JIA_CSm6\calcn_r.stl'));

% Need to account for cases where the foot is subidivided into multiple 
% meshes. 
% Foot define here all the bone distal to the ankle joint except from the
% Talus. Phalanges are not mandatory and their presence or absence
% should not impact the results.

%========================
% LUCA's COMMENT
%========================
% The mesh you have chosen for development is special, in the sense that
% normally in building models we do not attach the phalanges to the rest of
% the foot, but we have 1) talus, 2) calcn+all other bones, 3)
% toes/phalanges.
% trying your script with data more similar to the one we use, e.g.
% [Foot] = ReadMesh('../test_geometries/TLEM2_CT/calcn_r.stl');
% it seems to work very nicely, and the blu plane is exactly what I was
% looking for, without even need for cutting the mesh.
%========================

% 1. Indentify initial CS of the foot
% Get eigen vectors V_all of the Talus 3D geometry and volumetric center
[ V_all, CenterVol, InertiaMatrix, D ] = TriInertiaPpties( Foot );

X0 = V_all(:,1); Y0 = V_all(:,2); Z0 = V_all(:,3);

% Get least square plane normal vector of the foot
[~,Z0] = lsplane(Foot.Points);
Y0 = normalizeV(cross(Z0,X0));
Z0 = cross(X0,Y0);

%Visually check the Inertia Axis orientation relative to the Talus geometry
figure()
% Plot the whole foot, here Foot is a Matlab triangulation object
trisurf(Foot,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',.6,'edgecolor','none');
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
plotArrow( X0, 1, CenterVol, 150, 1, 'r')
plotArrow( Y0, 1, CenterVol, 50, 1, 'g')
plotArrow( Z0, 1, CenterVol, 50, 1, 'b')

% 2. Get a convex hull of the Foot
[x, y, z] = deal(Foot.Points(:,1), Foot.Points(:,2), Foot.Points(:,3));

% K = convhull(x,y,z,'simplify', false);

[ IdxPtsPair , EdgesLength , K] = LargestEdgeConvHull(Foot.Points);

% trisurf(K,x,y,z,'Facecolor','c','FaceAlpha',.2,'edgecolor','k');
% for i = 1:10
%     plot3(x(IdxPtsPair(i,:)),y(IdxPtsPair(i,:)),z(IdxPtsPair(i,:)),...
%         'k-*','linewidth',2)
% end
%% Convexhull approach with prior deleting of the phalanges

% In the vast majority of cases, the reference system at the foot is
% computed using the geometries from talus to metatarsal bone, without the
% phalanges.
% This part of code is not needed
%==========================================
% Foot_Start = min(Foot.Points*X0);
% Foot_End = max(Foot.Points*X0);
% Foot_Length = Foot_End - Foot_Start; 
% ElmtsNoPhalange= find(Foot.incenter*X0 < (Foot_Start+0.80*Foot_Length));
% Foot2 = TriReduceMesh( Foot, ElmtsNoPhalange );
%==========================================

Foot2 = Foot;
% K = convhull(x,y,z,'simplify', false);
[x, y, z] = deal(Foot2.Points(:,1), Foot2.Points(:,2), Foot2.Points(:,3));
[ IdxPtsPair , EdgesLength , K] = LargestEdgeConvHull(Foot2.Points);

trisurf(K,x,y,z,'Facecolor','c','FaceAlpha',.2,'edgecolor','k');
% for i = 1:round(0.02*length(IdxPtsPair))
%     plot3(x(IdxPtsPair(i,:)),y(IdxPtsPair(i,:)),z(IdxPtsPair(i,:)),...
%         'k-*','linewidth',2)
% end

% Convert the convexHull to triangulation object
Foot2_CH = triangulation(K,x,y,z);
[V_all_CH, CenterVol_CH] = TriInertiaPpties( Foot2_CH );

% Get a vector superior to inferior from the center of the foot and its
% convex hull to creat a new temporary coordinate system R1
Ucenters0 = normalizeV(CenterVol_CH - CenterVol);
Ucenters = Ucenters0 - (Ucenters0'*X0)*X0;
Z1 = normalizeV(Ucenters);
X1 = X0;
Y1 = cross( Z1, X1 );

% Project the convex hull along the previously found direction
XY1 = [X1,Y1];
ProjZ1 = XY1*inv(XY1'*XY1)*XY1';

Foot2_CH_PTS_Proj = (ProjZ1*Foot2_CH.Points')';
Foot2_CH_Proj = triangulation(Foot2_CH.ConnectivityList, Foot2_CH_PTS_Proj);

% Find the largest triangle on the projected Convex Hull
[ Foot2_CH_Proj_Ppties ] = TriMesh2DProperties( Foot2_CH_Proj );
[~,I] = max(Foot2_CH_Proj_Ppties.Area);

trisurf(Foot2_CH.ConnectivityList(I,:),x,y,z,'Facecolor','b','FaceAlpha',1,'edgecolor','k');

%% Attribute the triangle vertices to the heel or the metatarsus
triangleNrml = - Foot2_CH.faceNormal(I)'; % minus to point superiorly
triangleVerticesID = Foot2_CH.ConnectivityList(I,:);
trianglePts = Foot2_CH.Points(triangleVerticesID,:);
[metatarsusPts, heelPt, maxEdgeLength] = TriangleClosestPointPair(trianglePts) ;

% plotDot(metatarsusPts,'r',2)
% plotDot(heelPt,'r',2)

metatarsPt1 = metatarsusPts(1,:);
metatarsPt2 = metatarsusPts(2,:);

%% Get the three points of interest 
%   1.  Select from the longest edges those which are below a plan 
%       parallel to the one defined by the largest triangle (the start and
%       end of those edges must be below that plan)

% Height of the foot along the triangle normal
FootISHeigth = range(Foot2_CH.Points*triangleNrml);

% Keep all edges that are above 80% of the triangle max edge length
IdxPtsPair(EdgesLength < 0.8*maxEdgeLength, :) = [];

% Verify that the points are below a plan parallel to the triangle
% offsetted 5% superiorly

GoodEdges = Foot2_CH.Points(IdxPtsPair,:)*triangleNrml < ...
    ( mean(trianglePts)*triangleNrml + 0.5 * FootISHeigth);

GoodEdges = GoodEdges(1:2:end-1,:) + GoodEdges(2:2:end,:);

% Verify that both edge start and end points are close enough to the
% triangle
IgoodEdges = find(GoodEdges == 2);

GoodIdxPointPair = IdxPtsPair(IgoodEdges, :);

% for i = 1:length(GoodIdxPointPair)
%     plot3(x(GoodIdxPointPair(i,:)),y(GoodIdxPointPair(i,:)),z(GoodIdxPointPair(i,:)),...
%         'r-s','linewidth',2)
% end

GoodPointIdx = unique( GoodIdxPointPair(:) );
CandidatePoints = Foot2_CH.Points(GoodPointIdx,:);

% Keep the metarsus points (not too close to the heel) 
notHeelPtsID = find( sqrt(sum(bsxfun(@minus, CandidatePoints, heelPt).^2, 2))>...
    0.5*maxEdgeLength) ;
metaCandidatePoints = CandidatePoints(notHeelPtsID,:);


%   2.  Cluster the points defining the largest edges in 3 clusters
[clusterIdx, clusterCentroids] = kmeans(metaCandidatePoints, 2);

%   3.  Associate the the cluster to the medial and lateral distal points
%       of the triangles
IdxMeta1 = knnsearch(clusterCentroids, metatarsPt1) ;
PtsMeta1 = metaCandidatePoints(clusterIdx == IdxMeta1, :);
pl3t(PtsMeta1,'mo')

IdxMeta2 = knnsearch(clusterCentroids, metatarsPt2) ;
PtsMeta2 = metaCandidatePoints(clusterIdx == IdxMeta2, :);
pl3t(PtsMeta2,'go')

figure(2)
pl3t(metaCandidatePoints(clusterIdx==1,:),'b.')
hold on
axis equal
pl3t(metaCandidatePoints(clusterIdx==2,:),'r.')


%   4.  Get the the points as the furthest one from the ones from the
%       triangles
Idx1 = knnsearch(PtsMeta1,metatarsPt1,'K',length(PtsMeta1)) ;
PtMeta1_Final = PtsMeta1(Idx1(end),:) ;

Idx2 = knnsearch(PtsMeta2,metatarsPt2,'K',length(PtsMeta2)) ;
PtMeta2_Final = PtsMeta2(Idx2(end),:) ;

newTriangle = [PtMeta1_Final; PtMeta2_Final; heelPt];
newTriangleNrml = cross(  (PtMeta2_Final-PtMeta1_Final), ...
                            (PtMeta1_Final-heelPt));
newTriangleNrml = normalizeV(newTriangleNrml);
newTriangleNrml = sign(newTriangleNrml'*triangleNrml)*newTriangleNrml;


%   5.  Keep the proximal vertices of the triangle as the calcaneus tip


%   6. Identify the medial side of the foot
Z2 = newTriangleNrml;
Y2 = normalizeV(cross(Z2,X1));
X2 = cross(Y2,Z2);

% Project the convex hull along the previously Y2 direction
ZX2 = [Z2,X2];
ProjY2 = ZX2*inv(ZX2'*ZX2)*ZX2';

Foot2_CH_PTS_Proj = (ProjY2*Foot2_CH.Points')';
Foot2_CH_Proj = triangulation(Foot2_CH.ConnectivityList, Foot2_CH_PTS_Proj);

% Find the largest triangle on the projected Convex Hull
[ Foot2_CH_Proj_Ppties ] = TriMesh2DProperties( Foot2_CH_Proj );
[~,I] = max(Foot2_CH_Proj_Ppties.Area);

% Medial vector
medialDirection = Foot2_CH.faceNormal(I)';

% Reorient Y2 accordingly
Y2 = sign(Y2'*medialDirection)*Y2;
X2 = cross(Y2,Z2);

% Determine which of the metatarsus points is medial and which is lateral.
PtsMeta1and2_Final = [PtMeta1_Final;PtMeta2_Final];
[~, ILat] = min(PtsMeta1and2_Final*Y2);
[~, IMed] = max(PtsMeta1and2_Final*Y2);

PtMetaLat = PtsMeta1and2_Final(ILat,:) ;
PtMetaMed = PtsMeta1and2_Final(IMed,:) ;

%   7. Final coordinate system and bony landmarks
CSs.X = X2; % Distal proximal
CSs.Y = Y2; % Lateral to medial
CSs.Z = Z2; % Ventral to dorsal

CSs.MedDistalMeta = PtMetaMed;
CSs.LatDistalMeta = PtMetaLat;
CSs.HeelTip = heelPt;

figure(3)
% Plot the whole foot, here Foot is a Matlab triangulation object
trisurf(Foot,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',1,'edgecolor','none');
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
plotDot(heelPt,'k',3)
plotDot(PtMetaLat,'b',3)
plotDot(PtMetaMed,'r',3)

% plot vectors
plotArrow( X2, 1, heelPt, 100, 1, 'r')
plotArrow( Y2, 1, heelPt, 50, 1, 'g')
plotArrow( Z2, 1, heelPt, FootISHeigth, 1, 'b')

% Plot the sole plane
[x, y, z] = deal(newTriangle(:,1), newTriangle(:,2), newTriangle(:,3));
trisurf([1 2 3],x,y,z,'Facecolor','b','FaceAlpha',0.4,'edgecolor','k');
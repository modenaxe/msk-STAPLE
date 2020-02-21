%% Initial Set up 
function [CSs, TrObjects] = GIBOK_calcn(Calcn)

TrObjects=[];

% Foot define here all the bone distal to the ankle joint except from the
% Talus. Phalanges are not mandatory and their presence or absence
% should not impact the results.
Foot = Calcn;

% 1. Indentify initial CS of the foot
% Get eigen vectors V_all of the Talus 3D geometry and volumetric center
[ V_all, CenterVol ] = TriInertiaPpties( Foot );
X0 = V_all(:,1);

% Get least square plane normal vector of the foot
[~,Z0] = lsplane(Foot.Points);
Y0 = normalizeV(cross(Z0,X0));
Z0 = cross(X0,Y0);


%% Convex hull approach with prior deleting of the phalanges
[x, y, z] = deal(Foot.Points(:,1), Foot.Points(:,2), Foot.Points(:,3));
[ IdxPtsPair , EdgesLength , K] = LargestEdgeConvHull(Foot.Points);
% plot convex hull
% trisurf(K,x,y,z,'Facecolor','c','FaceAlpha',.2,'edgecolor','k');

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

%% Attribute the triangle vertices to the heel or the metatarsus
triangleNrml = - Foot2_CH.faceNormal(I)'; % minus to point superiorly
triangleVerticesID = Foot2_CH.ConnectivityList(I,:);
trianglePts = Foot2_CH.Points(triangleVerticesID,:);
[metatarsusPts, heelPt, maxEdgeLength] = TriangleClosestPointPair(trianglePts) ;

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
% pl3t(PtsMeta1,'mo')

IdxMeta2 = knnsearch(clusterCentroids, metatarsPt2) ;
PtsMeta2 = metaCandidatePoints(clusterIdx == IdxMeta2, :);
% pl3t(PtsMeta2,'go')

% figure(2)
% pl3t(metaCandidatePoints(clusterIdx==1,:),'b.')
% hold on
% axis equal
% pl3t(metaCandidatePoints(clusterIdx==2,:),'r.')


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
PtsMeta1and2_Final = [PtMeta1_Final; PtMeta2_Final];
[~, ILat] = min(PtsMeta1and2_Final*Y2);
[~, IMed] = max(PtsMeta1and2_Final*Y2);

PtMetaLat = PtsMeta1and2_Final(ILat,:) ;
PtMetaMed = PtsMeta1and2_Final(IMed,:) ;

% 7. rebuild reference system so that X points at midpoint of Metas [LM]
X3 = normalizeV(0.5* (PtMetaMed + PtMetaLat) - heelPt);
Z3 = Z2;
Y3 = cross(Z3, X3);

%   7. Final coordinate system and bony landmarks
CSs.X = X3; % Distal proximal
CSs.Y = Y3; % Lateral to medial
CSs.Z = Z3; % Ventral to dorsal

CSs.MedDistalMeta = PtMetaMed;
CSs.LatDistalMeta = PtMetaLat;
CSs.HeelTip = heelPt;

figure(3)
quickPlotTriang(Foot)
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
plotArrow( X3, 1, heelPt, 100, 1, 'r')
plotArrow( Y3, 1, heelPt, 50, 1, 'g')
plotArrow( Z3, 1, heelPt, FootISHeigth, 1, 'b')

% Plot the sole plane
[x, y, z] = deal(newTriangle(:,1), newTriangle(:,2), newTriangle(:,3));
trisurf([1 2 3],x,y,z,'Facecolor','b','FaceAlpha',0.4,'edgecolor','k');
end
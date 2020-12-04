%-------------------------------------------------------------------------%
%  Author:   Luca Modenese & Jean-Baptiste Renault. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [CS, JCS, CalcnBL] = STAPLE_foot(calcnTri, side_raw, result_plots, debug_plots, in_mm)

% depends on
% TriangleClosestPointPair
% pl3t

% results/debug plot default
if nargin<3;     result_plots =1;  end
if nargin<4;     debug_plots = 0;  end
if nargin<5;     in_mm = 1;        end
if in_mm == 1;   dim_fact = 0.001; else;  dim_fact = 1; end

% get sign correspondent to body side
[sign_side, side_low] = bodySide2Sign(side_raw);

% joint names
toes_name     = ['mtp_', side_low];

% inform user about settings
disp('---------------------')
disp('   STAPLE - FOOT     '); 
disp('---------------------')
disp(['* Body Side   : ', upper(side_low)]);
disp(['* Method      : ', 'convex hull']);
disp(['* Result Plots: ', convertBoolean2OnOff(result_plots)]);
disp(['* Debug  Plots: ', convertBoolean2OnOff(debug_plots)]);
disp(['* Triang Units: ', 'mm']);
disp('---------------------')
disp('Initializing method...')

% 1. Indentify initial CS of the foot
% Get eigen vectors V_all of the Talus 3D geometry and volumetric center
[ V_all, CenterVol ] = TriInertiaPpties( calcnTri );
X0 = V_all(:,1);

% Get least square plane normal vector of the foot
[~,Z0] = lsplane(calcnTri.Points);
Y0 = normalizeV(cross(Z0,X0));
Z0 = cross(X0,Y0);

%% Convex hull approach with prior deleting of the phalanges
disp('Computing convex hull...')

% TODO: polish here: this line is used only for plotting
[x, y, z] = deal(calcnTri.Points(:,1), calcnTri.Points(:,2), calcnTri.Points(:,3));

% In the vast majority of cases, the reference system at the foot is
% computed using the geometries from talus to metatarsal bone, without the
% phalanges.
% This part of code is not needed
% TODO : Adapt the code in case there are the phalanges
%==========================================
% Foot_Start = min(Foot.Points*X0);
% Foot_End = max(Foot.Points*X0);
% Foot_Length = Foot_End - Foot_Start; 
% ElmtsNoPhalange= find(Foot.incenter*X0 < (Foot_Start+0.80*Foot_Length));
% Foot2 = TriReduceMesh( Foot, ElmtsNoPhalange );
%==========================================
[ IdxPtsPair , EdgesLength , K] = LargestEdgeConvHull(calcnTri.Points);

% plot convex hull
if debug_plots == 1
    trisurf(K,x,y,z,'Facecolor','c','FaceAlpha',.2,'edgecolor','k');
end

% remove indices not in the triangulation anymore (LM)
Kold2new(sort(unique(K(:)))) = 1:length(sort(unique(K(:))));
Pts_sorted = calcnTri.Points(sort(unique(K(:))),:);
% Convert the convexHull to triangulation object
Foot2_CH = triangulation(Kold2new(K), Pts_sorted);

% JB-version
% % % Convert the convexHull to triangulation object
% Foot2_CH = triangulation(K,x,y,z);

% verify differences (JB version keeps all points!)
% plot3(Foot2_CH1.Points(:,1), Foot2_CH1.Points(:,2), Foot2_CH1.Points(:,3), 'r.'); hold on
% plot3(Foot2_CH.Points(:,1), Foot2_CH.Points(:,2), Foot2_CH.Points(:,3), 'b.')

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

disp('Landmarking...')

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
% JB option: discarded no sense using triangulation to store all points
% GoodEdges = Foot2_CH.Points(IdxPtsPair,:)*triangleNrml < ...
%     ( mean(trianglePts)*triangleNrml + 0.5 * FootISHeigth);
GoodEdges = calcnTri.Points(IdxPtsPair,:)*triangleNrml < ...
    ( mean(trianglePts)*triangleNrml + 0.5 * FootISHeigth);

GoodEdges = GoodEdges(1:2:end-1,:) + GoodEdges(2:2:end,:);

% Verify that both edge start and end points are close enough to the
% triangle
IgoodEdges = find(GoodEdges == 2);

GoodIdxPointPair = IdxPtsPair(IgoodEdges, :);

GoodPointIdx = unique( GoodIdxPointPair(:) );

% JB option: discarded no sense using triangulation to store all points
% CandidatePoints = Foot2_CH.Points(GoodPointIdx,:);
CandidatePoints = calcnTri.Points(GoodPointIdx,:);

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
if debug_plots == 1
    quickPlotTriang(calcnTri);
    pl3t(PtsMeta1,'mo');
end

IdxMeta2 = knnsearch(clusterCentroids, metatarsPt2) ;
PtsMeta2 = metaCandidatePoints(clusterIdx == IdxMeta2, :);
if debug_plots == 1
    pl3t(PtsMeta2,'go');
end

if debug_plots == 1
    figure(2)
    quickPlotTriang(calcnTri);
    pl3t(metaCandidatePoints(clusterIdx==1,:),'b.')
    hold on
    axis equal
    pl3t(metaCandidatePoints(clusterIdx==2,:),'r.')
end

%   4.  Get the the points as the furthest one from the ones from the
%       triangles
Idx1 = knnsearch(PtsMeta1,metatarsPt1,'K',length(PtsMeta1)) ;
PtMeta1_Final = PtsMeta1(Idx1(end),:) ;

Idx2 = knnsearch(PtsMeta2,metatarsPt2,'K',length(PtsMeta2)) ;
PtMeta2_Final = PtsMeta2(Idx2(end),:) ;

% newTriangle approximates the foot sole
newTriangle = [PtMeta1_Final; PtMeta2_Final; heelPt];
newTriangleNrml = cross(  (PtMeta2_Final-PtMeta1_Final), ...
                            (PtMeta1_Final-heelPt));
newTriangleNrml = normalizeV(newTriangleNrml);
newTriangleNrml = sign(newTriangleNrml'*triangleNrml)*newTriangleNrml;


%   5.  Keep the proximal vertices of the triangle as the calcaneus tip
% [from previous versions]

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
Z3 = normalizeV(Z2);
Y3 = normalizeV(cross(Z3, X3));

%   7. Final coordinate system and bony landmarks
CS.X = X3; % Distal proximal
CS.Y = Z3; % Lateral to medial
CS.Z = -Y3; % Ventral to dorsal
% THIS IS USED IN jointDefinitions_Modenese2018.m
CS.V = [X3, Z3, -Y3];
CS.Origin = CenterVol;

% landmarks bone according to CS (only Origin and CS.V are used)
CalcnBL    = landmarkBoneGeom(calcnTri, CS, ['calcn_',side_low]);
side_up = upper(side_low);
CalcnBL.([side_up,'1MGROUND' ]) = PtMetaMed;
CalcnBL.([side_up,'5MGROUND' ]) = PtMetaLat;
CalcnBL.([side_up,'HEEGROUND']) = heelPt;

% sometimes the simple landmarking gets incorrect detection of D5M.
% Attempting to correct.
if norm(CalcnBL.([side_up,'D5M'])-CalcnBL.([side_up,'5MGROUND' ]))>10
    disp(['  Dubious identification of ',side_up,'D5M...Renamed ', side_up,'5MPROX.'])
    disp(['  Appending alternative ', side_up,'D5M.'])
    CalcnBL.([side_up,'5MPROX']) = CalcnBL.([side_up,'D5M']);
    CalcnBL.([side_up,'D5M'])    = CalcnBL.([side_up,'5MGROUND' ]);
end

% sometimes the simple landmarking gets incorrect detection of D1M.
% Attempting to correct.
if norm(CalcnBL.([side_up,'D1M'])-CalcnBL.([side_up,'1MGROUND' ]))>10
    disp(['  Dubious identification of ',side_up,'D1M...Renamed ', side_up,'1MPROX.'])
    disp(['  Appending alternative ', side_up,'D1M.'])
    CalcnBL.([side_up,'1MPROX']) = CalcnBL.([side_up,'D1M']);
    CalcnBL.([side_up,'D1M'])    = CalcnBL.([side_up,'1MGROUND' ]);
end

% calcn currently does not have a real child joint, but JCS structure is created for
% consistency
% only joints in JCS!
% JCS = CS;
% JCS.Origin = heelPt';

% define toes joint
Z = normalizeV(CalcnBL.([side_up,'D5M'])-CalcnBL.([side_up,'D1M']))*sign_side;
X = normalizeV(X3-X3*(X3'*Z));
Y = normalizeV(cross(Z,X));
midpoint_DM = (CalcnBL.([side_up,'D5M'])+CalcnBL.([side_up,'D1M']))/2.0;
JCS.(toes_name).Origin = midpoint_DM;
JCS.(toes_name).V = [X Y Z];
JCS.(toes_name).parent_location = midpoint_DM * dim_fact;
JCS.(toes_name).parent_orientation = computeXYZAngleSeq(JCS.(toes_name).V);


label_switch = 1;

paper_figure = 0;
if paper_figure == 1
    figure
    quickPlotTriang(calcnTri)
    trisurf(K,x,y,z,'Facecolor','c','FaceAlpha',.2,'edgecolor','k');
    [x, y, z] = deal(newTriangle(:,1), newTriangle(:,2), newTriangle(:,3));
    trisurf([1 2 3],x,y,z,'Facecolor','b','FaceAlpha',0.8,'edgecolor','k');
    axis off
end

if result_plots == 1
    figure('Name', ['STAPLE | bone: foot | side: ', side_low])
    % plot the calcn triangulation
    plotTriangLight(calcnTri, CS, 0)
    % Plot the inertia Axis & Volumic center
    quickPlotRefSystem(JCS.(toes_name))

    
    % plot markers and labels
    plotBoneLandmarks(CalcnBL, label_switch)   
    
    % Plot the sole plane
    [x, y, z] = deal(newTriangle(:,1), newTriangle(:,2), newTriangle(:,3));
    trisurf([1 2 3],x,y,z,'Facecolor','b','FaceAlpha',0.4,'edgecolor','k');
        % plot the bone landmarks
    %     plotDot(heelPt,'g',3)
    %     plotDot(PtMetaLat,'b',3)
    %     plotDot(PtMetaMed,'r',3)

end

disp('Done');

end
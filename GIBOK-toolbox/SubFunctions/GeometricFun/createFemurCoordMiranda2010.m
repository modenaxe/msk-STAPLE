function CSs = createFemurCoordMiranda2010(DistFem, CSs)


% TODO: double check against manuscript
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2866785/

%% Compute the femur diaphysis axis
[V_all, Center0] = TriInertiaPpties( DistFem );

% inertial axis from the distal femur triangulation
Z0 = V_all(:,1);
X0 = V_all(:,3);
Y0 = V_all(:,2);

% in slicing the Z0 normal needs to be inverted from GIBOK [LM]
coeff = -1;

% slicing femur along the "long" dimension

% TODO: This should be every mm, not on 200 points
Alt = linspace( min(DistFem.Points*Z0)+0.1 ,max(DistFem.Points*Z0)-0.1, 400);
Area=[];
for d = Alt
    [ Curves , Area(end+1), ~ ] = TriPlanIntersect(DistFem, coeff*Z0 , d );
end

% compare with Fig 3 of Miranda publication.
% bar(Area)

%=======================================
quickPlotTriang(DistFem, 'r')
% figure
% trisurf(DistFem.ConnectivityList, DistFem.Points(:,1), DistFem.Points(:,2), DistFem.Points(:,3),'Facecolor','m','Edgecolor','none');
% light; lighting phong; % light
% hold on, axis equal
% curves not usable because not stored
%=======================================

% first location: maximum area
[maxArea,ImaxArea] = max(Area);
Loc1 = Alt(ImaxArea);

% second location: 1/2 maximum area (after the first location)
AreasPastMax=Area(ImaxArea:end);
[~,Id] = min(abs(maxArea/2-AreasPastMax));
% Original code had a bug here -missed -1 - [LM]
Loc2 = Alt(ImaxArea+Id-1);

% idenfication of diaphysis
% TODO: should be Alt(0)
dd = Loc2 - min(Alt);

% Different from Miranda: instead of finding a point and using a plane,
% points are identify above and below the threshold.
ElmtsDia = find(DistFem.incenter*Z0>(min(Alt) + 1.3*dd));
ElmtsEpi = find(DistFem.incenter*Z0<(min(Alt) + 1.3*dd));

% create diaphysis triangulation
DiaFem = TriReduceMesh( DistFem, ElmtsDia );
DiaFem = TriFillPlanarHoles(DiaFem);

% get inertial properties from diaphysis
[V_DiaFem, DiaFem_Center] = TriInertiaPpties( DiaFem );
Zdia = V_DiaFem(:,1);

EpiFem = TriReduceMesh( DistFem, ElmtsEpi );

%=======================================
figure
trisurf(EpiFem.ConnectivityList, EpiFem.Points(:,1), EpiFem.Points(:,2), EpiFem.Points(:,3),'Facecolor','m','Edgecolor','none');
light; lighting phong; % light
hold on, axis equal
%=======================================

%% Find Pt1 described in their method

LinePtNodes = bsxfun(@minus, EpiFem.Points, DiaFem_Center');

CP = (cross(repmat(Zdia',length(LinePtNodes),1),LinePtNodes));

Dist = sqrt(sum(CP.^2,2));
[~,IclosestPt] = min(Dist);
Pt1 = EpiFem.Points(IclosestPt,:);

plot3(Pt1(1),Pt1(2),Pt1(3),'o','LineWidth',4)

%% Find Pt2
% curve at second location (max + 1/2 area)
[ Curves , ~, ~ ] = TriPlanIntersect(DistFem, coeff*Z0 , min(Alt) + dd );

% plot the curve
plot3(Curves.Pts(:,1), Curves.Pts(:,2), Curves.Pts(:,3),'k'); hold on; axis equal

% moving curve in inertial axes ref system
NewPts = Curves.Pts*V_all; 
% finding the centre of the bounding box
Center_BBox = mean([min(NewPts); max(NewPts)]);
% TODO: find points posterior in axial ref syst
% post_curve = NewPts(:,3)>Center_BBox(3);
% [~, ind] = min(abs(NewPts(post_curve,2)-Center_BBox(2)));
% figure; plot3(NewPts(:,1), NewPts(:,2), NewPts(:,3),'-k'); grid on; axis equal;hold on
% plot3(Center_BBox(:,1), Center_BBox(:,2), Center_BBox(:,3),'ok'); grid on; axis equal
% plot3(NewPts(ind,1), NewPts(ind,2), NewPts(ind,3),'*k')

CenterCS = V_all*Center_BBox';

%======================== 
% THIS IS A MESS AND NEEDS TO BE REWRITTEN

% getting the nearest neighbour in Curves for the point in CenterCS
IDX = knnsearch(Curves.Pts,CenterCS');

Uap = normalizeV(Curves.Pts(IDX,:)-CenterCS');

PosteriorPts = Curves.Pts(Curves.Pts*Uap>CenterCS'*Uap,:);
% ClosestPts = Curves.Pts(IDX,:);
% The Point P2
LinePtNodes = bsxfun(@minus, PosteriorPts, CenterCS');
CP = (cross(repmat(X0',length(LinePtNodes),1),LinePtNodes));

Dist = sqrt(sum(CP.^2,2));
[~,IclosestPt] = min(Dist);
Pt2 = PosteriorPts(IclosestPt,:);
%==============================================

plot3(Pt2(1),Pt2(2),Pt2(3),'ro','LineWidth',4)

%% Define first plan iteration
npcs = normalizeV(cross( Pt1-Pt2, Y0));

if (Center0'-Pt1)*npcs > 0
    npcs = -npcs;
end

ElmtsDPCs = find(EpiFem.incenter*npcs > Pt1*npcs);

% first iteration fitted geometry
PCsFem = TriReduceMesh( EpiFem, ElmtsDPCs );

%=======================================
figure
trisurf(PCsFem.ConnectivityList, PCsFem.Points(:,1), PCsFem.Points(:,2), PCsFem.Points(:,3),'Facecolor','m','Edgecolor','none');
light; lighting phong; % light
hold on, axis equal; 
%=======================================


% First Cylinder Fit
Axe0 = Y0';
Radius0 = 0.5*(max(PCsFem.Points*npcs)-min(PCsFem.Points*npcs));

[x0n, an, rn, d] = lscylinder(PCsFem.Points(1:3:end,:), mean(PCsFem.Points)' - 2*npcs, Axe0, Radius0, 0.001, 0.001);

plotCylinder( an, rn, x0n, 15, 1, 'b')

%% Define second plan iteration
npcs = cross( Pt1-Pt2, an); npcs = npcs'/norm(npcs);

if (Center0'-Pt1)*npcs > 0
    npcs = -npcs;
end

ElmtsDPCs = find(EpiFem.incenter*npcs > Pt1*npcs);
PCsFem = TriReduceMesh( EpiFem, ElmtsDPCs );

%=======================================
figure
trisurf(PCsFem.ConnectivityList, PCsFem.Points(:,1), PCsFem.Points(:,2), PCsFem.Points(:,3),'Facecolor','b','Edgecolor','none');
light; lighting phong; % light
hold on, axis equal
%=======================================

% Second and last Cylinder Fit
Axe0 = an/norm(an);
Radius0 = rn;

[x0n, an, rn, d] = lscylinder(PCsFem.Points(1:3:end,:), x0n, Axe0, Radius0, 0.001, 0.001);

EpiPtsOcyl_tmp = bsxfun(@minus,PCsFem.Points,x0n');

CylStart = min(EpiPtsOcyl_tmp*an)*an' + x0n';
CylStop = max(EpiPtsOcyl_tmp*an)*an' + x0n';

CylCenter = 1/2*(CylStart + CylStop);

plotCylinder( an, rn, x0n, norm(CylStart - CylStop), 1, 'r')

Results.Yend_Miranda = an;
Results.Xend_Miranda = cross(an,Zdia); 
Results.Xend_Miranda = Results.Xend_Miranda  / norm(Results.Xend_Miranda);
Results.Zend_Miranda = cross(Results.Xend_Miranda,Results.Yend_Miranda);
Results.CenterKnee_Miranda = CylCenter;

end

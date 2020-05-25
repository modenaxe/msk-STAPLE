function CSs = Miranda2010_femur(Femur)


L_ratio = 0.40;
[ U_DistToProx ] = femur_get_correct_first_CS( Femur );
[ProxFem, DistFem] = cutLongBoneMesh(Femur, U_DistToProx, L_ratio);
[ ~, CS.CenterVol] = TriInertiaPpties(Femur);
if nargin<2
    pname = '.';
    fm = 'temp_fem.iv';
end

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
disp('Slicing femur for Miranda et al. 2010 method....')
Alt = linspace( min(DistFem.Points*Z0)+0.1 ,max(DistFem.Points*Z0)-0.1, 200);
Area=[];
for d = Alt
    [ Curves , Area(end+1), ~ ] = TriPlanIntersect(DistFem, coeff*Z0 , d );
end
disp('DONE')

% compare with Fig 3 of Miranda publication.
% bar(Area)

% debug plot
quickPlotTriang(DistFem, 'r', 1)


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

% create distal epiphysis triangulation
EpiFem = TriReduceMesh( DistFem, ElmtsEpi );

% debug plot
quickPlotTriang(EpiFem, 'b')

%% Find Pt1 described in their method
% Pt1 : Closest epiphysis point to the diaphysis 1st inertia axis

% Get the vectors of the epiphysis points to a point on the 
% 1st inertial axis (the centroid of the diaphysis)
LinePtNodes = bsxfun(@minus, EpiFem.Points, DiaFem_Center');

% Get the vectors connecting the epiphysis point to their othogonal 
% projection point on the 1st inertia axis
CP = (cross(repmat(Zdia',length(LinePtNodes),1),LinePtNodes));

% Find the closest point to the diaphysis 1st inertia axis
Dist = sqrt(sum(CP.^2,2));
[~,IclosestPt] = min(Dist);
Pt1 = EpiFem.Points(IclosestPt,:);

% debug plot
plot3(Pt1(1),Pt1(2),Pt1(3),'o','LineWidth',4)

%% Find Pt2
% curve at second location (max + 1/2 area)
[ Curves , ~, ~ ] = TriPlanIntersect(DistFem, coeff*Z0 , min(Alt) + dd );

% debug plot
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

% Identify the posterior part of the cross section :
% assume that the closest point of the cross section 
% border is posterior
% getting the nearest neighbour in Curves for the point in CenterCS
IDX = knnsearch(Curves.Pts,CenterCS');

% Get a raw Anterior to Posterior vector : Uap
Uap = normalizeV(Curves.Pts(IDX,:)-CenterCS');

% From the cross section border keep only the points that are 
% posterior to the center point of the bounding box
PosteriorPts = Curves.Pts(Curves.Pts*Uap>CenterCS'*Uap,:);

% Find the The Point P2
% Get the orthogonal distance of the points on the posterior
% part of the cross section border to the 3rd inertia axis of
% the whole distal femur
LinePtNodes = bsxfun(@minus, PosteriorPts, CenterCS');
CP = (cross(repmat(X0',length(LinePtNodes),1),LinePtNodes));
Dist = sqrt(sum(CP.^2,2));

% Identify the closest point which is Pt2
[~,IclosestPt] = min(Dist);
Pt2 = PosteriorPts(IclosestPt,:);
%==============================================

% debug plot
plot3(Pt2(1),Pt2(2),Pt2(3),'ro','LineWidth',4)

%% Define first plan iteration
npcs = normalizeV(cross( Pt1-Pt2, Y0));

if (Center0'-Pt1)*npcs > 0
    npcs = -npcs;
end

ElmtsDPCs = find(EpiFem.incenter*npcs > Pt1*npcs);

% first iteration fitted geometry
PCsFem = TriReduceMesh( EpiFem, ElmtsDPCs );

% debug plot
quickPlotTriang(PCsFem, 'm')

%% First Cylinder Fit
% Initialize axis, radius and center of the cylinder
Axe0 = Y0';
Radius0 = 0.5*(max(PCsFem.Points*npcs)-min(PCsFem.Points*npcs));
Center0 = mean(PCsFem.Points)' - 2*npcs;
% Get a subset of the points for speed
CylPtsSS = PCsFem.Points(1:3:end,:)

% Fit the 1st cylinder
[x0n, an, rn, d] = lscylinder(CylPtsSS, Center0, Axe0, Radius0, 0.001, 0.001);

plotCylinder( an, rn, x0n, 15, 1, 'b')

%% Define second plan iteration
% TODO: double check: second iteration is very similar to first
% The normal of the cut plan separting the posterior condyles is 
% updated with the just identified cylinder axis
npcs = cross( Pt1-Pt2, an); 
npcs = npcs'/norm(npcs);

% Make sure the plan normal npcs points posteriorly and distally
if (Center0'-Pt1)*npcs > 0
    npcs = -npcs;
end

% Select the points of the epiphysis lying posteriorly to the plan
ElmtsDPCs = find(EpiFem.incenter*npcs > Pt1*npcs);
PCsFem = TriReduceMesh( EpiFem, ElmtsDPCs );

% Second and last Cylinder Fit
Axe1 = normalizeV(an);
Radius1 = rn;
Center1 = X0n;
% Get a subset of the points for speed
CylPtsSS = PCsFem.Points(1:3:end,:);

% Fit the 2nd cylinder
[x0n, an, rn, d] = lscylinder(CylPtsSS, Center1, Axe1, Radius1, 0.001, 0.001);

%% Get the origin of the CS : the centroid of the fitted cylinder
% Here we take it as the middle point on the cylinder axis between the most
% lateral point projected on the axis and the most medial point projected on the 
% cylinder axis.
EpiPtsOcyl_tmp = bsxfun(@minus,PCsFem.Points,x0n');

CylStart = min(EpiPtsOcyl_tmp*an)*an' + x0n';
CylStop = max(EpiPtsOcyl_tmp*an)*an' + x0n';

CylCenter = 1/2*(CylStart + CylStop);

% debug plot
quickPlotTriang(PCsFem, 'g')
plotCylinder( an, rn, x0n, norm(CylStart - CylStop), 1, 'r')

CSs.Yend_Miranda = an;
CSs.Xend_Miranda = cross(an,Zdia); 
CSs.Xend_Miranda = CSs.Xend_Miranda  / norm(CSs.Xend_Miranda);
CSs.Zend_Miranda = cross(CSs.Xend_Miranda,CSs.Yend_Miranda);
CSs.CenterKnee_Miranda = CylCenter;

end

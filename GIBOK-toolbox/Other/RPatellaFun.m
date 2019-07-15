function [ Results ] = RPatellaFun( name , oprtr , RATM_on)
% Fit an ACS to Patella

Results = struct();

% Piece of code to generate a random affine transformation matrix
if RATM_on

end

addpath(strcat(pwd,'\SubFonctions'));
addpath(strcat(pwd,'\SubFonctions\SurFit'));

%% Read the 3D bone model mesh
% Read the Patella (PAT) 3D bone model
XYZELMTS = py.txt2mtlb.read_meshGMSH(strcat('\Repere3DData\',name,'_PAT',oprtr,'05.msh'));
Pts2D = [cell2mat(cell(XYZELMTS{'X'}))' cell2mat(cell(XYZELMTS{'Y'}))' cell2mat(cell(XYZELMTS{'Z'}))'];
Elmts2D = [cell2mat(cell(XYZELMTS{'N1'}))' cell2mat(cell(XYZELMTS{'N2'}))' cell2mat(cell(XYZELMTS{'N3'}))'];
if RATM_on
    % Get a random roto-translation matrix
    [ Matm , Vatm , Tatm, angles ] = randomATM;
    Results.RATM.ATM = Matm;
    Results.RATM.R = Vatm;
    Results.RATM.T = Tatm;
	
	% Update Patella vertices location with the random roto-translation matrix
    Pts2D = bsxfun(@plus,Pts2D*Vatm , Tatm');
end

% Verify that normal are outward-pointing and fix if not
Elmts2D = fixNormals( Pts2D, Elmts2D );


[ InertiaMatrix, Center ] = InertiaProperties( Pts2D, Elmts2D );
[V_all,~] = eig(InertiaMatrix);
Center0 = Center;

TR0 = triangulation(double(Elmts2D),Pts2D);

 %%  Check for the Z Inertia axis to always in anterior direction
% Test for circularity, because on one face the surface is spherical and on the arular surface it's
% more like a Hyperbolic Paraboloid, the countour od the cross section have
% different circularity.

% First 0.5 mm in Start and End are not accounted for, for stability.

nAP = V_all(:,3);
Alt = linspace( min(Pts2D*nAP)+0.5 ,max(Pts2D*nAP)-0.5, 100);
Area=[];
Circularity=[];
for d = Alt
    [ Curves , Area(end+1), ~ ] = TriPlanIntersect( Pts2D, Elmts2D, nAP , d );
    PtsTmp=[];
    for i = 1 : length(Curves)
        PtsTmp (end+1:end+length(Curves(i).Pts),:) = Curves(i).Pts;
        if isempty(PtsTmp)
            Curves(i).Pts
        end
    end
    dist2center = sqrt(sum(bsxfun(@minus,PtsTmp,mean(PtsTmp)).^2,2));
    Circularity(end+1) = std(dist2center)/mean(dist2center);
end

Circularity1stOffSettedQuart = Circularity(Alt<quantile(Alt,0.3) & Alt>quantile(Alt,0.05));
Circularity3rdOffSettedQuart = Circularity(Alt>quantile(Alt,0.7) & Alt<quantile(Alt,0.95));


if mean(Circularity1stOffSettedQuart)<mean(Circularity3rdOffSettedQuart)
    sprintf('invert AP axis')
    V_all(:,3) = - V_all(:,3);
    V_all(:,2) = cross(V_all(:,3),V_all(:,1));
    V_all(:,1) = cross(V_all(:,2),V_all(:,3));
end

Pts2D = Pts2D*V_all ;
[ ~, Center ] = InertiaProperties( Pts2D, Elmts2D );

Pts2D = bsxfun(@minus , Pts2D , Center');
TR = triangulation(double(Elmts2D),Pts2D);

%% Rainbow

x0 = 0;
options = optimoptions(@fminunc,'Algorithm','quasi-newton');
x1 = fminunc(@(x)patRidge(x,TR,-1,-1,1),x0,options);

V = [cos(x1);sin(x1);0];
U = [-sin(x1);cos(x1);0];

U = LSSLFitRidge( TR,U,75);

x0 = 0;
nbCuts = 40;
options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton',...
    'MaxFunctionEvaluations',2500,'StepTolerance',1e-9,...
    'MaxIterations',2500,'OptimalityTolerance',1e-9,'Display','final-detailed');
x1_0 = fminunc(@(x)patRidge(x,TR,-1,-1,1),x0,options);
U_0 = [-sin(x1_0);cos(x1_0);0];


Alt = linspace( min(TR.Points*U)+0.5 ,max(TR.Points*U)-0.5, 40);
LowestPoints = zeros(length(Alt),3);
i=0;
for d = Alt
    i=i+1;
    
    [ Curves , ~ , ~ ] = TriPlanIntersect( TR.Points, TR.ConnectivityList, U , d );
    EdgePts = vertcat(Curves(:).Pts);
    [~,lowestPointID] = min(EdgePts(:,3));
    LowestPoints(i,:) = EdgePts(lowestPointID(1),:);

    
end
LowestPoints_ACS0 = LowestPoints*[U V [0;0;1]];

[fitresult, gof] = patRidgeFit(LowestPoints_ACS0(:,1),LowestPoints_ACS0(:,3));

Xintrsctn = (fitresult.d-fitresult.b)/(fitresult.a-fitresult.c);

idx = rangesearch([LowestPoints_ACS0(:,1),LowestPoints_ACS0(:,3)],...
    [Xintrsctn,fitresult.a*Xintrsctn+fitresult.b],0.15*range(LowestPoints_ACS0(:,1)));

[~,Imin] = min(LowestPoints_ACS0(idx{1},3));

SizeInf = sum(LowestPoints_ACS0(:,1) < Xintrsctn);
SizeSup = sum(LowestPoints_ACS0(:,1) > Xintrsctn);

Xcut = LowestPoints_ACS0(idx{1}(Imin),1);

if SizeSup > SizeInf
    RidgePts = LowestPoints_ACS0(LowestPoints_ACS0(:,1) > Xintrsctn,:);
    StartDist = 1.1*(Xcut - min(LowestPoints_ACS0(:,1)));
    EndDist = 0.05*range(LowestPoints_ACS0(:,1));
    Side = +1;
else
    RidgePts = LowestPoints_ACS0(LowestPoints_ACS0(:,1) < Xintrsctn,:);
    EndDist = 1.1*(max(LowestPoints_ACS0(:,1)) - Xcut);
    StartDist = 0.05*range(LowestPoints_ACS0(:,1));
    Side = -1;
end
% Make sure the Sup-Inf vector points towards the up;

[ U, Uridge , LowestPoints_end ] = LSSLFitRidge( TR,U,75,StartDist, EndDist);
U = Side*U;

LowestPoints_CS0 = bsxfun(@plus,LowestPoints_end,Center')*V_all';


%% Write results

%% Technic : MJ Rainbow 2013 , Automatic determination of an anatomical coordinate system for a three-dimensional model of the human patella
% Make sure the Sup-Inf vector points towards the up;
% Technic All
U_0 = Side*U_0;
Z0 = V_all*U_0;
X0 = V_all(:,3);
Y0 = cross(Z0,X0);

Results.X0 = X0;
Results.Y0 = Y0;
Results.Z0 = Z0;


%% Technic volume, improved Rainbow with separation of apex from articular surface
Z = V_all*U;
X = V_all(:,3);
Y = cross(Z,X);

Results.X = X;
Results.Y = Y;
Results.Z = Z;
Results.Theta1 = x1;
Results.Theta2 = -asin(U(1));
Results.V = [X Y Z];
Results.Center = Center0;


%% technic inertia of art surf 
%% Test identify articular surface and fit an ellipse on its borders
LengthRidge = range(LowestPoints_CS0*Z3);
PtRidgeDist = LowestPoints_CS0(LowestPoints_CS0*Z3==min(LowestPoints_CS0*Z3),:);

% Select elements on the articular surface
Condition1 = abs(TR0.faceNormal*Z3)<0.23 ; %cos(pi/12);
Condition2 = TR0.faceNormal*X3>cos(pi/3);
Condition3 = TR0.incenter*Z3>PtRidgeDist*Z3-0.25*LengthRidge;

IgoodElmts = find(Condition1&Condition2&Condition3);

ArtSurf = TriReduceMesh(TR0,IgoodElmts);
ArtSurf0 = ArtSurf ;
ArtSurf = TriOpenMesh(TR0,ArtSurf,2);
ArtSurf = TriCloseMesh(TR0,ArtSurf,4);
ArtSurf = TriConnectedPatch(ArtSurf,LowestPoints_CS0);

[Nrml,~] = PlanMC( ArtSurf.Points ); Nrml = sign(dot(X3,Nrml))*Nrml;

ArtSurfDilated = TriDilateMesh(TR0,ArtSurf,15);
Condition1 = abs(ArtSurfDilated.faceNormal*Z3)<0.375;
Condition2 = ArtSurfDilated.faceNormal*Nrml>cos(3*pi/10);
Condition3 = ArtSurfDilated.incenter*Z3>PtRidgeDist*Z3+0.15*LengthRidge & ...
   ArtSurfDilated.faceNormal*Nrml>0.5 ;

IgoodElmts = unique([find(Condition1&Condition2);find(Condition3)]);

ArtSurf = TriReduceMesh(ArtSurfDilated,IgoodElmts);
ArtSurf = TriOpenMesh(TR0,ArtSurf,3);
ArtSurf = triangulationUnite(ArtSurf0,ArtSurf);
ArtSurf = TriCloseMesh(TR0,ArtSurf,2);
ArtSurf = TriConnectedPatch(ArtSurf,LowestPoints_CS0);
ArtSurf = TriCloseMesh(TR0,ArtSurf,30);
ArtSurf = TriOpenMesh(TR0,ArtSurf,15);
ArtSurf = TriErodeMesh(ArtSurf,2);
ArtSurf = TriCloseMesh(TR0,ArtSurf,5);

[V,~] = eig(TriCovMatrix(ArtSurf));
D4 = TriMesh2DProperties(ArtSurf);

Z4 = V(:,2); Z4 = sign(Z3'*Z4)*Z4;
X4 = V(:,1); X4 = sign(X3'*X4)*X4;
Y4 = cross(Z4,X4);

Results.X4 = X4;
Results.Y4 = Y4;
Results.Z4 = Z4;
Results.V4 = V;

Results.Center4 = D4.Center;
Results.Center4onMesh = D4.onMeshCenter;

%% Technic Articular Surface, least square straight line fit on the ridge, and volume centroid projection on it

% Make sure the Sup-Inf vector points towrds the up;
Uridge = sign(U'*Uridge)*Uridge;
Center3 = (Center' + mean(LowestPoints_end))*V_all';
Center2 = Center3 + (Center0' - Center3)*(V_all*Uridge)*transpose(V_all*Uridge);

Z3 = V_all*Uridge;
X3 = V_all(:,3);
Y3 = cross(Z3,X3) / norm(cross(Z3,X3));
X3 = cross(Z3,Y3);

X3 = -X3;
Results.X3 = X3;
Results.Uridge = Uridge;
Results.Y3 = Y3;
Results.Z3 = Z3;
Results.V3 = [X3 Y3 Z3];
Results.Center3 = Center3;
Results.Center2 = Center2;


end


function [ CSs, TrObjects ] = RPatellaFun( Patella )
% Fit an ACS to the Patella

addpath(genpath(strcat(pwd,'/SubFunctions')));
CSs = struct();

% Get eigen vectors V_all of the Tibia 3D geometry and volumetric center
[ V_all, CenterVol, InertiaMatrix ] = TriInertiaPpties( Patella );
Center = CenterVol;

CSs.CenterVol = CenterVol;
CSs.InertiaMatrix = InertiaMatrix;

%%  Check for the Z Inertia axis to always in anterior direction
% Test for circularity, because on one face the surface is spherical and on the arular surface it's
% more like a Hyperbolic Paraboloid, the countour od the cross section have
% different circularity.

% First 0.5 mm in Start and End are not accounted for, for stability.

% initial guess of Antero-Posterior axis
nAP = V_all(:,3);
Alt = linspace( min(Patella.Points*nAP)+0.5 ,max(Patella.Points*nAP)-0.5, 100);
Area=[];
Circularity=[];
for d = -Alt
    [ Curves , Area(end+1), ~ ] = TriPlanIntersect( Patella, nAP , d );
    PtsTmp=[];
    for i = 1 : length(Curves)
        PtsTmp (end+1:end+length(Curves(i).Pts),:) = Curves(i).Pts;
        if isempty(PtsTmp)
            Curves(i).Pts
        end
    end
    % compute the circularity (criteria ? Coefficient of Variation)
    dist2center = sqrt(sum(bsxfun(@minus,PtsTmp,mean(PtsTmp)).^2,2));
    Circularity(end+1) = std(dist2center)/mean(dist2center);
end

% Get the circularity at both first last quarter of the patella
Circularity1stOffSettedQuart = Circularity(Alt<quantile(Alt,0.3) & Alt>quantile(Alt,0.05));
Circularity3rdOffSettedQuart = Circularity(Alt>quantile(Alt,0.7) & Alt<quantile(Alt,0.95));

% Check that the circularity is higher in the anterior part otherwise
% invert AP axis direction :
if mean(Circularity1stOffSettedQuart)<mean(Circularity3rdOffSettedQuart)
    sprintf('invert AP axis')
    V_all(:,3) = - V_all(:,3);
    V_all(:,2) = cross(V_all(:,3),V_all(:,1));
    V_all(:,1) = cross(V_all(:,2),V_all(:,3));
end

%% Move the Patella from CS0 to the Principal Inertia Axis CS
PatPIACS = TriChangeCS( Patella, V_all, CenterVol );

%% Technic : MJ Rainbow 2013 , Automatic determination of an anatomical coordinate system for a three-dimensional model of the human patella
% Make sure the Sup-Inf vector points towards the up;
% Technic All
x0 = 0;
nbCuts = 40;
options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton',...
    'MaxFunctionEvaluations',2500,'StepTolerance',1e-9,...
    'MaxIterations',2500,'OptimalityTolerance',1e-9,'Display','final-detailed');
x1_0 = fminunc(@(x)patRidge(x,PatPIACS,1,1,nbCuts),x0,options);
U_0 = [-sin(x1_0);cos(x1_0);0];


Z0 = V_all*U_0;

% It is assumed here that the patella in a stantardises position in the
% imaging device, so that Z0 point toward Superior direction
Z0 = sign( Z0(3) ) * Z0;

X0 = -V_all(:,3);
Y0 = cross(Z0,X0);

% Write Results
CSs.RAINBOW2013.X = X0;
CSs.RAINBOW2013.Y = Y0;
CSs.RAINBOW2013.Z = Z0;
CSs.RAINBOW2013.Theta = x1_0;
CSs.RAINBOW2013.V = [X0 Y0 Z0];
CSs.RAINBOW2013.Origin = CenterVol';

%% Identify initial guess of patella posterior ridge
% Optimization to find the ridge orientation
U0 = [1;0;0];
U = LSSLFitRidge( PatPIACS,U0,30);
% Refine the guess with higher number of slices (75)
[ U, ~ ,LowestPoints_PIACS ] = LSSLFitRidge( PatPIACS,U,75);
V = [U(2); -U(1); 0];


%% Seperate the ridge region from the apex region
% Move the lowest point to CS updated with initial ridge orientation PIACSU
LowestPoints_PIACSU = LowestPoints_PIACS*[U V [0;0;1]];

% Fit a piecewise linear funtion to the points : [ max(a.x+b , c.x+d) ]
fitresult = patRidgeFit(LowestPoints_PIACSU(:,1),LowestPoints_PIACSU(:,3));

% Find the intersection point
Xintrsctn = (fitresult.d-fitresult.b)/(fitresult.a-fitresult.c);

idx = rangesearch([LowestPoints_PIACSU(:,1),LowestPoints_PIACSU(:,3)],...
    [Xintrsctn,fitresult.a*Xintrsctn+fitresult.b],0.15*range(LowestPoints_PIACSU(:,1)));

[~,Imin] = min(LowestPoints_PIACSU(idx{1},3));

% Seperate an inferior and superior part
SizeInf = sum(LowestPoints_PIACSU(:,1) < Xintrsctn);
SizeSup = sum(LowestPoints_PIACSU(:,1) > Xintrsctn);

% Find the point in the updated PIA CS, ACS0
Xcut = LowestPoints_PIACSU(idx{1}(Imin),1);

% Get the ridge region start and end points
if SizeSup > SizeInf
    RidgePts = LowestPoints_PIACSU(LowestPoints_PIACSU(:,1) > Xintrsctn,:);
    StartDist = 1.1*(Xcut - min(LowestPoints_PIACSU(:,1)));
    EndDist = 0.05*range(LowestPoints_PIACSU(:,1));
    Side = +1;
else
    RidgePts = LowestPoints_PIACSU(LowestPoints_PIACSU(:,1) < Xintrsctn,:);
    EndDist = 1.1*(max(LowestPoints_PIACSU(:,1)) - Xcut);
    StartDist = 0.05*range(LowestPoints_PIACSU(:,1));
    Side = -1;
end


%% Update the ridge orienation with optimisation only on the ridge regioon
[ U, Uridge , LowestPoints_end ] = LSSLFitRidge( PatPIACS,U,75,StartDist, EndDist);
U = Side*U;

LowestPoints_CS0 = bsxfun(@plus,LowestPoints_end*V_all',Center');


%% Technic VR volume ridge
Z = V_all*U;
X = -V_all(:,3);
Y = cross(Z,X);

CSs.VR.X = X;
CSs.VR.Y = Y;
CSs.VR.Z = Z;
CSs.VR.Theta = -asin(U(1));
CSs.VR.V = [X Y Z];
CSs.VR.Origin = CenterVol';


%% Technic Ridge Line ( ridge Least Square line fit )
% LS line fit on the ridge and ridge midpoint
Uridge = sign(U'*Uridge)*Uridge;

% Construct RL ACS
Center3 = mean(LowestPoints_CS0);

Z3 = V_all*Uridge;
X3 = -V_all(:,3);
Y3 = normalizeV( cross(Z3,X3) );
X3 = cross(Y3,Z3);

% Write RL ACS
CSs.RL.X = X3;
CSs.RL.Uridge = Uridge;
CSs.RL.Y = Y3;
CSs.RL.Z = Z3;
CSs.RL.V = [X3 Y3 Z3];
CSs.RL.Origin = Center3;


%% Technic PIAAS
% Identify articular surface and get principal axis
LengthRidge = range(LowestPoints_CS0*Z3);
PtRidgeDist = LowestPoints_CS0(LowestPoints_CS0*Z3==min(LowestPoints_CS0*Z3),:);

% Select intial elements on the articular surface
Condition1 = abs(Patella.faceNormal*Z3)<0.23 ; %cos(pi/12);
Condition2 = Patella.faceNormal*X3>cos(pi/3);
Condition3 = Patella.incenter*Z3>PtRidgeDist*Z3-0.25*LengthRidge;

IgoodElmts = find(Condition1&Condition2&Condition3);

ArtSurf = TriReduceMesh(Patella,IgoodElmts);
ArtSurf0 = ArtSurf ;
ArtSurf = TriOpenMesh(Patella,ArtSurf,2);
ArtSurf = TriCloseMesh(Patella,ArtSurf,4);
ArtSurf = TriConnectedPatch(ArtSurf,LowestPoints_CS0);

% Fit a plane to the AS
[~,Nrml] = lsplane( ArtSurf.Points, X3 ); 

% Update conditions with fitted plane orientation
ArtSurfDilated = TriDilateMesh(Patella,ArtSurf,15);
Condition1 = abs(ArtSurfDilated.faceNormal*Z3)<0.375;
Condition2 = ArtSurfDilated.faceNormal*Nrml>cos(3*pi/10);
Condition3 = ArtSurfDilated.incenter*Z3>PtRidgeDist*Z3+0.15*LengthRidge & ...
   ArtSurfDilated.faceNormal*Nrml>0.5 ;

IgoodElmts = unique([find(Condition1&Condition2);find(Condition3)]);
ArtSurf = TriReduceMesh(ArtSurfDilated,IgoodElmts);

% Smooth found region with morphologic operations
ArtSurf = TriOpenMesh(Patella,ArtSurf,3);
ArtSurf = TriUnite(ArtSurf0,ArtSurf);
ArtSurf = TriCloseMesh(Patella,ArtSurf,2);
ArtSurf = TriConnectedPatch(ArtSurf,LowestPoints_CS0);
ArtSurf = TriCloseMesh(Patella,ArtSurf,30);
ArtSurf = TriOpenMesh(Patella,ArtSurf,15);
ArtSurf = TriErodeMesh(ArtSurf,2);
ArtSurf = TriCloseMesh(Patella,ArtSurf,5);


% Principal Inertia Matrix of the Articular Surface
[V_AS,~] = eig(TriCovMatrix(ArtSurf));
D4 = TriMesh2DProperties(ArtSurf);

% Construct PIAAS ACS
Origin = D4.Center;
Z4 = V_AS(:,2);
Z4 = sign(Uridge'*Z4)*Z4;

X4 = V_AS(:,1); 
X4 = -sign(V_all(:,3)'*X4)*X4;

Y4 = cross(Z4,X4);

% Write PIAAS ACS
CSs.PIAAS.X = X4;
CSs.PIAAS.Y = Y4;
CSs.PIAAS.Z = Z4;
CSs.PIAAS.V = V_AS;

CSs.PIAAS.Origin = Origin;
CSs.PIAAS.CenteronMesh = D4.onMeshCenter;


%% Export Identified Objects
if nargout > 1
    TrObjects.Patella = Patella;
    TrObjects.PatArtSurf = ArtSurf;
    TrObjects.RidgePts_Separated = LowestPoints_CS0;
    TrObjects.RidgePts_All = bsxfun(@plus,LowestPoints_PIACS,Center')*V_all';  
end
    

end

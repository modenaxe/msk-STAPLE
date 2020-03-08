



function [CS, ArtSurf] = ACS_patella_PIAAS(Patella, CS, Uridge, LowestPoints_CS0, CoeffMorpho, in_mm)

% check units
if nargin<6;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% inertia matrix
V_all = CS.V_all;

% Uridge in the initial (CT/MRI) coordinate system
UridgeR0 = V_all*Uridge;

% Construct RL ACS
Z3 = V_all*Uridge;
X3 = -V_all(:,3);
Y3 = normalizeV( cross(Z3,X3) );
X3 = cross(Y3,Z3);

% Technic PIAAS
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
ArtSurf = TriOpenMesh(Patella,ArtSurf, 2*CoeffMorpho);
ArtSurf = TriCloseMesh(Patella,ArtSurf, 4*CoeffMorpho);
ArtSurf = TriConnectedPatch(ArtSurf, LowestPoints_CS0);

% Fit a plane to the AS
[~,Nrml] = lsplane( ArtSurf.Points, X3 );

% Update conditions with fitted plane orientation
ArtSurfDilated = TriDilateMesh(Patella, ArtSurf, 15*CoeffMorpho);
Condition1 = abs(ArtSurfDilated.faceNormal*Z3)<0.375;
Condition2 = ArtSurfDilated.faceNormal*Nrml>cos(3*pi/10);
Condition3 = ArtSurfDilated.incenter*Z3>PtRidgeDist*Z3+0.15*LengthRidge & ...
    ArtSurfDilated.faceNormal*Nrml>0.5 ;

IgoodElmts = unique([find(Condition1&Condition2);find(Condition3)]);
ArtSurf = TriReduceMesh(ArtSurfDilated,IgoodElmts);

% Smooth found region with morphologic operations
ArtSurf = TriOpenMesh(Patella, ArtSurf, 3*CoeffMorpho);
ArtSurf = TriUnite(ArtSurf0, ArtSurf);
ArtSurf = TriCloseMesh(Patella, ArtSurf, 2*CoeffMorpho);
ArtSurf = TriConnectedPatch(ArtSurf, LowestPoints_CS0);
ArtSurf = TriCloseMesh(Patella, ArtSurf, 30*CoeffMorpho);
ArtSurf = TriOpenMesh(Patella, ArtSurf, 15*CoeffMorpho);
ArtSurf = TriErodeMesh(ArtSurf, 2*CoeffMorpho);
ArtSurf = TriCloseMesh(Patella, ArtSurf, 5*CoeffMorpho);


% Principal Inertia Matrix of the Articular Surface
[V_AS,~] = eig(TriCovMatrix(ArtSurf));
D4 = TriMesh2DProperties(ArtSurf);

% Construct PIAAS ACS
Origin = D4.Center;
Z4 = V_AS(:,2);
Z4 = sign(UridgeR0'*Z4)*Z4;

X4 = V_AS(:,1);
X4 = -sign( V_all(:,3)' * X4) * X4;

Y4 = cross(Z4, X4);

% % Write PIAAS ACS
% CSs.PIAAS.X = X4;
% CSs.PIAAS.Y = Y4;
% CSs.PIAAS.Z = Z4;
% CSs.PIAAS.V = V_AS;

% ISB
CS.patellofemoral_r.X = -X4;
CS.patellofemoral_r.Y = Z4;
CS.patellofemoral_r.Z = Y4;
CS.patellofemoral_r.V =[-X4 Z4 Y4];

CS.patellofemoral_r.Origin = Origin*dim_fact;
CS.patellofemoral_r.CenterOnMesh = D4.onMeshCenter*dim_fact;

quickPlotRefSystem(CS.patellofemoral_r)
end

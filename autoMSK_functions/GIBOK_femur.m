function [ CSs, TrObjects ] = GIBOK_femur( Femur , ProxFem)

% TODO: use a projectOnTo.m for lines like: Pts_0_C1*X1>PtNotch*X1
% TODO: I think there is a transformation back adn forth from VC that can
% be eliminated

% coordinate system structure to store results
CSs = struct();

% if this is an entire femur then cut it in two parts
% but keep track of all geometries
if ~exist('DistFem','var')
      [ProxFem, DistFem] = cutLongBoneMesh(Femur);
else
    % join two parts in one triangulation
    Femur = TriUnite(DistFem, ProxFem);
end

% Initial Coordinate system (from inertial axes and femoral head)
%-------------------------------------
% Z0: points upwards (inertial axis) 
% Y0: points medio-lat (from OT and Z0 in findFemoralHead.m)
% X0: used only in Kai2014
%-------------------------------------

% Get eigen vectors V_all of the Femur 3D geometry and volumetric center
[ V_all, CenterVol ] = TriInertiaPpties( Femur );

% Check that the distal femur is 'below' the proximal femur or invert Z0
Z0 = V_all(:,1);
Z0 = sign((mean(ProxFem.Points)-mean(DistFem.Points))*Z0)*Z0;

% store approximate Z direction and centre of mass of triangulation
CSs.Z0 = Z0;
CSs.CenterVol = CenterVol;
CSs.V_all = V_all;

% Find Femoral Head Center
% NB adds a CSs.Y0, (lateral)
[CSs, FemHead] = findFemoralHead(ProxFem, CSs);

% X0 points backwards
CSs.X0 = cross(CSs.Y0, CSs.Z0);

% Isolates the epiphysis
% TODO: replace with slicing function
%=========================================
% First 0.5 mm in Start and End are removed for stability.
Alt = linspace( min(DistFem.Points*Z0)+0.5 ,max(DistFem.Points*Z0)-0.5, 100);
Area= zeros(size(Alt));
it=0;
for d = -Alt
    it = it + 1;
    [ ~ , Area(it), ~ ] = TriPlanIntersect(DistFem, Z0 , d );
end
%=========================================

% removes mesh above the limit of epiphysis (Zepi)
[~ , Zepi, ~] = FitCSA(Alt, Area);
ElmtsEpi = find(DistFem.incenter*Z0<Zepi);
EpiFem = TriReduceMesh( DistFem, ElmtsEpi);

% extract full femoral condyles
[fullCondyle_Med, fullCondyle_Lat, CSs] = GIBOK_femur_ArticSurf(EpiFem, CSs, 'full_condyles');

% extract posterior part of condyles (points)
% by fitting an ellipse on long convexhull edges extremities
[postCondyle_Med_end, postCondyle_Lat_end, CSs] = GIBOK_femur_ArticSurf(EpiFem, CSs, 'post_condyles');

% extract patellar grooves
[Groove_Med, Groove_Lat, CSs] = GIBOK_femur_ArticSurf(EpiFem, CSs, 'pat_groove');

% Fit two spheres to patellar groove
CSs = createPatellaGrooveCoordSyst(Groove_Lat, Groove_Med, CSs);

% Fit two spheres on articular surfaces of posterior condyles
CSs = createFemurCoordSystSpheresOnCondyles(postCondyle_Lat_end, postCondyle_Med_end, CSs);

% Fit the posterior condyles with a cylinder
CSs = createFemurCoordSystCylinderOnCondyles(postCondyle_Lat_end, postCondyle_Med_end, CSs);

% Fit the entire condyles with an ellipsoid
CSs = createFemurCoordSystEllipsoidOnCondyles(fullCondyle_Lat, fullCondyle_Med, CSs);

% Store triangulation objects for output if required
if nargout>1
    TrObjects = struct();
    % store triangulations
    TrObjects.Femur         = Femur; % full femur
    TrObjects.ProxFem       = ProxFem; % proximal
    TrObjects.DistFem       = DistFem; % distal
    % store pieces used throughout the processing
    TrObjects.FemHead       = FemHead;
    TrObjects.EpiFem        = EpiFem;
    TrObjects.EpiFemASLat   = postCondyle_Lat_end;
    TrObjects.EpiFemASMed   = postCondyle_Med_end;
    TrObjects.PatGrooveLat  = Groove_Lat;
    TrObjects.PatGrooveMed  = Groove_Med;
end

end


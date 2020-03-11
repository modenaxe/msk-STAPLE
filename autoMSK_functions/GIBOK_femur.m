function [CS, JCS] = GIBOK_femur(Femur, DistFem, fit_method)

debug_plot = 1;
% coordinate system structure to store results
CS = struct();

% if this is an entire femur then cut it in two parts
% but keep track of all geometries
if ~exist('DistFem','var') || isempty(DistFem)
      [ProxFem, DistFem] = cutLongBoneMesh(Femur);
else
    % join two parts in one triangulation
    ProxFemur = Femur;
    Femur = TriUnite(ProxFemur, DistFem);
end

% default method is the cylinder fitting one as in Modenese et al. JBiomech
% 2018
if ~exist('method', 'var') || isempty(fit_method) || strcmp(fit_method, '')
    fit_method = 'cylinder';
end

% Get the mean edge length of the triangles composing the femur
% This is necessary because the functions were originally developed for
% triangulation with constant mean edge lengths of 0.5 mm
PptiesFemur = TriMesh2DProperties( Femur );

% Assume triangles are equilaterals
meanEdgeLength = sqrt( 4/sqrt(3) * PptiesFemur.TotalArea / Femur.size(1) );

% Get the coefficient for morphology operations
CoeffMorpho = 0.5 / meanEdgeLength ;

% Initial Coordinate system (from inertial axes and femoral head)
%-------------------------------------
% Z0: points upwards (inertial axis) 
% Y0: points medio-lat (from OT and Z0 in findFemoralHead.m)
%-------------------------------------

% Get eigen vectors V_all of the Femur 3D geometry and volumetric center
[ V_all, CenterVol ] = TriInertiaPpties( Femur );

% Check that the distal femur is 'below' the proximal femur or invert Z0
Z0 = V_all(:,1);
Z0 = sign((mean(ProxFem.Points)-mean(DistFem.Points))*Z0)*Z0;

% store approximate Z direction and centre of mass of triangulation
CS.Z0 = Z0;
CS.CenterVol = CenterVol;
CS.V_all = V_all;

% Find Femoral Head Center
% NB adds a CSs.Y0, (lateral)
[CS, FemHead] = fitSphere2FemHead_Renault2019(ProxFem, CS, CoeffMorpho);

% X0 points backwards
CS.X0 = cross(CS.Y0, CS.Z0);

% Isolates the epiphysis
EpiFem = GIBOK_isolate_epiphysis(DistFem, Z0, 'distal');

% extract full femoral condyles
[fullCondyle_Med, fullCondyle_Lat, CS] = GIBOK_femur_ArticSurf(EpiFem, CS, CoeffMorpho, 'full_condyles');

% extract posterior part of condyles (points)
% by fitting an ellipse on long convexhull edges extremities
[postCondyle_Med, postCondyle_Lat, CS] = GIBOK_femur_ArticSurf(EpiFem, CS,  CoeffMorpho, 'post_condyles');

% extract patellar grooves
[Groove_Med, Groove_Lat, CS] = GIBOK_femur_ArticSurf(EpiFem, CS, CoeffMorpho, 'pat_groove');

% Fit two spheres to patellar groove
quickPlotTriang(DistFem, [], 1); hold on
CS = CS_femur_SpheresOnPatellarGroove(Groove_Lat, Groove_Med, CS);

% how to compute the joint axes
switch fit_method
    case 'spheres'
        % Fit two spheres on articular surfaces of posterior condyles
        [CS, JCS] = CS_femur_SpheresOnCondyles(postCondyle_Lat, postCondyle_Med, CS);
    case 'cylinder'
        % Fit the posterior condyles with a cylinder
        [CS, JCS] = CS_femur_CylinderOnCondyles(postCondyle_Lat, postCondyle_Med, CS);
    case 'ellipsoids'
        % Fit the entire condyles with an ellipsoid
        [CS, JCS] = CS_femur_EllipsoidsOnCondyles(fullCondyle_Lat, fullCondyle_Med, CS);
    otherwise
        error('GIBOK_femur.m ''method'' input has value: ''spheres'', ''cylinder'' or ''ellipsoids''.')
end

% define segment ref system
CS.Origin = CenterVol;
CS.V = JCS.hip_r.V;

quickPlotTriang(Femur);hold on;
quickPlotRefSystem(CS);
quickPlotRefSystem(JCS.hip_r);
quickPlotRefSystem(JCS.knee_r);

% Store triangulation objects for output if required
% TODO: plot proximal femur as well
if debug_plot
    TrObjects = struct();
    % store triangulations
    TrObjects.Femur         = Femur; % full femur
    TrObjects.ProxFem       = ProxFem; % proximal
    TrObjects.DistFem       = DistFem; % distal
    % store pieces used throughout the processing
    TrObjects.FemHead       = FemHead;
    TrObjects.EpiFem        = EpiFem;
    TrObjects.EpiFemASLat   = postCondyle_Lat;
    TrObjects.EpiFemASMed   = postCondyle_Med;
    TrObjects.PatGrooveLat  = Groove_Lat;
    TrObjects.PatGrooveMed  = Groove_Med;
    
    % plot nicely with GIBOK function
    PlotFemur(CS, TrObjects )
end

end


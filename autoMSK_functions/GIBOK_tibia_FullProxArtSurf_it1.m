function [EpiTibAS, oLSP,Ztp] = GIBOK_tibia_FullProxArtSurf_it1(EpiTib, CSs, angle_thresh, curv_quartile)

% 1) identify surface
% 2) fit plane 
% 3) fit ellipse
% 4) get points accordingly for AS

Z0 = CSs.Z0;
Y0 = CSs.Y0;

% Get curvature "intensity"
[Cmean,Cgaussian]=TriCurvature(EpiTib,false);
Curvtr = sqrt(4*Cmean.^2-2*Cgaussian);

% Keep only the elements that respect both criteria :
%   1) Make an angle inferior to 35° with Z0
%   2) Within the 1st quartile of curvature "intensity"
NodesEpiAS_OK = find(rad2deg(acos(EpiTib.vertexNormal*Z0))<angle_thresh &...
                     Curvtr<quantile(Curvtr, curv_quartile)) ;

% fit a LS plane oriented in the same direction as Z0
% subsequent operation will be on this plane [LM]
Pcondyle = EpiTib.Points(NodesEpiAS_OK,:);
[oLSP,Ztp] = lsplane(Pcondyle, Z0);

% Smooth resulting surface
EpiTibAS = TriReduceMesh( EpiTib, [] , NodesEpiAS_OK );
EpiTibAS = TriCloseMesh( EpiTib, EpiTibAS, 6 );
 
% Fit an ellipse on proximal AS to get an initial Ml and AP axis
[ Xel, Yel, ellipsePts , ellipsePpties] = EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP );
a = ellipsePpties.a;
b = ellipsePpties.b;
Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Y0'*Yel)*Yel;

% Compute seed points to get a patch of AS on each condyle
MedPtsInit = mean(ellipsePts) + 2/3*b*Yel';
MedPtsInit = [  MedPtsInit; 
                MedPtsInit - 1/3*a*Xel'; 
                MedPtsInit + 1/3*a*Xel'];
EpiTibASMed = TriConnectedPatch( EpiTibAS, MedPtsInit );

LatPtsInit = mean(ellipsePts) - 2/3*b*Yel';
LatPtsInit = [  LatPtsInit; 
                LatPtsInit - 1/3*a*Xel'; 
                LatPtsInit + 1/3*a*Xel'];
EpiTibASLat = TriConnectedPatch( EpiTibAS, LatPtsInit );

% Update the AS 
EpiTibAS = TriUnite(EpiTibASMed, EpiTibASLat);

end
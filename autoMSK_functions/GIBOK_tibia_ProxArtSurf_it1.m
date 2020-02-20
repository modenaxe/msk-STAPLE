function EpiTibAS = GIBOK_tibia_ProxArtSurf_it1(ProxTib, EpiTibAS, CSs, Ztp , oLSP)

Z0 = CSs.Z0;
Y0 = CSs.Y0;

% using an ellipse fit keep only the part of the artic surf where the
% femoral condyle touch

% fit ellipsoid
[ Xel, Yel, ellipsePts, ellipsePpties] = EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP);
ELP1.a = ellipsePpties.a;
ELP1.b = ellipsePpties.b;
ELP1.Xel = sign(Xel'*Y0)*Xel ;
ELP1.Yel = sign(Yel'*Y0)*Yel ;
ELP1.ellipsePts = ellipsePts;

% remove area between ridges
EpiTibCenterRidgeMed = GIBOK_tibia_removePartBetweenRidges_it1(ProxTib, EpiTibAS, CSs, ELP1, Ztp , 'medial');
EpiTibCenterRidgeLat = GIBOK_tibia_removePartBetweenRidges_it1(ProxTib, EpiTibAS, CSs, ELP1, Ztp , 'lateral');
EpiTibCenterRidge    = TriUnite(EpiTibCenterRidgeLat,EpiTibCenterRidgeMed);

% Remove between ridge points from identified AS points
EpiTibAS = TriDifferenceMesh(EpiTibAS , EpiTibCenterRidge);

% debug
quickPlotTriang(EpiTibAS);hold on
quickPlotTriang(EpiTibCenterRidge,'r')

%% Refine and separete medial and lateral AS region
% Compute seed points to get a patch of AS on each condyle
MedPtsInit = mean(ellipsePts) + 2/3*ELP1.b*ELP1.Yel';
LatPtsInit = mean(ellipsePts) - 2/3*ELP1.b*ELP1.Yel';

% not on the surface
plot3(MedPtsInit(1), MedPtsInit(2), MedPtsInit(3),'ro','LineWidth',3); hold on
plot3(LatPtsInit(1), LatPtsInit(2), LatPtsInit(3),'bo','LineWidth',3); hold on

MedPtsInit = [  MedPtsInit; 
                MedPtsInit - 1/3*ELP1.a*ELP1.Xel';  
                MedPtsInit + 1/3*ELP1.a*ELP1.Xel'];
LatPtsInit = [  LatPtsInit; 
                LatPtsInit - 1/3*ELP1.a*ELP1.Xel'; 
                LatPtsInit + 1/3*ELP1.a*ELP1.Xel'];
EpiTibAS = TriConnectedPatch(EpiTibAS , [MedPtsInit ; LatPtsInit] );

quickPlotTriang(EpiTibAS, 'g', 1);hold on

end
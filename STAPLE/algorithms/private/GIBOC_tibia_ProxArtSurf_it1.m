%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault. 
%  Modified by Luca Modenese based on GIBOC-knee prototype.
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function EpiTibAS = GIBOC_tibia_ProxArtSurf_it1(ProxTib, EpiTib, EpiTibAS, CSs, Ztp , oLSP, CoeffMorpho)

Z0 = CSs.Z0;
Y0 = CSs.Y0;
% decide if to plot intermediate step. Left manual switch as function is
% deeply nested.
debug_plots = 0;

% using an ellipse fit keep only the part of the artic surf where the
% femoral condyle touch

% fit ellipsoid
[ Xel, Yel, ellipsePts, ellipsePpties] = fitEllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP);
ELP1.a = ellipsePpties.a;
ELP1.b = ellipsePpties.b;
ELP1.Xel = -sign(Xel'*Y0)*Xel ; % Post to Ant
ELP1.Yel = -sign(Yel'*Y0)*Yel ; % Lat to Med
ELP1.ellipsePts = ellipsePts;

% remove area between ridges
EpiTibCenterRidgeMed = GIBOC_tibia_removePartBetweenRidges_it1(ProxTib, EpiTib, CSs, CoeffMorpho, ELP1, Ztp , 'medial');
EpiTibCenterRidgeLat = GIBOC_tibia_removePartBetweenRidges_it1(ProxTib, EpiTib, CSs, CoeffMorpho, ELP1, Ztp , 'lateral');

% if there is no area to be removed keep EpiTibAS as it was, otherwise
% remove that area
if ~isempty(EpiTibCenterRidgeMed) || ~isempty(EpiTibCenterRidgeLat)
    EpiTibCenterRidge    = TriUnite(EpiTibCenterRidgeLat,EpiTibCenterRidgeMed);
    % Remove between ridge points from identified AS points
    EpiTibAS = TriDifferenceMesh(EpiTibAS , EpiTibCenterRidge);
    % debug
    if debug_plots == 1
        quickPlotTriang(EpiTibAS);hold on
        quickPlotTriang(EpiTibCenterRidge,'r')
    end
end


%% Refine and separate medial and lateral AS region
% Compute seed points to get a patch of AS on each condyle
MedPtsInit = mean(ellipsePts) + 2/3*ELP1.b*ELP1.Yel';
LatPtsInit = mean(ellipsePts) - 2/3*ELP1.b*ELP1.Yel';

% refine from seeds
MedPtsInit = [  MedPtsInit; 
                MedPtsInit - 1/3*ELP1.a*ELP1.Xel';  
                MedPtsInit + 1/3*ELP1.a*ELP1.Xel'];
LatPtsInit = [  LatPtsInit; 
                LatPtsInit - 1/3*ELP1.a*ELP1.Xel'; 
                LatPtsInit + 1/3*ELP1.a*ELP1.Xel'];

EpiTibAS = TriConnectedPatch(EpiTibAS , [MedPtsInit ; LatPtsInit] );

% not on the surface
if debug_plots == 1
    quickPlotTriang(EpiTibAS);hold on
    plot3(MedPtsInit(1), MedPtsInit(2), MedPtsInit(3),'ro','LineWidth',3); hold on
    plot3(LatPtsInit(1), LatPtsInit(2), LatPtsInit(3),'bo','LineWidth',3); hold on
end

end
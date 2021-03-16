function [ TibiaElmtsIDOK ] = ankleSurfFit( TR_AnkleSurf, TR_Tibia, V )
%Find the ID of the elements of the distal tibia that lies on a +/- 1 mm poly22 fit of a initial estimate of
%the surface (TR_AnkleSurf)

%   Detailed explanation goes here


PointsArtSurf0 = TR_AnkleSurf.Points*V;
PointsDistTib = TR_Tibia.incenter*V;

PointsDistTib = bsxfun(@minus, PointsDistTib ,mean(PointsArtSurf0)); 
PointsArtSurf0 = bsxfun(@minus, PointsArtSurf0, mean(PointsArtSurf0));

X=PointsArtSurf0(:,2);Y=PointsArtSurf0(:,3);Z=PointsArtSurf0(:,1);
[xData, yData, zData] = prepareSurfaceData( X, Y, Z );
% Set up fittype and options.
ft = fittype( 'poly22' );
% Fit model to data.
[fitresult, ~] = fit( [xData, yData], zData, ft );

distZ = abs(fitresult(PointsDistTib(:,2),PointsDistTib(:,3))-PointsDistTib(:,1));
TibiaElmtsIDOK = find(distZ<1.05);

end


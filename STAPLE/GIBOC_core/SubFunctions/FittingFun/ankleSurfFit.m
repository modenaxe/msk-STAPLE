% ANKLESURFFIT Find the ID of the elements of the distal tibia that 
% lies within 1 mm to a poly22 fit of a initial estimate of the surface.
%
% This function only identify the part of the tibial articular surface
% that is perpendicalar to the long axis of the tibia (ie. the inferior
% articular surface of the tibia). The articular surface of the medial
% malleolus is not identified.
%
% [ TibiaElmtsIDOK ] = ankleSurfFit( TR_AnkleSurf, TR_Tibia, V )
%
%
% Inputs:
%   TR_AnkleSurf - An initial estimation of the inferior articular
%                  surface of the tibia
%   TR_Tibia - The geometry of the distal tibia.
%   V - The eigen vectors of the pseudo inertia-matrix of the whole tibia. 
%
% Outputs:
%   TibiaElmtsIDOK - Element Id of all elements from TR_Tibia identified to
%                    be part of the updated inferior articular surface.
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2019 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ TibiaElmtsIDOK ] = ankleSurfFit( TR_AnkleSurf, TR_Tibia, V )


% Express the surface in the eigen vectors basis
PointsArtSurf0 = TR_AnkleSurf.Points*V;
PointsDistTib = TR_Tibia.incenter*V;

PointsDistTib = bsxfun(@minus, PointsDistTib ,mean(PointsArtSurf0)); 
PointsArtSurf0 = bsxfun(@minus, PointsArtSurf0, mean(PointsArtSurf0));

X = PointsArtSurf0(:, 2); Y = PointsArtSurf0(:, 3); Z = PointsArtSurf0(:, 1);
[xData, yData, zData] = prepareSurfaceData( X, Y, Z );
% Set up fittype and options.
ft = fittype( 'poly22' );
% Fit model to data.
[fitresult, ~] = fit( [xData, yData], zData, ft );

distZ = abs( fitresult(PointsDistTib(:, 2), PointsDistTib(:, 3)) - PointsDistTib(:,1) );
TibiaElmtsIDOK = find(distZ<1.05);

end


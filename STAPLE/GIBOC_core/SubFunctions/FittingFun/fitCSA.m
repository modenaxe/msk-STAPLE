% FITCSA Create a fit of the evolution of the cross section area.
% 1st step is to fit a double gaussian on the curve
% 2nd step is to use the result of the first fit to initialize a 2nd
% fit of a gaussian plus an affine function : a1*exp(-((x-b1)/c1)^2)+d*x+e
%
% Separate the diaphysis based on the hypothseis that its long axis cross section
% area evolve pseudo linearly along its diaphysis while the variation are
% more bell-shaped for the epiphysis region.
%
% It is assumed that the cross-sections are calculated on a cutted long bone
% that have a part of the diaphysis and a single full epiphysis. 
%
%   [Zdiaph, Zepi, or] = fitCSA(Z, Area)
%
% Inputs:
%   Z - The distance to origin of each cross section center when projected 
%       onto the bone long axis.
%   Area - The cross section areas of the bone along the bone long axis.
%
% Outputs:
%   Zdiaph - The value of Z for at which the diaphysis is estimated to ends.
%   Zepi - The value of Z for at which the epiphysis is estimated to starts.
%   or - The orientation of the bone. -1 if the ephysis is the distal one.
%        1 if the epiphysis is the proximal one 
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2019 Jean-Baptiste Renault
%-------------------------------------------------------------------------%

function [Zdiaph, Zepi, or] = fitCSA(Z, Area)
	% FITCSA Create a fit of the evolution of the cross section area
	% 1st step is to fit a double gaussian on the curve 
	% 2nd step is to use the result of the first fit to initialize a 2nd
	% fit of a gaussian plus an affine function : a1*exp(-((x-b1)/c1)^2)+d*x+e
	% Separate the diaphysis based on the hypothseis that its long axis cross section
	% area evolve pseudo linearly along its diaphysis while the variation are
	% more bell-shaped for the epiphysis region
	%
	% It is assumed that the cross-sections are calculated on a cutted long bone
	% that have a part of the diaphysis and a single full epiphysis. 
	%
	% Parameters
	% ----------
	% Z : __TYPE__
	% 	The distance to origin of each cross section center when projected 
	% 	 onto the bone long axis.
	% Area : __TYPE__
	% 	The cross section areas of the bone along the bone long axis
	%
	% Returns
	% -------
	% Zdiaph : __TYPE__
	% 	The value of Z for at which the diaphysis is estimated to ends.
	% Zepi : __TYPE__
	% 	The value of Z for at which the epiphysis is estimated to starts.
	% or : __TYPE__
	% 	The orientation of the bone. -1 if the ephysis is the distal one.
	% 	 +1 if the epiphysis is the proximal one
	%
    %

	
	
	Z0 = mean(Z);
	Z = Z - Z0;
	
	Area = Area/mean(Area);
	
	[AreaMax,Imax] = max(Area);
	
	% Orientation of bone along the z axis
	if Z(Imax)<mean(Z) 
	    or = -1; % The epiphysis is distal
	else
	    or = 1; % The epihysis is proximal
	end
	
	
	[xData, yData] = prepareCurveData( Z, Area );
	
	% Set up fittype and options.
	ft = fittype( 'gauss2' );
	opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
	opts.Display = 'Off';
	opts.Lower = [-Inf -Inf 0 -Inf -Inf 0];
	
	opts.StartPoint = [max(AreaMax) Z(Imax) 20 mean(Area) mean(Z) 75];
	
	% Fit model to data.
	[fitresult, ~] = fit( xData, yData, ft, opts );
	% 
	% Plot fit with data.
	% figure( 'Name', 'Area vs. Z' );
	% h = plot( fitresult, xData, yData );
	% legend( h, 'Area vs. Z', 'Gauss2 fit', 'Location', 'NorthEast' );
	% % Label axes
	% xlabel Z
	% ylabel Area
	% grid on
	
	
	%% Fit: 'untitled fit 1'.
	[xData, yData] = prepareCurveData( Z, Area );
	
	% Set up fittype and options.
	ft = fittype( 'a1*exp(-((x-b1)/c1)^2)+d*x+e', 'independent', 'x', 'dependent', 'y' );
	opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
	opts.Display = 'Off';
	opts.Robust = 'Off';
	opts.StartPoint = [fitresult.a1 fitresult.b1 fitresult.c1 0 mean(Z)];
	
	% Fit model to data.
	[fitresult, ~] = fit( xData, yData, ft, opts );
	
	
	% Distance to linear part
	Dist2linear = Area - (fitresult.d*Z + fitresult.e);
	
	Zkept = Z(abs(Dist2linear)<abs(0.1*median(Area)));
	Zkept(end)=[];
	Zkept(1)=[];
	Zkept(end)=[];
	Zkept(1)=[];
	
	
	% Plot fit with data.
	% figure( 'Name', 'Gaussian + Affine fit' );
	% h = plot( fitresult, xData, yData );
	% legend( h, 'Area vs. Z', 'Gauss + Affine fit', 'Location', 'NorthEast' );
	% hold on
	% plot(Z,Z*fitresult.d+fitresult.e,'k-')
	% plot(Z(abs(Dist2linear)<abs(0.1*median(Area))),Area(abs(Dist2linear)<abs(0.1*median(Area))),'ks')
	% Label axes
	% xlabel Z
	% ylabel Area
	% grid on
	% 
	% 
	
	
	% AreaKept = Area(abs(Dist2linear)<abs(0.05*fitresult.e))
	% The End of the diaphysis correspond to the "end" of the gaussian curve
	% (outside the 95 %) of the gaussian curve surface
	
	if or==-1
	    ZStartDiaphysis = max(Zkept);
	elseif or==1
	    ZStartDiaphysis = min(Zkept);
	end
	
	ZendDiaphysis = fitresult.b1 - 3*or*fitresult.c1;
	Zdiaph = Z0 + [ZStartDiaphysis;ZendDiaphysis];
	
	ZStartEpiphysis = fitresult.b1 - 1.5*or*fitresult.c1;
	
	Zepi = Z0 + ZStartEpiphysis;
	
	end
	
	

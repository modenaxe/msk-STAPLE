% PATRIDGEFIT Allow to seperate the patellar apex and patetella 
% articular surfaces thanks to a non-linear fit of the most 
% posterior points of the posterior facet of the patella.
% 
% This separation allow to know where the superior and 
% inferior regions of the patella are located. Thanks to that, 
% we will be able to ensure that the patella distral to proximal
% axis is  oriented from inferior to superior.
% 
% see page 228 of my thesis https://www.theses.fr/2019AIXM0636/document
% 
% [fitresult, gof] = patRidgeFit(AX, AY)
%
% 
% Inputs :
%   AX - Pseudo inferior to superior coordinates of the most posterior points
%        of each slice.
% 
%   AY - Anterior to posterior coordinates of the most posterior points
%        of each slice.

%   nbSlice - (int) The number of slice to make along the patella inferior to 
%             superior axis. On those slices the most posterior points will be 
%             identified as points belonging to the patella articular surface
%             ridge.
% 
%   startDist - (float, optional) The relative distance from the inferior limit 
%               of the patella from which to start slicing. Default to 2.5% of 
%               the inferior to superior patella length.
% 
%   endDist - (float, optional) The relative distance from the superior limit 
%               of the patella from which to end the slicing. Default to 2.5% of 
%               the inferior to superior patella length.
% 
%   debug_plots - (boolean, optional)n to plot or not the fit.
%
% Outputs : 
%   U - The updated vector of the patella ridge line direction
%
%   Uridge - The direction of the least square line fitted onto the points
%            identified on the ridge line.
%   LowestPoints - The set of points identified to be on the ridge line.



function [fitresult, gof] = patRidgeFit(AX, AY)
	% PATRIDGEFIT Allow to seperate the patellar apex and patetella 
	% articular surfaces thanks to a non-linear fit of the most 
	% posterior points of the posterior facet of the patella
	%
	% This separation allow to know where the superior and 
	% inferior regions of the patella are located. Thanks to that, 
	% we will be able to ensure that the patella distral to proximal
	% axis is  oriented from inferior to superior.

	% see page 228 of my thesis https://www.theses.fr/2019AIXM0636/document
	%
	% Parameters
	% ----------
	% AX : __TYPE__
	% 	Pseudo inferior to superior coordinates of the most posterior points
	% 	 of each slice.
	% 	 
	% AY : __TYPE__
	% 	Anterior to posterior coordinates of the most posterior points
	% 	 of each slice
	%
	% Returns
	% -------
	% fitresult : __TYPE__
	% 	__DESCRIPTION__
	% gof : __TYPE__
	% 	__DESCRIPTION__
	%
	%

	
	Size = round(length(AX)/4);
	
	AX1 = AX(3:3+Size); AY1 = AY(3:3+Size);
	XX1 = [AX1 ones(size(AX1))];
	C1 = pinv(XX1)*AY1;
	
	AY2 = AY(end-(Size+2):end-2); AX2 = AX(end-(Size+2):end-2);
	XX2 = [AX2 ones(size(AX2))];
	C2 = pinv(XX2)*AY2;
	
	
	
	%% Fit: 'untitled fit 1'.
	[xData, yData] = prepareCurveData( AX, AY );
	
	% Set up fittype and options.
	ft = fittype( 'max(a*x+b,c*x+d)', 'independent', 'x', 'dependent', 'y' );
	opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
	opts.Display = 'Off';
	options.MaxFunctionEvaluations = 500;
	opts.Lower = [-20 -inf -10 -Inf];
	opts.Robust = 'Bisquare';
	opts.StartPoint = [C1(1) C1(2) C2(1) C2(2)];
	opts.Upper = [20 +inf 10 Inf];
	
	% Fit model to data.
	[fitresult, gof] = fit( xData, yData, ft, opts );
	% 
	% % Plot fit with data.
	% figure( 'Name', 'untitled fit 1' );
	% h = plot( fitresult, xData, yData );
	% legend( h, 'AY vs. AX', 'untitled fit 1', 'Location', 'NorthEast' );
	% % Label axes
	% xlabel AX
	% ylabel AY
	% grid on
	% hold on
	
	

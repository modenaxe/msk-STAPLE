% FITCSATALUS Create a fit of the evolution of the cross section area :
%   1st step is to fit a double gaussian on the Area = f(Alt) curve 
%   2nd step is to identify the anterior and the posterior parts. This
%   provide us with the orientation of the talus. It is a prerequisite to
%   the automatic identification of talus articular surfaces.
%
%   [or, alt_TlNvc_start, alt_TlNeck_start, alt_TlTib_start] =  ...
%                                        fitCSATalus(Alt, Area, debug_plots)
%
% Inputs:
%   Alt - The distance to origin of each cross section center when projected 
%         onto the talus long axis (distal to proximal, ie. anterior to posterior).
%   Area - The cross section areas of the talus along the long axis.
%
%   debug_plots - Display debug plot.
%
% Outputs:
%   or - The orientation of the talus. (__TO_BE_PRECISED__)
%
%   alt_TlNvc_start - gives the altitude along X0 at wich the CSA is maximal
%                     and where the TaloNavicular (TlNvc) articular surface
%                     could start.
%   
%   alt_TlNeck_start - gives the altitude along x0 at the approximate start
%                      of talus neck
%
%   alt_TlTib_start - gives the altitude along X0 at wich articular surface
%                     with the tibia can start
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%

function [or, alt_TlNvc_start, alt_TlNeck_start, alt_TlTib_start] = fitCSATalus(Alt, Area, debug_plots)
	% FITCSATALUS Create a fit of the evolution of the cross section area :
	%   1st step is to fit a double gaussian on the Area = f(Alt) curve 
	%   2nd step is to identify the anterior and the posterior parts. This
	%   provide us with the orientation of the talus. It is a prerequisite to
	%   the automatic identification of talus articular surfaces
	%
	% 
	%
	% Parameters
	% ----------
	% Alt : __TYPE__
	% 	The distance to origin of each cross section center when projected 
	% 	 onto the talus long axis (distal to proximal, ie. anterior to posterior).
	% Area : __TYPE__
	% 	The cross section areas of the talus along the long axis
	% debug_plots : boolean
	% 	Display debug plot
	%
	% Returns
	% -------
	% or : __TYPE__
	% 	The orientation of the talus. (__TO_BE_PRECISED__
	% alt_TlNvc_start : __TYPE__
	% 	gives the altitude along X0 at wich the CSA is maximal
	% 	 and where the TaloNavicular (TlNvc) articular surface
	% 	 could start.
	% 	 
	% alt_TlNeck_start : __TYPE__
	% 	gives the altitude along x0 at the approximate start
	% 	 of talus nec
	% alt_TlTib_start : __TYPE__
	% 	gives the altitude along X0 at wich articular surface
	% 	 with the tibia can star
	%
	%

	
	
	if nargin<3
	    debug_plots = 0 ;
	end
	%% Discard data from the borders
	Length = range(Alt);
	Alt(Area<0.2*max(Area))=[];
	Area(Area<0.2*max(Area))=[];
	
	
	
	%% Fit: 'untitled fit 1'.
	[xData, yData] = prepareCurveData( Alt, Area );
	
	% Set up fittype and options.
	ft = fittype( 'gauss2' );
	opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
	opts.Display = 'Off';
	
	% Ensure that the fit is the sum of two gaussian with positive scale factor
	opts.Lower = [0.1*max(Area) -Inf 0 0.1*max(Area) -Inf 0];
	
	% Make sure that the fit doesn't yield gaussians too flat by setting the
	% upper boundary of sigma parameters to 20% of the talus length along
	% the axis
	opts.Upper = [10*max(Area) +Inf 0.20*Length 10*max(Area) +Inf 0.20*Length];
	
	
	% Fit model to data.
	[fitresult, gof] = fit( xData, yData, ft, opts );
	
	% % Plot fit with data.
	if debug_plots == 1
	    figure( 'Name', 'untitled fit 1' );
	    h = plot( fitresult, xData, yData );
	    legend( h, 'Area vs. Alt', 'untitled fit 1', 'Location', 'NorthEast' );
	    % Label axes
	    xlabel Alt
	    ylabel Area
	    grid on
	end
	
	% [LM] when this test fails the diretion of X is inverted and talus is not
	% analysed correctly
	% Orientation of bone along the y axis
	or_test_a = fitresult.a1 < fitresult.a2 ;
	or_test_b = fitresult.b1 < fitresult.b2 ;
	if or_test_a
	    alt_TlNvc_start = fitresult.b1;
	    or = - 2*or_test_b + 1; % implicit logical to int conversion
	    alt_TlTib_start = or*(fitresult.b2 - or*1.0*fitresult.c2);
	%     disp('test a1 < a2')
	%     disp(fitresult.b2)
	else
	    alt_TlNvc_start = fitresult.b2;
	    or = 2*or_test_b - 1; % implicit logical to int conversion
	    alt_TlTib_start = or*(fitresult.b1 - or*1.0*fitresult.c1);
	%     disp('test a1 > a2')
	%     disp(alt_TlTib_start)
	end
	
	% Values along the length of the Talus
	alt_TlNvc_start = or*alt_TlNvc_start;
	
	% Neck start is the middle point between the two summits of the fit
	alt_TlNeck_start = 0.5*or*(fitresult.b1 + fitresult.b2);
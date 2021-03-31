function [or, alt_TlNvc_start, alt_TlNeck_start, alt_TlTib_start] = fitCSATalus(Alt, Area, debug_plots)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      Alt
%      Area
%  Output:
%   alt_TlNvc_start, gives the altitude along X0 at wich the CSA is maximal
%   and where the TaloNavicular (TlNvc) articular surface could start.
%   
%   alt_TlNeck_start, gives the altitude along x0 at the approximate start
%   of talus neck
%
%   alt_TlTib_start, gives the altitude along X0 at wich articular surface
%   with the tibia can start
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

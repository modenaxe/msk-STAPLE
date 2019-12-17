function [fitresult, gof] = patRidgeFit(AX, AY)
% PATRIDGEFIT 
%
% initial guess by looking at first and last offsetted quarter of points at the start and the end of the X-axis 
% Least-Square affine function fit on each quarter
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



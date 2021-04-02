% LSSLFITPATELLARIDGELEAST Square Straight Line Fit on Patellar Ridge
% To obtain the direction of the ridge a Least Square Straight Line is
% fitted on the lowest points on slices of normal U, and the normal U is
% updated until convergence (of U or number of iterations > 100)
% U is the vector ~aligned with the ridge
%
% Least Square Straight Line Fit on Patellar Ridge
% 
% To obtain the direction of the ridge a Least Square Straight Line is
% fitted on the lowest points on slices of normal U, and the normal U is
% updated until convergence of U (or number of iterations > 100)
%
%
%  [U, Uridge, LowestPoints] = LSSLFitPatellaRidge(patellaTri, U,...
%                                  nbSlice, startDist, endDist, debug_plots)
% Inputs :
%   Tr - (Triangulation) The triangulation object of the Patella
% 
%   U - ([3x1] vector) The initial vector of the patella ridge line direction
% 
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
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese & Jean-Baptiste Renault. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [U, Uridge, LowestPoints] = LSSLFitPatellaRidge(   patellaTri,...
                                                            U,...
                                                            nbSlice,...
                                                            startDist,...
                                                            endDist,...
                                                            debug_plots)

% initialization
if nargin<3; nbSlice = 50;                                 end
if nargin<4; startDist = 0.025*range(patellaTri.Points*U); end %Offset distance from first points
if nargin<5; endDist = startDist;                          end %Offset distance from last points
if nargin<6; debug_plots=0;                                 end

% initialize fitting
U0 = U;
U_old = [0;0;0];
k=0; 
test = true;
while test && k < 100 % Cut at 100 iterations (convergence generally occuring before 10)
    k=k+1;
    % points along U where the slices will be performed
    Alt = linspace( min(patellaTri.Points*U)+startDist , max(patellaTri.Points*U)-endDist, nbSlice);
    LowestPoints = zeros(length(Alt),3);
    % slice patella along U
    i=0;
    for d = -Alt
        i=i+1;
        [ Curves , ~ , ~ ] = TriPlanIntersect( patellaTri, U , d );
        EdgePts = vertcat(Curves(:).Pts);
        [~,lowestPointID] = min(EdgePts(:,3));
        LowestPoints(i,:) = EdgePts(lowestPointID(1),:);
        if debug_plots == 1
            title('Slicing and LowerPoints on AS')
            quickPlotTriang(patellaTri);
            plot3(Curves(:).Pts(:,1), Curves(:).Pts(:,2), Curves(:).Pts(:,3),'k'); hold on
            plot3(LowestPoints(:,1), LowestPoints(:,2), LowestPoints(:,3),'r'); hold on
            axis equal
        end
    end
    
    % updating direction of U usign the variance of the patellar ridge path
    [Vridge_all,~] = eig(cov(LowestPoints));
    
    % vector describing the direction of the ridge
    Uridge = sign(U0'*Vridge_all(:,3))*Vridge_all(:,3);
    
    % the vector will be in the XY plane where the patella is a "circle"
    % third component = 0
%     U = Uridge;
%     U(3) = 0; 
    U = normalizeV([Uridge(1:2); 0]);
    
    % how much the vector is changing in direction
    U_old(1:3,end+1) = U;
    test = U_old(1:3,end-1)'*U_old(1:3,end) > (1 - 100*eps);
end

% debug plots
if debug_plots == 1
    figure()
    title('Final vector of ridge')
    trisurf(patellaTri,'facecolor','red','faceAlpha',0.5)
    hold on;    grid off;     axis equal;
    LocalCS        = struct();
    LocalCS.Origin = [0 0 0]';
    LocalCS.V      = eye(3);
    quickPlotRefSystem(LocalCS);
    
    % plot trace of points on the proximal surface
    pl3t(LowestPoints,'gs')
    plotArrow( U, 1.5, mean(LowestPoints), 30, 1, 'k')
    plotArrow( Uridge, 1.5, mean(LowestPoints), 50, 1, 'c')
    hold off
end

end


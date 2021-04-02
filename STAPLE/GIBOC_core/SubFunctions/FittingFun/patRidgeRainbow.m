% PATRIDGE Calculate the dispersion of the projection of 
% the points currently identified as the most posterior points
% on slices taken along the patella following U direction.
%
% This function is called in an optimizer whose goal is to minimize 
% the dispersion by finding the best direction U. The best direction U
% is then assumed to be the inferior to superior axis. 
%
% see Rainbow et al. 2013, J Biomech.  10.1016/j.jbiomech.2013.05.024
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3729621/pdf/nihms486842.pdf 
% 
% 
% [ PatRidgeVariability] = patRidgeRainbow( x, triMesh , StartDist, EndDist, nbSlice)
%
% 
% Inputs:
%   AX - Pseudo inferior to superior coordinates of the most posterior points
%        of each slice.
% 
%   AY - Anterior to posterior coordinates of the most posterior points
%        of each slice.
%
%   nbSlice - (int) The number of slice to make along the patella inferior to 
%             superior axis. On those slices the most posterior points will be 
%             identified as points belonging to the patella articular surface
%             ridge.
% 
%   startDist - (float, optional) The absolute distance from the inferior limit 
%               of the patella from which to start slicing. Default to 5% of 
%               the inferior to superior patella length.
% 
%   endDist - (float, optional) The ansolute distance from the superior limit 
%               of the patella from which to end the slicing. Default to 5% of 
%               the inferior to superior patella length.
% 
%   debug_plots - (boolean, optional)n to plot or not the fit.
%
% Outputs : 
%   PatRidgeVariability - The dispersion of the projection of the points currently
%                         identified as the most posterior points on slices taken
%                         along the patella.  



function [ PatRidgeVariability] = patRidgeRainbow( x, triMesh , StartDist, EndDist, nbSlice)

	
	V = [cos(x);sin(x);0];
	U = [-sin(x);cos(x);0];
	
	
	if nargin<3
	    StartDist = 0.05*range(triMesh.Points*U);
	    EndDist = 0.05*range(triMesh.Points*U);
	    nbSlice = 50;
	end
	
	if StartDist<=0 || EndDist<=0
	    StartDist = 0.05*range(triMesh.Points*U);
	    EndDist = 0.05*range(triMesh.Points*U);
	end
	
	if nbSlice < 5
	    Alt = min(triMesh.Points*U)+StartDist:1:max(triMesh.Points*U)-EndDist;
	else
	    Alt = linspace( min(triMesh.Points*U)+StartDist ,max(triMesh.Points*U)-EndDist, nbSlice);
	end
	LowestPoints = zeros(length(Alt),3);
	i=0;
	
	% figure(15)
	for d = -Alt
	    i=i+1;
	    
	    [ Curves , ~ , ~ ] = TriPlanIntersect( triMesh, U , d );
	    EdgePts = vertcat(Curves(:).Pts);
	    [~,lowestPointID] = min(EdgePts(:,3));
	    LowestPoints(i,:) = EdgePts(lowestPointID(1),:);
	%     
	%     pl3t(Curves(1).Pts,'b-')
	%     hold on
	%     pl3t(LowestPoints(i,:),'r*')
	%     axis equal
	%     
	    
	end
	
	% hold off
	
	PatRidgeVariability = std(LowestPoints*V);
	
	% figure(10)
	% plot(LowestPoints(:,1),LowestPoints(:,2),'b.')
	
	% pause(0.3)
	
	
	
	
	end
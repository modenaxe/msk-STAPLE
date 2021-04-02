% TRIANGLECLOSESTPOINTPAIR Identify the pair of closest point of a triangle
%
% From seeds S found all the points that are inside the spheres of radius r
% Then use the found points as new seed
% loop until no new points are found to be in the spheres
%
% [closestPtPair, isolatedPt, maxEdgeLength, minEdgeLength] = 
%                                        TriangleClosestPointPair(triangle)
%
% Inputs:
%   triangle - A 3x3 matrix or 3x2 matrix
%              3 lines of the 2D or 3D coordinates of the vertices of
%              the triangle
%
% Outputs:
%   closestPtPair - a 2x3 or 2x2 matrix of the pair of closest point   
%   isolatedPt - a 1x3 or 1x2 vector of the coordiante of the
%                point isolated relative to the point pair
%   minEdgeLength - a scalar value, length of the shortest edge
%   maxEdgeLength - a scalar value, length of the largest edge
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%

function [closestPtPair, isolatedPt, maxEdgeLength, minEdgeLength] = ...
                                        TriangleClosestPointPair(triangle)
	% TRIANGLECLOSESTPOINTPAIR Identify the pair of closest point of a triangl
	%
	% From seeds S found all the points that are inside the spheres of radius r
	% Then use the found points as new seed
	% loop until no new points are found to be in the spheres
	%
	% Parameters
	% ----------
	% triangle : __TYPE__
	% 	A 3x3 matrix or 3x2 matrix
	% 	 3 lines of the 2D or 3D coordinates of the vertices of
	% 	 the triangl
	%
	% Returns
	% -------
	% closestPtPair : __TYPE__
	% 	a 2x3 or 2x2 matrix of the pair of closest point   
	% isolatedPt : __TYPE__
	% 	a 1x3 or 1x2 vector of the coordiante of the
	% maxEdgeLength : __TYPE__
	% 	a scalar value, length of the largest edg
	% minEdgeLength : __TYPE__
	% 	a scalar value
	% 	 closestPtPair - a 2x3 or 2x2 matrix of the pair of closest point 
	% 	 isolatedPt - a 1x3 or 1x2 vector of the coordiante of the
	% 	 point isolated relative to the point pair
	%
	%

	
	
	% Get edge length
	
	triangleS = [triangle; triangle(1,:)];
	edgeLengths = sqrt( sum( diff(triangleS, 1).^2 , 2) );
	
	% Get the smallest edge
	[minEdgeLength,i] = min(edgeLengths);
	
	% The smallest edge connect the two closest point of the triangle
	closestPtPair = triangleS(i:i+1,:);
	
	% The isolated point is the 
	j = i+2;
	if j > 4
	    j = i-1 ;
	end
	isolatedPt = triangleS(j,:) ;
	maxEdgeLength = max(edgeLengths);
	
	
	end
	

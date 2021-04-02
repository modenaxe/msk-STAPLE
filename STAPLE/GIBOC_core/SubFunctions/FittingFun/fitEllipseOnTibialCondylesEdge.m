% ELLIPSEONTIBIALCONDYLESEDGE Identify the edges of the proximal tibia
% articular surfaces
%
% [ Xel, Yel, ellipsePts, ellipse_t, EdgePtsTop , K ] = ...
%                       fitEllipseOnTibialCondylesEdge( Tr, n , x0 )
%
% Inputs: 
%   Tr - Triangulation object of the articular surface.
% 
%   n - Array [v1; v2; v3] the normal vector to the
%       tibial plateau articular surfaces least square plane. 
%
%   x0 - Array  [x y z] a point on the least square plane or the
%        the value d such as d = -(v1.x + v2.y + v3.z)
%        Dimension: 3 x 1 or 1 x 1.
%
% Outputs: 
%   Xel - The X axis of the fitted ellipse in the original 3D space.
% 
%   Yel - The Y axis of the fitted ellipse in the original 3D space.
% 
%   ellipsePts - The ellipse points in the original 3D space (useful for 
%                plotting putposes).
% 
%   ellipse_t - Output structure of fit_ellipse
% 
%   EdgePtsTop - Articular surface edge points that are not too distal.
% 
%   K - The index of of the points from EdgePtsTop that form the convexhull.
%
% SEE ALSO ProjectOnPlan, fit_ellipse
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2019 Jean-Baptiste Renault
%-------------------------------------------------------------------------%

function [ Xel, Yel, ellipsePts, ellipse_t, EdgePtsTop , K ] = ...
    fitEllipseOnTibialCondylesEdge( Tr, n , x0 )
	% ELLIPSEONTIBIALCONDYLESEDGE Identify the edges of the proximal tibia
	% articular surface
	%
	% 
	%
	% Parameters
	% ----------
	% Tr : triangulation
	% 	Triangulation object of the articular surface.
	% 	 
	% n : [3x1] float vector
	% 	Array [v1; v2; v3] the normal vector to the
	% 	 tibial plateau articular surfaces least square plane.
	% x0 : __TYPE__
	% 	Array  [x y z] a point on the least square plane or the
	% 	 the value d such as d = -(v1.x + v2.y + v3.z)
	% 	 Dimension: 3 x 1 or 1 x 1
	%
	% Returns
	% -------
	% Xel : __TYPE__
	% 	The X axis of the fitted ellipse in the original 3D space.
	% 	 
	% Yel : __TYPE__
	% 	The Y axis of the fitted ellipse in the original 3D space.
	% 	 
	% ellipsePts : __TYPE__
	% 	The ellipse points in the original 3D space (useful for 
	% 	 plotting putposes).
	% 	 
	% ellipse_t : __TYPE__
	% 	Output structure of fit_ellipse
	% 	 
	% EdgePtsTop : __TYPE__
	% 	Articular surface edge points that are not too distal.
	% 	 
	% K : __TYPE__
	% 	The index of of the points from EdgePtsTop that form the convexhull.
	% 	
	% 	 SEE ALSO ProjectOnPlan, fit_ellips
	%
	%

	
	if length(x0) > 1
	    d = - (n(1)*x0(1) + n(2)*x0(2) + n(3)*x0(3));
	else
	    d = x0;
	end
	
	EdgePtsID = unique(Tr.freeBoundary);
	EdgePts = Tr.Points(EdgePtsID,:);
	
	EdgePtsTop = EdgePts(EdgePts*n + d > - 10, : );
	
	% Transform the top Edge Points to a 2D space
	% 1. project all points on the place
	EdgePtsTopProj = ProjectOnPlan(EdgePtsTop,n,d);
	
	% 2. find the principal vectors of the projected point cloud
	[V,~] = eig(cov(EdgePtsTopProj));
	
	% 3. Perform a Change of basis to "drop" a dimension
	EdgePtsTop2D = EdgePtsTopProj*V;
	
	% Calculate the conhull of the 2D points
	K = convhull(EdgePtsTop2D(:,2:3));
	EdgePtsTopProjOut = EdgePtsTopProj(K,:);
	
	% Fit an ellipse to the convhull points
	ellipse_t = fit_ellipse( EdgePtsTop2D(K,2), EdgePtsTop2D(K,3) );
	
	% Add the deleted dimension to the ellipse points and axis
	ellipsePts2D = [EdgePtsTop2D(1)*ones(1,length(ellipse_t.data)) ; ellipse_t.data];
	Yel2D = [0 ; sin( ellipse_t.phi ) ; cos( ellipse_t.phi )];
	Xel2D = [0 ; cos( ellipse_t.phi ) ; -sin( ellipse_t.phi )];
	
	% Send results back to 3D space
	Xel = V*Xel2D;
	Yel = V*Yel2D;
	ellipsePts = transpose( V*ellipsePts2D );
	
	
	end
	

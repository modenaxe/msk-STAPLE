function [ Xel, Yel, ellipsePts, ellipse_t, EdgePtsTop ,K  ] = ...
    fitEllipseOnTibialCondylesEdge( Tr, n , x0 )
%ELLIPSEONTIBIALCONDYLESEDGE 
%   Identify the edges of proximal tibial articular surfaces
%
% Modified          J B Renault 12 Jan 2018
% Created           J B Renault 16 Oct 2017
% ---------------------------------------------------------------------
% Input 
% Tr        Triangulation object of the articular surface.
%
% n         Array  [v1; v2; v3] the normal vector to the
%           tibial plateau articular surfaces least square plane.
%           Dimension: 3 x 1.
%
% x0        Array  [x y z] a point on the least square plane or the
%           the value d such as d = -(v1.x + v2.y + v3.z)
%           Dimension: 3 x 1 or 1 x 1.
%
% Output   
% x0        Centroid of the data = point on the best-fit plane.
%           Dimension: 3 x 1. 
% 
% a         Direction cosines of the normal to the best-fit 
%           plane. 
%           Dimension: 3 x 1.
% 
% <Optional... 
% d         Residuals. 
%           Dimension: m x 1. 
% 
% normd     Norm of residual errors. 
%           Dimension: 1 x 1. 
% ...>
%
% [x0, a <, d, normd >] = lsplane(X)
% ---------------------------------------------------------------------
% depends on ProjectOnPlan
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


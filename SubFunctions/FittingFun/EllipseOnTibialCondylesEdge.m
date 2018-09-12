function [ Xel, Yel, ellipsePts, ellipse_t, EdgePtsTop ,K  ] = ...
    EllipseOnTibialCondylesEdge( Tr, n , x0 )
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
if length(x0) > 1
    d = - (n(1)*x0(1) + n(2)*x0(2) + n(3)*x0(3));
else
    d = x0;
end

EdgePtsID = unique(Tr.freeBoundary);
EdgePts = Tr.Points(EdgePtsID,:);

EdgePtsTop = EdgePts(EdgePts*n + d > - 10, : );

EdgePtsTopProj = ProjectOnPlan(EdgePtsTop,n,d);

[V,~] = eig(cov(EdgePtsTopProj));

EdgePtsTop2D = EdgePtsTopProj*V;

K = convhull(EdgePtsTop2D(:,2:3));

EdgePtsTopProjOut = EdgePtsTopProj(K,:);

ellipse_t = fit_ellipse( EdgePtsTop2D(K,2), EdgePtsTop2D(K,3) );

ellipsePts2D = [EdgePtsTop2D(1)*ones(1,length(ellipse_t.data)) ; ellipse_t.data];
Yel2D = [0 ; sin( ellipse_t.phi ) ; cos( ellipse_t.phi )];
Xel2D = [0 ; cos( ellipse_t.phi ) ; -sin( ellipse_t.phi )];


% Send results back to 3D space
Xel = V*Xel2D;
Yel = V*Yel2D;
ellipsePts = transpose( V*ellipsePts2D );


end


function [ Xel, Yel, ellipsePts, ellipse_t, EdgePtsTop ,K  ] = EllipseOnEdge( TRedge, n , d )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

EdgePtsID = unique(TRedge.freeBoundary);
EdgePts = TRedge.Points(EdgePtsID,:);

EdgePtsTop = EdgePts(EdgePts*n > -d - 10, : );

EdgePtsTopProj = ProjectOnPlan(EdgePtsTop,n,d);

[V,~] = eig(cov(EdgePtsTopProj));

EdgePtsTop2D = EdgePtsTopProj*V;

K = convhull(EdgePtsTop2D(:,2:3));

EdgePtsTopProjOut = EdgePtsTopProj(K,:);

ellipse_t = fit_ellipse( EdgePtsTop2D(K,2), EdgePtsTop2D(K,3) );

ellipsePts2D = [EdgePtsTop2D(1)*ones(1,length(ellipse_t.data)) ; ellipse_t.data];
Yel2D = [0 ; sin( ellipse_t.phi ) ; cos( ellipse_t.phi )];
Xel2D = [0 ; cos( ellipse_t.phi ) ; -sin( ellipse_t.phi )];



Xel = V*Xel2D;
Yel = V*Yel2D;
ellipsePts = transpose( V*ellipsePts2D );


% , n_m, n_p
% Xel2D_p = [0 ; cos( ellipse_t.phi + pi/8 ) ; -sin( ellipse_t.phi + pi/8)];
% Xel2D_m = -[0 ; cos( ellipse_t.phi - pi/8) ; -sin( ellipse_t.phi - pi/8)];
% 
% Xel_p = V*Xel2D_p;
% Xel_m = V*Xel2D_m;
% 
% n_m = cross(n,Xel_m); n_m = n_m / norm(n_m);
% n_p = cross(n,Xel_p); n_p = n_p / norm(n_p);


end


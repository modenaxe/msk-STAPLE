% SPHEREFIT fits a sphere to a collection of data using a closed form for the
% solution (opposed to using an array the size of the data set). 
% Minimizes Sum((x-xc)^2+(y-yc)^2+(z-zc)^2-r^2)^2
% x,y,z are the data, xc,yc,zc are the sphere's center, and r is the radius
%
% Assumes that points are not in a singular configuration, real numbers, ...
% if you have coplanar data, use a circle fit with svd for determining the
% plane, recommended Circle Fit (Pratt method), by Nikolai Chernov
% http://www.mathworks.com/matlabcentral/fileexchange/22643
%
% [Center,Radius,ErrorDist] = sphereFit(X)
%
% Inputs:
%   X - n x 3 matrix of cartesian data
%
% Outputs:
%   Center - Center of sphere 
%   Radius - Radius of sphere
%   ErrorDist - Error dist for each points in X
%
% Modified to add distance to sphere -> ErrorDist
%-------------------------------------------------------------------------%
%  Author:   Alan Jennings, University of Dayton
%  Copyright 2020 Alan Jennings, University of Dayton
%-------------------------------------------------------------------------%

function [Center,Radius,ErrorDist] = sphereFit(X)
	% SPHEREFIT fits a sphere to a collection of data using a closed form for the
	% solution (opposed to using an array the size of the data set). 
	% Minimizes Sum((x-xc)^2+(y-yc)^2+(z-zc)^2-r^2)^2
	% x,y,z are the data, xc,yc,zc are the sphere's center, and r is the radiu
	%
	% Assumes that points are not in a singular configuration, real numbers, ...
	% if you have coplanar data, use a circle fit with svd for determining the
	% plane, recommended Circle Fit (Pratt method), by Nikolai Chernov
	% http://www.mathworks.com/matlabcentral/fileexchange/22643
	%
	% Parameters
	% ----------
	% X : __TYPE__
	% 	n x 3 matrix of cartesian dat
	%
	% Returns
	% -------
	% Center : __TYPE__
	% 	Center of sphere 
	% Radius : __TYPE__
	% 	Radius of sphere
	% ErrorDist : __TYPE__
	% 	Error dist for each points in X
	% 	
	% 	 Modified to add distance to sphere -> ErrorDis
	%
	%

	
	
	A=[mean(X(:,1).*(X(:,1)-mean(X(:,1)))), ...
	    2*mean(X(:,1).*(X(:,2)-mean(X(:,2)))), ...
	    2*mean(X(:,1).*(X(:,3)-mean(X(:,3)))); ...
	    0, ...
	    mean(X(:,2).*(X(:,2)-mean(X(:,2)))), ...
	    2*mean(X(:,2).*(X(:,3)-mean(X(:,3)))); ...
	    0, ...
	    0, ...
	    mean(X(:,3).*(X(:,3)-mean(X(:,3))))];
	A=A+A.';
	B=[mean((X(:,1).^2+X(:,2).^2+X(:,3).^2).*(X(:,1)-mean(X(:,1))));...
	    mean((X(:,1).^2+X(:,2).^2+X(:,3).^2).*(X(:,2)-mean(X(:,2))));...
	    mean((X(:,1).^2+X(:,2).^2+X(:,3).^2).*(X(:,3)-mean(X(:,3))))];
	Center=(A\B).';
	
	Radius=sqrt(mean(sum([X(:,1)-Center(1),X(:,2)-Center(2),X(:,3)-Center(3)].^2,2)));
	% (P-Centre)^2 - Radius^2
	ErrorDist = sum([X(:,1)-Center(1),X(:,2)-Center(2),X(:,3)-Center(3)].^2,2) - Radius^2;

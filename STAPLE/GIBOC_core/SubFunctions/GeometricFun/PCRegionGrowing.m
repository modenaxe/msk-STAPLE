% PCRegionGrowing Point cloud Region growing
%
% From a given set of seed points [S], find recursively the points in the 
% point cloud [Pts] that are "connected" to the iteratively grown seed points.
% The connected property is defined by a distance threshold given by a
% radius [r].
%
%   [ Pts_Out] = PCRegionGrowing(Pts,S,r)
%
% Inputs:
%   Pts - A point cloud
%   S - The seeds (a matrix of points coordinates) from which to grow
%   r - The radius of the sphere to consider two points as neighours
%   
%
% Outputs:
%   Pts_Out - The subset of points in point clouds that are connected
%             to the seeds.
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault
%  Copyright 2018 Jean-Baptiste Renault
%-------------------------------------------------------------------------%


function [ Pts_Out] = PCRegionGrowing(Pts,S,r)
	% PCRegionGrowing Point cloud Region growin
	%
	% From a given set of seed points [S], find recursively the points in the 
	% point cloud [Pts] that are "connected" to the iteratively grown seed points.
	% The connected property is defined by a distance threshold given by a
	% radius [r].
	%
	% Parameters
	% ----------
	% Pts : [nx3] float matrix
	% 	A point cloud
	% S : __TYPE__
	% 	The seeds (a matrix of points coordinates) from which to grow
	% r : __TYPE__
	% 	The radius of the sphere to consider two points as neighour
	%
	% Returns
	% -------
	% Pts_Out : [nx3] float matrix
	% 	The subset of points in point clouds that are connected
	% 	 to the seeds
	%
	%

	
	Seeds = S;
	
	% Seeds in the considerated point cloud
	Seeds = Pts(dsearchn(Pts,Seeds),:);
	
	Pts_Out=[];
	
	while ~isempty(Seeds)  
	        % Get the index of points within the spheres
	        I = rangesearch(Pts,Seeds,r);
	        idx=[];
	        for k=1:size(I,1)
	            idx(end+1:end+size(I{k},2)) = I{k};
	        end
	        idx = unique(idx(:));
	        
	        % Update Seeds with found points
	        Seeds = Pts(idx,:);
	        Pts_Out(end+1:end+size(idx),:) =  Pts(idx,:);
	        Pts(idx,:) = [];       
	end
	
	end
	

% PCREGIONGROWING PointCloud Region growing
%
% [ Pts_Out ] = PCRegionGrowing(Pts, S, r)
%
% From seeds S found all the points that are inside the spheres of radius r
% Then use the found points as new seed
% loop until no new points are found to be in the spheres
%
% Inputs:
%   Pts - A Points Cloud of n points in d dimensions
%   S - A matrix of m>=1 seed points in d dimensions
%   r - Radius of search for neighbour points
%
% Outputs:
%   Pts_Out - A subset of the input points cloud that are grown from
%             the seed points. 
%
% -------------------------------------------------------------------------
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ Pts_Out ] = PCRegionGrowing(Pts, S, r)

    Seeds = S;

    % Seeds in the considered point cloud
    Seeds = Pts(dsearchn(Pts, Seeds), :);

    Pts_Out=[];

    while ~isempty(Seeds)  
            % Get the index of points within the neighbour spheres
            I = rangesearch(Pts, Seeds, r);
            idx = [];
            for k = 1:size(I, 1)
                idx(end+1:end+size(I{k}, 2)) = I{k};
            end
            idx = unique(idx(:));
            
            % Update Seeds with found points
            Seeds = Pts(idx, :);
            Pts_Out(end+1:end+size(idx), :) = Pts(idx,:);
            Pts(idx, :) = [];       
    end

end


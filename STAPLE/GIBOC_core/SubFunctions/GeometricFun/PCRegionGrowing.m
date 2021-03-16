function [ Pts_Out] = PCRegionGrowing(Pts,S,r)
%PCRegionGrowing PointCloud Region growing
%   Pts : Point Cloud
%   r : radius threshold 
% From seeds S found all the points that are inside the spheres of radius r
% Then use the found points as new seed
% loop until no new points are found to be in the spheres


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


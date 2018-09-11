function [ Pts_Out] = PCRegionGrowing(Pts,S,r)
%PCRegionGrowing PointCloud Region growing
%   Pts : Point Cloud
%   r : radius threshold 
Seeds = S;

% Seeds in the considerated point cloud
Seeds = Pts(dsearchn(Pts,Seeds),:);

Pts_Out=[];

while ~isempty(Seeds)
        I = rangesearch(Pts,Seeds,r);
        idx=[];
        for k=1:size(I,1)
            idx(end+1:end+size(I{k},2)) = I{k};
        end
        idx = unique(idx(:));
%         Seeds = [];
        Seeds = Pts(idx,:);
        Pts_Out(end+1:end+size(idx),:) =  Pts(idx,:);
        Pts(idx,:) = [];       
end

end


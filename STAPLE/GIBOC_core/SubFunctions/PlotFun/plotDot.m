function plotDot( centers, color, r )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin <2
    color='k';
    r=1.75;
end

if nargin <3
    r=1.75;
end

% [LM] the check was not working I fixed it
if size(centers,1)>size(centers,2) && size(centers,1)==3
    centers = centers';
end


for i=1:size(centers,1)
    [x,y,z] = sphere(50);
    x0 = centers(i,1); y0 = centers(i,2); z0 = centers(i,3);
    x = x*r + x0;
    y = y*r + y0;
    z = z*r + z0;
    
    hold on
    % lightGrey = 0.8*[1 1 1]; % It looks better if the lines are lighter
    surface(x,y,z,'FaceColor', color,'EdgeColor','none')
    hold on
end

end


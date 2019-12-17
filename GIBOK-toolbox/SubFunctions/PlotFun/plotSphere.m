function plotSphere( center, r , color , alpha)
% Plot a sphere on the current figure
if nargin <2
    color='c';
    r=10;
    alpha = 1;
end

if nargin <3
    color='c';
    alpha = 1;
end

if nargin <4
    alpha = 1;
end



[x,y,z] = sphere(50);
x0 = center(1); y0 = center(2); z0 = center(3);
x = x*r + x0;
y = y*r + y0;
z = z*r + z0;

hold on
surface(x,y,z,'FaceColor', color ,'EdgeColor',[0.8 0.8 0.8],'FaceAlpha',alpha,'EdgeAlpha',min(1,alpha*2.5))
hold on

end


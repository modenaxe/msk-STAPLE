% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %
% TO DO: write description
% this function plots a reference system useful to visualize changes of
% reference systems.

function plot_refsyst(axes_handle, orig, axisMatrix, varargin)

% update axes length using the scale factor provided
if isempty(varargin)
    scale = 1;
else 
    scale = varargin{1};
end
R = axisMatrix*scale;

% check on origin dimensions: if orig is row vector then make it column
if isequal(size(orig),[1,3])
    orig = orig';
end

% shorter name for axes handle
h = axes_handle;

% plot x axis
x_vec = [orig, orig+R(:,1), orig]';
plot3(h, x_vec(:,1),x_vec(:,2),x_vec(:,3), 'Linewidth',2,'Color','r'); 
plot3(h, orig(1)+R(1,1),orig(2)+R(2,1),orig(3)+R(3,1),'^', 'MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor','r','Linewidth',2,'Color','r'); hold on

% plot y axis
y_vec = [orig,orig+R(:,2),orig]';
plot3(h, y_vec(:,1),y_vec(:,2),y_vec(:,3), 'Linewidth',2,'Color','g')
plot3(h, orig(1)+R(1,2),orig(2)+R(2,2),orig(3)+R(3,2),'^', 'MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor','g','Linewidth',2,'Color','r'); hold on

% plot z axis
z_vec = [orig,orig+R(:,3),orig]';
plot3(h, z_vec(:,1),z_vec(:,2),z_vec(:,3), 'Linewidth',2,'Color','b')
plot3(h, orig(1)+R(1,3),orig(2)+R(2,3),orig(3)+R(3,3),'^', 'MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor','b','Linewidth',2,'Color','r'); hold on

axis equal

end
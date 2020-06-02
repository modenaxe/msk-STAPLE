%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese, April 2018                                  % 
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% based on https://www.mathworks.com/matlabcentral/answers/19716-what-is-the-function-to-plot-a-rotating-3-d-ellipsoid
function plotEllipsoid(centre, radii, evecs, color, alpha)

if nargin<5
    alpha=0.4;
end
M = centre;
% generate ellipsoid
[xc,yc,zc] = ellipsoid(0,0,0,radii(1),radii(2),radii(3),50);

U = evecs;

% rotate data with orientation matrix U and center M
a = kron(U(:,1),xc); b = kron(U(:,2),yc); c = kron(U(:,3),zc);
data = a+b+c; n = size(data,2);
x = data(1:n,:)+M(1); 
y = data(n+1:2*n,:)+M(2); 
z = data(2*n+1:end,:)+M(3);
% plot
surf(x, y, z, 'Facecolor', color,'EdgeColor','none', 'FaceAlpha', alpha);

end
function [Z0,Y0] = fitQuadriTalus(Tr, V_all, plotOn)
%FITQUADRITALUS Approximate the shape of the talus by a quadrilateral
%   From the mesh (triangulation of the talus), fit a quadrilateral to get
%   an initial guess of the talus Z0 direction (Inferior to Superior).
%   Inputs :
%       - Tr :  The triangulation object of the Talus
%       - V_all : The eigen vector of the inertia matrix of Talus
%       - plotOn : Optionnal argument to plot the fit
%   Outputs : 
%       - Z0 :  A vector [3x1] of the inf to sup direction
%       - Y0 :  A vector [3x1] of the medial to lateral (or the other way
%               around) direction

%% 

if nargin == 2
    plotOn = 0;
end

% First project the mesh on the plane perpendicular to X0 (1st inertia axis)
Pts_inertia = (V_all'*Tr.Points')';

if plotOn
    figure('color','w','numbertitle','off', ...
        'name', ['Debug Figure: ' mfilename '.m: Projection on X0 (1st inertia axis)']);
    axis equal tight; hold on
    plot3(Pts_inertia(:,1),Pts_inertia(:,2),Pts_inertia(:,3),'g.')
    xlabel('X'); ylabel('Y'); zlabel('Z')
    view(90,0)
end

% Keep only the 2nd (Y0) and 3rd (Z0) dimension 
Pts_proj_2D = Pts_inertia(:,2:3);
assert(sum(sum(Pts_inertia(:,2:3)-Pts_proj_2D)) < 1e-8)

%Get the convex hull of the point cloud
K = convhull(Pts_proj_2D,'simplify', false);

if plotOn
    projFig = figure('color','w','numbertitle','off', ...
        'name', ['Debug Figure: ' mfilename '.m: Convex hull of the projection on X0']);
    projAxes = axes();
    axis equal tight; hold on
    plot(Pts_proj_2D(:,1),Pts_proj_2D(:,2),'b.')
    plot(Pts_proj_2D(K,1),Pts_proj_2D(K,2),'k-')
    xlabel('Y'); ylabel('Z')
end

% Find the two points of the convex hull with max. distance to each other
% assuming that it is the 1st diagonal of the quadrilateral
pwDist = squareform(pdist(Pts_proj_2D(K,:)));
[~, maxDistIdx] = max(pwDist(:));
[rowPP1,colPP1] = ind2sub(size(pwDist),maxDistIdx);
pointPair1 = [K(rowPP1),K(colPP1)];
U1 = (Pts_proj_2D(pointPair1(2),:)-Pts_proj_2D(pointPair1(1),:))';

if plotOn
    maxDist1D_H = plot(Pts_proj_2D(pointPair1,1),Pts_proj_2D(pointPair1,2),'r-o');
    legend(maxDist1D_H, '1st diagonal')
end

% Hacky way to find the second diagonal of the quadrilateral by shrinking
% along the point cloud in the direction (U1) of the 1st diagonal found
U1 = normalizeV(U1);
Ru = [U1(1),-U1(2);U1(2),U1(1)];
Pts_proj_2D_shr = (Ru*[0.5,0;0,1]*Ru'*Pts_proj_2D')';

if plotOn
    figure('color','w','numbertitle','off', ...
        'name', ['Debug Figure: ' mfilename '.m: Projection on X0 shrinked along 1st diagonal']);
    axis equal tight; hold on
    plot(Pts_proj_2D_shr(:,1),Pts_proj_2D_shr(:,2),'g.')
    line(Pts_proj_2D_shr(K,1),Pts_proj_2D_shr(K,2))
    xlabel('Y'); ylabel('Z')
end

% Find the two points of the convex hull with max. distance to each other
% assuming that it is the 2nd diagonal of the quadrilateral
pwDist = squareform(pdist(Pts_proj_2D_shr(K,:)));
[~, maxDistIdx] = max(pwDist(:));
[rowPP2,colPP2] = ind2sub(size(pwDist),maxDistIdx);
pointPair2 = [K(rowPP2),K(colPP2)];

if plotOn
    maxDist2D_H = plot(Pts_proj_2D_shr(pointPair2,1),Pts_proj_2D_shr(pointPair2,2),'r--o');
    legend(maxDist2D_H, '2nd diagonal')
end

% Sort the quadrilateral vertices in counter-clockwise direction along the
% convex hull
quadriVIdx = sort([rowPP1,colPP1,rowPP2,colPP2]);
quadriV = K([quadriVIdx,quadriVIdx(1)]);
              
if plotOn
    maxDist2D_H = plot(projAxes, Pts_proj_2D(pointPair2,1),Pts_proj_2D(pointPair2,2),'r--o');
    qLitVerts_H = text(projAxes, Pts_proj_2D(quadriV(1:4),1),Pts_proj_2D(quadriV(1:4),2),{'1','2','3','4'},...
        'HorizontalAlignment','right', 'FontSize',14, 'FontWeight','bold');
    legend([maxDist1D_H,maxDist2D_H], {'1st diagonal','2nd diagonal'})
end         
              
% Get the length of the edges of the quadrilateral
edgesLength = zeros(4,1);
for i=1:4
    dy = Pts_proj_2D(quadriV(i+1),1)-Pts_proj_2D(quadriV(i),1);
    dz = Pts_proj_2D(quadriV(i+1),2)-Pts_proj_2D(quadriV(i),2);
    edgesLength(i) = sqrt(dy^2+dz^2);
end
[~,Imax] = max(edgesLength);

% The edge corresponding to the superior part of the bone is assumed to be 
% the one opposing the largest one
I_V_sup = mod(Imax+2,4); % Index of the start vertex of the superior edge
if I_V_sup == 0
    I_V_sup = 4;
end
Edge_sup = quadriV(I_V_sup:I_V_sup+1);

% Get the direction of the edge
U_edge_sup = [Pts_proj_2D(Edge_sup(2),1)-Pts_proj_2D(Edge_sup(1),1);...
    Pts_proj_2D(Edge_sup(2),2)-Pts_proj_2D(Edge_sup(1),2)];
%Z0_proj is normal to edge direction
Z0_proj = [-U_edge_sup(2);U_edge_sup(1)];

% Make sure Z0 point from inferior to superior
U0_IS = mean(Pts_proj_2D(Edge_sup,:))-mean(Pts_proj_2D);
Z0_proj = normalizeV(sign(U0_IS*Z0_proj)*Z0_proj);

% Get Z0 back in original coordinate system
Z0 = V_all*[0;Z0_proj];
Y0 = cross(Z0,V_all(:,1));

if plotOn
    qLitEdge_H = plot(projAxes, Pts_proj_2D(quadriV,1),Pts_proj_2D(quadriV,2),'g-s',...
        'linewidth',2);
    supEdge_H = plot(projAxes, Pts_proj_2D(Edge_sup,1),Pts_proj_2D(Edge_sup,2),'m-o',...
        'linewidth',3);
    legend([maxDist1D_H,maxDist2D_H,qLitEdge_H,supEdge_H],...
        {'1st diagonal','2nd diagonal','Quadrilateral edges','Superior edge'})
    uistack(qLitVerts_H, 'top');
    figure(projFig)
end

end
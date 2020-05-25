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


%% First project the mesh on the plan perpendicular to X0 (1st inertia axis)
YZ0 = [V_all(:,2),V_all(:,3)];
PX0 = YZ0*inv(YZ0'*YZ0)*YZ0'; %Projection matrix
Pts_proj = V_all'*PX0*Tr.Points';

% Keep only the 2 and 3rd coordinates
Pts_proj_2D = Pts_proj(2:3,:)';

%Get the convex hull of the point cloud
K = convhull(Pts_proj_2D,'simplify', false);

% Find the max edge
maxDist = -1;
for i=1:length(K)
    for j=1:length(K)
        diff1 = Pts_proj_2D(K(j),1)-Pts_proj_2D(K(i),1);
        diff2 = Pts_proj_2D(K(j),2)-Pts_proj_2D(K(i),2);
        dist = sqrt(diff1^2+diff2^2);
        if dist>maxDist
            maxDist=dist;
            pointPair1=[K(i),K(j)];
            U1=[diff1;diff2];
        end
    end
end

% Hacky way to find the second diagonal of the quadrilateral by shrinking
% along the point cloud in the direction (U1) of the first found diagonal
U1 = normalizeV(U1);
Ru = [U1(1),-U1(2);U1(2),U1(1)];
Pts_proj_2D_shr = transpose(Ru*[0.5,0;0,1]*Ru'*Pts_proj_2D');
% plot(Pts_proj_2D_shr(:,1),Pts_proj_2D_shr(:,2),'b.')


% Find the max edge on the shrink points cloud
maxDist = -1;
for i=1:length(K)
    for j=1:length(K)
        diff1 = Pts_proj_2D_shr(K(j),1)-Pts_proj_2D_shr(K(i),1);
        diff2 = Pts_proj_2D_shr(K(j),2)-Pts_proj_2D_shr(K(i),2);
        dist = sqrt(diff1^2+diff2^2);
        if dist>maxDist
            maxDist=dist;
            pointPair2=[K(i),K(j)];
            U2=[diff1;diff2];
        end
    end
end

% Get the quadrilateral vertices
quadriV = [pointPair1(1); pointPair2(1);...
                  pointPair1(2); pointPair2(2);...
                  pointPair1(1)];
              
% Get the length of the quadri edges 
edgesLength = zeros(4,1);
for i=1:4 
    diff1 = Pts_proj_2D(quadriV(i+1),1)-Pts_proj_2D(quadriV(i),1);
    diff2 = Pts_proj_2D(quadriV(i+1),2)-Pts_proj_2D(quadriV(i),2);
    edgesLength(i) = sqrt(diff1^2+diff2^2);
end

[~,Imax] = max(edgesLength);

% Indices of start vertices of quadrilateral
I_V_sup = mod(Imax+2,4);
% Edge corresponding to the superior part of the bone is assumed to be the
% one opposing the largest one
Edge_sup = quadriV(I_V_sup:I_V_sup+1);

% Get the direction of the edge :
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
    figure()
    plot(Pts_proj_2D(:,1),Pts_proj_2D(:,2),'b.')
    hold on
    plot(Pts_proj_2D(K,1),Pts_proj_2D(K,2),'k-')
    axis equal
    plot(Pts_proj_2D(pointPair1,1),Pts_proj_2D(pointPair1,2),'r-*')
    plot(Pts_proj_2D(pointPair2,1),Pts_proj_2D(pointPair2,2),'r-*')
    plot(Pts_proj_2D(quadriV,1),Pts_proj_2D(quadriV,2),'g-s',...
        'linewidth',2)
    plot(Pts_proj_2D(Edge_sup,1),Pts_proj_2D(Edge_sup,2),'m-o',...
        'linewidth',3)
end

end


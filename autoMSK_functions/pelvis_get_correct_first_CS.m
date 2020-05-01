function [RotPseudoISB2Glob, LargestTriangle] = pelvis_get_correct_first_CS(Pelvis, debug_plots)
% Function to test putting back together a correct orientation of the
% pelvis
% Inputs :
%           Pelvis : A triangulation of a complete pelvis
%           debug_plots : A boolean to display plots useful for debugging
%
% Output :
%   BL              A structure containing the pelvis bone landmarks
%   RotISB2Glob     A rotation matrix containing properly oriented initial
%                   guess of the X, Y and Z axis of the pelvis ISB CS
%   CenterVol       Volumetric center of the pelvis
%
% -------------------------------------------------------------------------
%                           General Idea
% The largest cross section along the principal inertia axis is located at
% the front of the pelvis. From that information it's easy to determine the
% distal to proximal direction. Then the largest triangle of the pelvis
% convex hull is the one connecting the LASIS RASIS and SYMP.
% -------------------------------------------------------------------------

% inputs checks
if nargin < 2
    debug_plots = 0;
end

% inertial axes
[V_all, CenterVol, ~, D ] =  TriInertiaPpties(Pelvis);

% smaller moment of inertia is prox/dist axis
Z0 = V_all(:,1);

%% Get convexHull
K = convhull(Pelvis.Points);
Kold2new(sort(unique(K(:)))) = 1:length(sort(unique(K(:))));
Pts = Pelvis.Points(sort(unique(K(:))),:);
PelvisConvHull = triangulation(Kold2new(K), Pts);

%% Get the Post-Ant direction by finding the largest triangle of the pelvis
% and checking the inertial axis that more closely aligns with it

% Find the largest triangle on the projected Convex Hull
[ PelvisConvHull_Ppties ] = TriMesh2DProperties( PelvisConvHull );
[~,I] = max(PelvisConvHull_Ppties.Area);

% Get the triangle center and normal
% ConvHullFaceNormals = PelvisConvHull.faceNormal;
% LargestTriangle.Normal = ConvHullFaceNormals(I,:);
LargestTriangle.Pts = PelvisConvHull.Points(...
                                PelvisConvHull.ConnectivityList(I,:) , :);
LargestTriangle = triangulation([1 2 3], LargestTriangle.Pts);
% vector pointing forward is X
[~, ind_X] = max(V_all'*LargestTriangle.faceNormal');
X0 = V_all(:,ind_X);

% Reorient X0 to be posterior to anterior
X0 = sign(LargestTriangle.faceNormal*X0)*X0;

% Y0 is just normal to X0 and Y0
Y0 = normalizeV(cross(Z0, X0));

%% Get the final initial CS
Z0 = cross(X0, Y0);
RotPseudoISB2Glob = [X0, Y0, Z0];

%% Debug Plots
if debug_plots
    figure()
    hold on
    axis equal
    pl3tVectors(CenterVol, X0, 125);
    pl3tVectors(CenterVol, Y0, 175);
    pl3tVectors(CenterVol, Z0, 250);
    trisurf(Pelvis,'facealpha',0.5,'facecolor','b',...
        'edgecolor','none');
    trisurf(PelvisConvHull,'facealpha',0.2,'facecolor','c',...
        'edgecolor',[.3 .3 .3], 'edgealpha', 0.2);
    trisurf(LargestTriangle,'facealpha',0.8,'facecolor','r',...
        'edgecolor','k');
    % handle lighting of objects
    light('Position',CenterVol + 500*V_all(:,2) + 500*V_all(:,3),'Style','local')
    light('Position',CenterVol + 500*V_all(:,2) -  500*V_all(:,3),'Style','local')
    light('Position',CenterVol - 500*V_all(:,2) + 500*V_all(:,3) - 500*Z0,'Style','local')
    light('Position',CenterVol - 500*V_all(:,2) -  500*V_all(:,3) + 500*Z0,'Style','local')
    lighting gouraud
    
    % Remove grid
    grid off
end

end
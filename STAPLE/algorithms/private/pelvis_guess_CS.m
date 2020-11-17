% PELVIS_GUESS_CS Run geometrical checks to correctly estimate the 
% orientation of an initial pelvis reference system. The convex hull for
% the pelvis triangulation is computed, and the normal of largest triangle,
% which connects the ASIS and PUB, identifies the frontal direction. Then, 
% for the pelvis moved to the reference system defined by its principal
% axes of inertia, the points that have the largest span along a
% non-prox-distal axis are identified as the crests of the iliac bones.
% Using the centroid of the triangulation, a cranial axis is defined and
% the reference system finalised after the recommendation of the
% International Society of Biomechanics (ISB).
%
% Inputs :
%   pelvisTri - MATLAB triangulation object of the entire pelvic geometry.
%
%   debug_plots - enable plots used in debugging. Value: 1 or 0 (default).
%
% Output :
%   RotPseudoISB2Glob - rotation matrix containing properly oriented initial
%        guess of the X, Y and Z axis of the pelvis. The axes are not
%        defined as by ISB definitions, but they are pointing in the same
%        directions, which is why is named "PseudoISB". This matrix 
%        represent the body-fixed transformation from this reference system
%        to ground.
%
%   LargestTriangle - MATLAB triangulation that identifies the largest
%       triangle of the convex hull computed for the pelvis triangulation.
%
%   BL - MATLAB structure containing the bony landmarks identified 
%       on the bone geometries based on the defined reference systems. Each
%       field is named like a landmark and contain its 3D coordinates.
%
% -------------------------------------------------------------------------
%  Author:   Jean-Baptiste Renault and Luca Modenese. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%

function [RotPseudoISB2Glob, LargestTriangle, BL] = pelvis_guess_CS(pelvisTri,...
                                                                    debug_plots)

% inputs checks
if nargin < 2; debug_plots = 0; end

% inertial axes
[V_all, CenterVol, ~, D ] =  TriInertiaPpties(pelvisTri);

% smaller moment of inertia is normally the medio/lateral axis. It will be
% updated anyway. It can be checked using D from TriInertiaPpties.m
Z0 = V_all(:,1);

% compute convex hull
K = convhull(pelvisTri.Points);

% transform it in triangulation
Kold2new(sort(unique(K(:)))) = 1:length(sort(unique(K(:))));
Pts = pelvisTri.Points(sort(unique(K(:))),:);
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

% NOTE that we are working using a GIBOC reference system until where the
% rotation matrix is assembled using ISB conventions(specified in comments)

% vector pointing forward is X
[~, ind_X] = max(abs(V_all'*LargestTriangle.faceNormal'));
X0 = V_all(:,ind_X);

% Reorient X0 to point posterior to anterior
anterior_v = LargestTriangle.incenter-CenterVol';
X0 = normalizeV(sign(anterior_v*X0)*X0);

% Y0 is just normal to X0 and Y0 (direction non inportant for now)
% NOTE: Z normally points medio-laterally, Y will be cranio-caudal.
% Directions not established yet
Y0_temp = normalizeV(cross(Z0, X0));

if debug_plots == 1 
    figure()
    quickPlotTriang(pelvisTri)
    plotArrow(X0, 1, CenterVol, 60, 1, 'r')
    plotArrow(Y0_temp, 1, CenterVol, 60, 1, 'g')
    plotArrow(Z0, 1, CenterVol, 60, 1, 'b')
    title('X0 shold be pointing anteriorly - no interest in other axes')
end

% transform the pelvis to the new set of inertial axes
[ PelvisInertia, ~ , ~ ] = TriChangeCS(pelvisTri, [X0, Y0_temp, Z0]', CenterVol);

if debug_plots == 1 
    figure()
    quickPlotTriang(PelvisInertia)
    plotArrow([1, 0, 0]', 1, [0 0 0]', 60, 1, 'r')
    plotArrow([0, 1, 0]', 1, [0 0 0]', 60, 1, 'g')
    plotArrow([0, 0, 1]', 1, [0 0 0]', 60, 1, 'b')
    title('Check axes of inertia orientation')
end

% get points that could be on iliac crests
[L1y, ind_P1y] = max(PelvisInertia.Points(:,2));
[L2y, ind_P2y] = min(PelvisInertia.Points(:,2));
spanY = abs(L1y)+abs(L2y);

% get points that could be on iliac crests (remaning axis)
[L1_z, ind_P1z] = max(PelvisInertia.Points(:,3));
[L2_z, ind_P2z] = min(PelvisInertia.Points(:,3));
spanZ = abs(L1_z)+abs(L2_z);

% the largest span will identify the iliac crests points and discard other
% directions
if spanY>spanZ
    ind_P1 = ind_P1y;
    ind_P2 = ind_P2y;
else
    ind_P1 = ind_P1z;
    ind_P2 = ind_P2z;
end

if debug_plots == 1 
    figure()
    quickPlotTriang(PelvisInertia)
    plotDot(PelvisInertia.Points(ind_P1,:), 'k', 7);
    plotDot(PelvisInertia.Points(ind_P2,:), 'k', 7);
    title('Points should be external points in the iliac wings (inertia ref syst)')
end

% these are the most external points in the iliac wings
% these are iliac crest tubercles (ICT)
P1 = pelvisTri.Points(ind_P1,:);
P2 = pelvisTri.Points(ind_P2,:);
P3 = (P1+P2)/2;% midpoint

if debug_plots == 1 
    figure()
    quickPlotTriang(pelvisTri)
    plotDot(P1, 'k', 7);
    plotDot(P2, 'k', 7);
    plotDot(P3, 'k', 7);
    title('Points should be external points in the iliac wings (glob ref syst)')
end

% upward vector (perpendicular to X0)
upw_ini = normalizeV(P3-CenterVol');
upw = upw_ini-(upw_ini'*X0)*X0;

% vector pointing upward is Z
[~, ind_Z] = max(abs(V_all'*upw));
Z0 = V_all(:,ind_Z);
Z0 = sign(upw'*Z0)*Z0;

if debug_plots == 1
    plotArrow(Z0, 1, CenterVol, 60, 1, 'b')
end

% Until now I have used GIBOC convention, now I build the ISB one!
% X0 = X0_ISB, Z0 = Y_ISB
RotPseudoISB2Glob = [X0,  Z0, cross(X0, Z0)];

% export markers
BL.ICT1 = P1;
BL.ICT2 = P2;

% debug Plots
if debug_plots
    figure()
    hold on; axis equal
    % define a ref system to plot
    temp.V = RotPseudoISB2Glob;
    temp.Origin = P3;
    % plot axes of pelvis (GIBOC)
%     pl3tVectors(CenterVol, X0, 125);
%     pl3tVectors(CenterVol, Y0, 175);
%     pl3tVectors(CenterVol, Z0, 250);
    % plot pelvis, convex hull and largest identified triangle
    trisurf(pelvisTri,'facealpha',0.5,'facecolor','b', 'edgecolor','none');
    trisurf(PelvisConvHull,'facealpha',0.2,'facecolor','c','edgecolor',[.3 .3 .3], 'edgealpha', 0.2);
    trisurf(LargestTriangle,'facealpha',0.8,'facecolor','r','edgecolor','k');
    % plot axes of pelvis (ISB)
    quickPlotRefSystem(temp)
    % plot landmarks
    plotDot(P1, 'k', 7);
    plotDot(P2, 'k', 7);
    plotDot(P3, 'k', 7);
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
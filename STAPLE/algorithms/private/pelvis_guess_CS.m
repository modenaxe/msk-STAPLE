%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [RotPseudoISB2Glob, LargestTriangle, BL] = pelvis_guess_CS(Pelvis, debug_plots)
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

% smaller moment of inertia is normally the medio/lateral axis. It will be
% updated anyway. It can be checked using D from TriInertiaPpties.m
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
    quickPlotTriang(Pelvis)
    plotArrow(X0, 1, CenterVol, 60, 1, 'r')
    plotArrow(Y0_temp, 1, CenterVol, 60, 1, 'g')
    plotArrow(Z0, 1, CenterVol, 60, 1, 'b')
    title('X0 shold be pointing anteriorly - no interest in other axes')
end

% transform the pelvis to the new set of inertial axes
[ PelvisInertia, ~ , ~ ] = TriChangeCS(Pelvis, [X0, Y0_temp, Z0]', CenterVol);

if debug_plots == 1 
    figure()
    quickPlotTriang(PelvisInertia)
    plotArrow([1, 0, 0]', 1, [0 0 0]', 60, 1, 'r')
    plotArrow([0, 1, 0]', 1, [0 0 0]', 60, 1, 'g')
    plotArrow([0, 0, 1]', 1, [0 0 0]', 60, 1, 'b')
    title('Check axes of inertia orientation')
end

% [~, ind_medLat] = max(abs(Y0_temp));
[L1y, ind_P1y] = max(PelvisInertia.Points(:,2));
[L2y, ind_P2y] = min(PelvisInertia.Points(:,2));
spanY = abs(L1y)+abs(L2y);

[L1_z, ind_P1z] = max(PelvisInertia.Points(:,3));
[L2_z, ind_P2z] = min(PelvisInertia.Points(:,3));
spanZ = abs(L1_z)+abs(L2_z);

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
P1 = Pelvis.Points(ind_P1,:);
P2 = Pelvis.Points(ind_P2,:);
P3 = (P1+P2)/2;% midpoint

if debug_plots == 1 
    figure()
    quickPlotTriang(Pelvis)
    plotDot(P1, 'k', 7);
    plotDot(P2, 'k', 7);
    plotDot(P3, 'k', 7);
    title('Points should be external points in the iliac wings (glob ref syst)')
end

%upward vector (perpendicular to X0)
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

%% Debug Plots
if debug_plots
    figure()
    hold on
    axis equal
    temp.V = RotPseudoISB2Glob;
    temp.Origin = P3;
%     pl3tVectors(CenterVol, X0, 125);
%     pl3tVectors(CenterVol, Y0, 175);
%     pl3tVectors(CenterVol, Z0, 250);
    trisurf(Pelvis,'facealpha',0.5,'facecolor','b',...
        'edgecolor','none');
    trisurf(PelvisConvHull,'facealpha',0.2,'facecolor','c',...
        'edgecolor',[.3 .3 .3], 'edgealpha', 0.2);
    trisurf(LargestTriangle,'facealpha',0.8,'facecolor','r',...
        'edgecolor','k');
    quickPlotRefSystem(temp)
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
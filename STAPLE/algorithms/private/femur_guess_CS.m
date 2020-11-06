function [ Z0 ] = femur_guess_CS( Femur, debug_plots )
% Function to test putting back together a correct orientation of the femur
% Inputs :
%           Femur : A triangulation of a complete femur
%           debug_plots : A boolean to display plots useful for debugging
%
% Output :
%           Z0 : A unit vector giving the distal to proximal direction
% -------------------------------------------------------------------------
%                           General Idea
% The idea is to exploit the fact that the distal epiphysis of the bone is
% relatively symmetrical relative to the diaphysis axis, while the one from
% the proximal epiphysis is not because of the femoral head.
% So if you deform the femur along the second principal inertial deirection
% which is relatively medial to lateral, the centroid of the distal
% epiphysis should be closer to the first principal inertia axis than the
% one from the proximal epiphysis.
% -------------------------------------------------------------------------
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Luca Modenese, Jean-Baptiste Renault
%-------------------------------------------------------------------------%

%% inputs checks
if nargin<2; debug_plots = 1; end


%% Part Used for developpment
% close all
% clear all
% % load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\VAKHUM_S6_CT\tri\femur_r.mat')
% % load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\P0_MRI\tri\femur_r.mat')
% % load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\LHDL_CT\tri\femur_r.mat')
% load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\TLEM2_MRI\tri\femur_r.mat')
% % Femur = triang_geom;
% Femur = curr_triang;
% debug_plots = 1

%% Get principal inertia axis and then deform the bone
% Get the principal inertia axis of the femur (potentially wrongly orientated)
[ V_all, CenterVol ] = TriInertiaPpties( Femur );
Z0 = V_all(:,1);
Y0 = V_all(:,2);

% Deform the femur along the 2nd principal direction
Pts = bsxfun(@minus,Femur.Points,CenterVol');
Pts_deformed = (Pts*V_all)*[1 0 0; 0 2 0; 0 0 1]*V_all';
Femur = triangulation(Femur.ConnectivityList,bsxfun(@plus,Pts_deformed,CenterVol'));

% Get both epiphysis of the femur (10% of the length at both ends)
% Tricks : Here we use Z0 as the initial direction for
[TrEpi1, TrEpi2] = cutLongBoneMesh(Femur, Z0, 0.10);

%% Get the central 60% of the bone -> The femur diaphysis
LengthBone = max(Femur.Points*Z0) - min(Femur.Points*Z0);
L_ratio = 0.20;
% First remove the top 20% percent
alt_top = max(Femur.Points*Z0) - L_ratio* LengthBone;
ElmtsTmp1 = find(Femur.incenter*Z0<alt_top);
TrTmp1 = TriReduceMesh( Femur, ElmtsTmp1);
TrTmp1 = TriFillPlanarHoles( TrTmp1 );
% Then remove the bottom 20% percent
alt_bottom = min(Femur.Points*Z0) + L_ratio* LengthBone;
ElmtsTmp2 = find(TrTmp1.incenter*Z0>alt_bottom);
TrTmp2 = TriReduceMesh( TrTmp1, ElmtsTmp2);
FemurDiaphysis = TriFillPlanarHoles( TrTmp2 );

%% Get the principal inertia axis of the diaphysis (potentially wrongly orientated)
[ V_all, CenterVol_dia ] = TriInertiaPpties( FemurDiaphysis );
Z0_dia = V_all(:,1);

%% Get the distance of the centroids of each epihyisis part to
%  the diaphysis axis
[ ~, CenterEpi1 ] = TriInertiaPpties( TrEpi1 );
[ ~, CenterEpi2 ] = TriInertiaPpties( TrEpi2 );

distToDiaphAxis1 = norm(cross(CenterEpi1-CenterVol_dia,Z0_dia));
distToDiaphAxis2 = norm(cross(CenterEpi2-CenterVol_dia,Z0_dia));


if distToDiaphAxis1 < distToDiaphAxis2
    % It means that epi1 is the distal epihysis and epi2 the proximal
    U_DistToProx = CenterEpi2 - CenterEpi1;
elseif distToDiaphAxis1 > distToDiaphAxis2
    % It means that epi1 is the proximal epihysis and epi2 the distal
    U_DistToProx = CenterEpi1 - CenterEpi2;
end

% Reorient Z0 of the femur according to the found direction
Z0 = sign(U_DistToProx'*Z0)*Z0;

% Warning flag for unclear results
if abs(distToDiaphAxis1 - distToDiaphAxis2)/(distToDiaphAxis1 + distToDiaphAxis2) < 0.20
    warning("The distance to the femur diaphysis axis for the " + ...
        "femur epihysis where not very different. Orientation of Z0," + ...
        "distal to proximal axis, of the femur could be incorrect.")
end

if debug_plots
    figure()
    pl3t(CenterEpi1,'r*')
    hold on
    pl3t(CenterEpi2,'b*')
    pl3tVectors(CenterVol_dia, Z0_dia, 200);
    pl3tVectors(CenterVol_dia, -Z0_dia, 200);
    pl3tVectors(CenterVol, Z0, 300);
    pl3tVectors(CenterVol, -Y0, 50);
    pl3tVectors(CenterVol, Y0, 50);
    trisurf(Femur,'facealpha',0.5,'facecolor','cyan','edgecolor','none')
    axis equal; grid on
end
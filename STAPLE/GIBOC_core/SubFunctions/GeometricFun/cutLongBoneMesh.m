% CUTLONGBONEMESH Separate the Mesh of long bone in two parts:
%   a proximal and a distal one.
% inputs :
%       TrLB        The triangulation of a long bone
%       U_0         A unit vector defining the wanted distal to proximal 
%                   orientation of the principal direction
%       L_ratio     The ratio of the bone length kept to define the prox. 
%                   and distal part of the long bone.
%
% Outputs:
%       TrProx      Triangulation of the proximal part of the long bone
%       TrDist      Triangulation of the distal part of the long bone
%
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault 
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [TrProx, TrDist] = cutLongBoneMesh(TrLB, U_0, L_ratio)

% to customize cuts of the entire bone
if nargin < 2
    U_0 = [0; 0; 1];
    warning("Distal to proximal direction of long bone is based on the"+...
        " assumption that the bone distal to proximal axis is oriented"+...
        " +Z_CT or +Z_MRI vector of the imaging system. If it's not"+...
        " the case the results might be wrong.")
    L_ratio = 0.33;
elseif nargin == 2
    L_ratio = 0.33;
end

% Get eigen vectors V_all of the Long Bone 3D geometry and volumetric center
[ V_all, ~ ] = TriInertiaPpties( TrLB );

% Initial estimate of the Distal-to-Proximal (DP) axis Z0
Z0 = V_all(:,1);

% Reorient Z0 according to U_0
Z0 = sign(U_0'*Z0)*Z0;

% Fast and dirty way to split the bone
LengthBone = max(TrLB.Points*Z0) - min(TrLB.Points*Z0);

% create the proximal bone part
Zprox = max(TrLB.Points*Z0) - L_ratio* LengthBone;
ElmtsProx = find(TrLB.incenter*Z0>Zprox);
TrProx = TriReduceMesh( TrLB, ElmtsProx);
TrProx = TriFillPlanarHoles( TrProx );

% create the distal bone part
Zdist = min(TrLB.Points*Z0) + L_ratio* LengthBone;
ElmtsDist = find(TrLB.incenter*Z0<Zdist);
TrDist = TriReduceMesh( TrLB, ElmtsDist);
TrDist = TriFillPlanarHoles( TrDist );


% figure()
% % Plot the whole tibia, here ProxTib is a Matlab triangulation object
% % trisurf(TrDist,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',1,'edgecolor','none');
% % hold on
% % axis equal
% 
% trisurf(TrDist,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',0.7,'edgecolor','none');
% hold on
% axis equal
% trisurf(TrProx,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',0.7,'edgecolor','none');
% lighting gouraud

% Alt = linspace( min(TrLB.Points*Z0)+0.5 ,max(TrLB.Points*Z0)-0.5, 100);
% Area= zeros(size(Alt));
% i=0;
% for d = -Alt
%     i = i + 1;
%     [ ~ , Area(i), ~ ] = TriPlanIntersect(TrLB, Z0 , d );
% end





end


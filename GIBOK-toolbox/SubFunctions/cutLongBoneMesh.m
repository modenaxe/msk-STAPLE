function [TrProx, TrDist] = cutLongBoneMesh(TrLB, varargin)
%CUTLONGBONEMESH Separate the Mesh of long bone in two parts:
%   a proximal and a distal one.
% WARNING : Assumption about the CT coordinate system :
%               Zct is approximately distal to proximal

% to customize cuts of the entire bone
if isempty(varargin)
    L_ratio = 0.33;
else
    L_ratio = varargin{1};
end

% Get eigen vectors V_all of the Long Bone 3D geometry and volumetric center
[ V_all, ~ ] = TriInertiaPpties( TrLB );

% Initial estimate of the Distal-to-Proximal (DP) axis Z0
Z0 = V_all(:,1);

% Assumption CT CS orientation
Z0 = sign(Z0(3))*Z0;

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


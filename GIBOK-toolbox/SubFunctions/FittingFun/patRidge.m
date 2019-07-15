function [ PatRidgeVariability] = patRidge( x, triMesh , StartDist, EndDist, nbCuts)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% theta = x(1);
% 
% 
% V = [cos(theta);sin(theta);0];
% U = [-sin(theta);cos(theta);0];

V = [cos(x);sin(x);0];
U = [-sin(x);cos(x);0];


if nargin<3
    StartDist = 0.05*range(triMesh.Points*U);
    EndDist = 0.05*range(triMesh.Points*U);
    nbCuts = 50;
end

if StartDist<=0 || EndDist<=0
    StartDist = 0.05*range(triMesh.Points*U);
    EndDist = 0.05*range(triMesh.Points*U);
end

if nbCuts < 5
    Alt = min(triMesh.Points*U)+StartDist:1:max(triMesh.Points*U)-EndDist;
else
    Alt = linspace( min(triMesh.Points*U)+StartDist ,max(triMesh.Points*U)-EndDist, nbCuts);
end
LowestPoints = zeros(length(Alt),3);
i=0;

% figure(15)
for d = -Alt
    i=i+1;
    
    [ Curves , ~ , ~ ] = TriPlanIntersect( triMesh, U , d );
    EdgePts = vertcat(Curves(:).Pts);
    [~,lowestPointID] = min(EdgePts(:,3));
    LowestPoints(i,:) = EdgePts(lowestPointID(1),:);
%     
%     pl3t(Curves(1).Pts,'b-')
%     hold on
%     pl3t(LowestPoints(i,:),'r*')
%     axis equal
%     
    
end

% hold off

PatRidgeVariability = std(LowestPoints*V);

% figure(10)
% plot(LowestPoints(:,1),LowestPoints(:,2),'b.')

% pause(0.3)




end
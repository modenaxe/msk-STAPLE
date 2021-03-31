%TriPlanIntersect:  Intersection between a 3D Triangulation object (Tr)
%                   and a 3D plan defined by normal vector n , d
% Output :
%   Curves:         a structure containing the diffirent intersection profile
%                   if there is only one Curves(1).Pts gives the intersection
%                   curve ordered points vectors (forming a polygon)
%   TotArea:        Total area of the cross section accounting for holes
%   InterfaceTri:   sparse Matrix with n1 x n2 dimension where n1 and n2 are
%                   number of faces in surfaces
% 
% -------------------------------------------------------------------------
% ONLY TESTED : on closed triangulation resulting in close intersection
% curve
% -------------------------------------------------------------------------
%  Author:   Jean-Baptiste Renault
%  Copyright 2020 Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [ Curves , TotArea , InterfaceTri ] = TriPlanIntersect( Tr, n , d, debug_plots )

% Check Arguments in
if nargin < 3
    error("Not engough input argument for TriPlanIntersect");
elseif nargin == 3
    debug_plots = 0;
end

Pts = Tr.Points;
n = [n(1); n(2); n(3)];
n=n/norm(n);
% If d is a point on the plane and not the d parameter of the plane equation
if length(d)>2
    Op = [d(1) d(2) d(3)];
    if size(d,2)==1
        d = -d'*n;
    elseif size(d,1)==1
        d = -d*n;
    else
        error('Third input must be an altitude or a point on plane')
    end
else
    % Get a point on the plane
    [~,n_principal_dir] = max(abs(n));
    Pts1 = Pts(1,:);
    Op = Pts1;
    Pts1(n_principal_dir) = 0;
    Op(n_principal_dir) = (-Pts1*n-d)/n(n_principal_dir);
end

%% Find the intersected elements (triagles
% Get Points (vertices) list as being over or under the plan
Pts_OverUnder = (Pts*n + d > 0) - (Pts*n + d < 0);

if sum(Pts_OverUnder==0)>0
    warnings("Points were found lying exactly on the intersecting" +...
        " plan, this case might not be correctly handled")
end

% Get the facets,elements/triangles/ intersecting the plan
Elmts = Tr.ConnectivityList;
Elmts_IntersectScore = sum(Pts_OverUnder(Elmts),2);
Elmts_Intersecting =  Elmts(abs(Elmts_IntersectScore)<3,:);

%% Check the existence of an interaction
if isempty(Elmts_Intersecting)
    TotArea = 0;
    InterfaceTri = [];
    Curves = struct();
    Curves(1).NodesID = [];
    Curves(1).Pts = [];
    Curves(1).Area = 0;
    Curves(1).Hole = 0;
    Curves(1).Text = 'No Intersection';
    warning("No intersection found between the plane and the triangulation")
    return
end

%% Find the Intersecting Edges among the intersected elements
% Get an edge list from intersecting elmts
Nb_InterSectElmts = size(Elmts_Intersecting,1);
Edges = zeros(3*Nb_InterSectElmts, 2);

i = 1:Nb_InterSectElmts;
Edges(3*i-2,:) = Elmts_Intersecting(i,1:2);
Edges(3*i-1,:) = Elmts_Intersecting(i,2:3);
Edges(3*i,:) = Elmts_Intersecting(i,[3,1]);


% Identify the edges crossing the plane
% They will have an edge status of 0
Edges_Status = sum(Pts_OverUnder(Edges),2);

I_Edges_Intersecting = find(Edges_Status ==0);

%% Find the edge plane intersecting points
% start and end points of each edges
P0 = Pts(Edges(I_Edges_Intersecting,1),:);
P1 = Pts(Edges(I_Edges_Intersecting,2),:);

% Vector of the edge
u = P1-P0;
% Get vectors from point on plane (Op) to edge ends
v = bsxfun(@minus, P0, Op);

EdgesLength = u*n;
EdgesUnderPlaneLength = -v*n;

ratio = EdgesUnderPlaneLength ./ EdgesLength;
% Get Intersectiong Points Coordinates
PtsInter = P0 + u.*ratio;

%% Make sure the shared edges have the same intersection Points
% Build an edge correspondance table
EdgeCorrepondance = zeros(3*Nb_InterSectElmts,1);
EdgeNbOccurences = zeros(3*Nb_InterSectElmts,1);
for i=I_Edges_Intersecting'
    j = find(Edges(:,2) == Edges(i,1) & Edges(:,1) == Edges(i,2));
    EdgeNbOccurences(i) = EdgeNbOccurences(i) + 1;
    EdgeNbOccurences(j) = EdgeNbOccurences(j) + 1;
    if EdgeNbOccurences(i) == 2
        EdgeCorrepondance(i) = j;
    elseif EdgeNbOccurences(i) == 1
        EdgeCorrepondance(i) = i;
    else
        warning("Intersecting edge appear in 3 triangles, not good")
    end
end

% Get edge intersection point
Edge_IntersectionPtsIndex = zeros(3*Nb_InterSectElmts,1);
Edge_IntersectionPtsIndex(I_Edges_Intersecting) = 1:length(I_Edges_Intersecting);
% Don't use intersection point duplicate: only one intersection point per
% edge
Edge_IntersectionPtsIndex(I_Edges_Intersecting) = ...
    Edge_IntersectionPtsIndex(EdgeCorrepondance(I_Edges_Intersecting));


%% Get the segments intersecting each triangle
% The segments are: [Intersecting Point 1 ID , Intersecting Point 2 ID]
Segments = Edge_IntersectionPtsIndex(Edge_IntersectionPtsIndex>0);
Segments = reshape(Segments, 2, [])';



%% Separate the edges to curves structure containing close curves
j=1;
Curves=struct();
i=1;
while ~isempty(Segments)
    % Initialise the Curves Structure, if there are multiple curves this
    % will lead to trailing zeros that will be removed afterwards
    Curves(i).NodesID = zeros(length(PtsInter),1);
    
    % Initialise the first segment
    Curves(i).NodesID(j)=Segments(1,1);
    Curves(i).NodesID(j+1)=Segments(1,2);
    
    % Remove the semgents added to Curves(i) from the segments matrix
    Segments(1,:)=[];
    j=j+1;
    
    % Find the edge in segments that has a node already in the curves(i).NodesID
    % This edge will be the next edge of the current curve because it's
    % connected to the current segment
    % Is, the index of the next edge
    % Js, the index of the node within this edge already present in NodesID
    [Is,Js] = ind2sub(size(Segments),find(Segments(:) == Curves(i).NodesID(j)));
    
    % Nk is the node of the previuously found edge that is not in the
    % current curves(i).NodeID list
    % round(Js+2*(1.5-Js)) give 1 if Js = 2 and 2 if Js = 1
    % It gives the other node not yet in NodesID of the identified next edge
    Nk = Segments(Is,round(Js+2*(1.5-Js)));
    Segments(Is,:)=[];
    j=j+1;
    % Loop until there is no next node
    while ~isempty(Nk)
        Curves(i).NodesID(j) = Nk;
        [Is,Js] = ind2sub(size(Segments),find(Segments(:) == Curves(i).NodesID(j)));
        Nk = Segments(Is,round(Js+2*(1.5-Js)));
        Segments(Is,:)=[];
        j=j+1;
    end
    % If there is on next node then we move to the next curve
    i=i+1;
end

%% Compute the area of the cross section defined by the curve

% Deal with cases where a cross section presents holes

% Get a matrix of curves inclusion -> CurvesInOut :
%   If the curve(i) is within the curve(j) then CurvesInOut(i,j) = 1
%   else  CurvesInOut(i,j) = 0
CurvesInOut = zeros(length(Curves));
for i = 1 : length(Curves)
    Curves(i).NodesID(Curves(i).NodesID==0) = [];
    Curves(i).Pts = PtsInter(Curves(i).NodesID,:);
    % Replace the close curve in coordinate system where X, Y or Z is 0, in
    % order to use polyarea
    [V,~]= eig(cov(Curves(i).Pts));
    CloseCurveinRplanar1 = V'*Curves(i).Pts';
    
    % Get the area of the section defined by the curve i.
    %   /!\ the curve.Area value Do not account for the area of potential 
    %   holes in the section described by curve i.
    Curves(i).Area = polyarea(CloseCurveinRplanar1(2,:), ...
        CloseCurveinRplanar1(3,:));
    
    for j =  1 : length(Curves)
        if i~=j
            Curves(j).NodesID(Curves(j).NodesID==0) = [];
            Curves(j).Pts =PtsInter(Curves(j).NodesID,:);
            % Replace the close curve in coordinate system where X, Y or Z is 0, in
            % order to use polyarea
            CloseCurveinRplanar2 = V'*Curves(j).Pts';
            
            % Check if the curve(i) is within the curve(j)
            if inpolygon(CloseCurveinRplanar1(2,1),CloseCurveinRplanar1(3,1),...
                    CloseCurveinRplanar2(2,:),CloseCurveinRplanar2(3,:))>0
                CurvesInOut(i,j) = 1;
            end
        end
    end
end

% if the curve(i) is within an even number of curves then its area must
% be added to the total area. If the curve(i) is within an odd number
% of curves then its area must be substracted from the total area
TotArea = 0;
for i = 1 : length(Curves)
    AddOrSubstract = 1 - 2*mod( sum(CurvesInOut(i,:)), 2);
    Curves(i).Hole = -AddOrSubstract; %1 if hole -1 if filled
    TotArea = TotArea - Curves(i).Hole*Curves(i).Area;
end


%% Nargout
if nargout == 3
    I_X = find(abs(Elmts_IntersectScore)<3);
    InterfaceTri = TriReduceMesh(Tr, I_X);
end

%% Debug plots
if debug_plots
    I_X = find(abs(Elmts_IntersectScore)<3);
    InterfaceTri = TriReduceMesh(Tr, I_X);
    
    [V_all, CenterVol] = TriInertiaPpties(Tr);
    hold on
    axis equal
    pl3tVectors(CenterVol, V_all(:,1), 250);
    pl3tVectors(CenterVol, V_all(:,2), 100);
    pl3tVectors(CenterVol, V_all(:,3), 175);
    trisurf(Tr,'facealpha',0.6,'facecolor','b',...
        'edgecolor','none');
    trisurf(InterfaceTri,'facealpha',0.7,'facecolor','r',...
        'edgecolor',[.5 .5 .5], 'edgealpha', 0.7);
    for j = 1:length(Curves)
        pl3t(Curves(j).Pts,'k-.')
    end
    % handle lighting of objects
    light('Position',CenterVol + 500*V_all(:,2) + 500*V_all(:,3),'Style','local')
    light('Position',CenterVol + 500*V_all(:,2) -  500*V_all(:,3),'Style','local')
    light('Position',CenterVol - 500*V_all(:,2) + 500*V_all(:,3) - 500*V_all(:,1),'Style','local')
    light('Position',CenterVol - 500*V_all(:,2) -  500*V_all(:,3) + 500*V_all(:,1),'Style','local')
    lighting gouraud
    % Remove grid
    grid off
end



end
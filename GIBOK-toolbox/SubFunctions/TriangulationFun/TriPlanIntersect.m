function [ Curves , TotArea , InterfaceTri ] = TriPlanIntersect( Tr, n , d, debug_plots )
%TriPlanIntersect:  Intersection between a 3D Triangulation object (Tr)
%                   and a 3D plan defined by normal vector n , d
% Output :
%   Curves:         a structure containing the diffirent intersection profile
%                   if there is only one Curves(1).Pts gives the intersection
%                   curve ordered points vectors (forming a polygon)
%   TotArea:        Total area of the cross section accounting for holes
%   InterfaceTri:   sparse Matrix with n1 x n2 dimension where n1 and n2 are
%                   number of faces in surfaces


%% Check Arguments in
if nargin < 3
    error("Not engough input argument for TriPlanIntersect");
elseif nargin == 3
    debug_plots = 0;
end

%% Get a bounding box of the triangulation Tr at the plan level
Pts = Tr.Points;
[ Pts_Proj ] = ProjectOnPlan( Pts , n , d );

% Get a random vector to construct a CS in the plane
while 1
    Utmp = normalizeV(randn(3,1));
    if Utmp'*n < 0.5
        break
    end
end

% Construct the plan CS
V = normalizeV( cross(n, Utmp) );
U = cross(V, n);
ProjCS = [U, V, n];

% Pts_Proj should be moved to the plan CS to get bounding rectangle and
% then moved back to the current imaging CS
Pts_ProjinCS = Pts_Proj*ProjCS;
altProjCS = mean(Pts_ProjinCS(:,3));

% Corner of the 2D bounding box in the plan CS
Pt1 = [min(Pts_ProjinCS(:,1))-20 min(Pts_ProjinCS(:,2))-20 altProjCS];
Pt2 = [max(Pts_ProjinCS(:,1))+20 min(Pts_ProjinCS(:,2))-20 altProjCS];
Pt3 = [max(Pts_ProjinCS(:,1))+20 max(Pts_ProjinCS(:,2))+20 altProjCS];
Pt4 = [min(Pts_ProjinCS(:,1))-20 max(Pts_ProjinCS(:,2))+20 altProjCS];

% Move the 2D bounding box in original CS
boxPts_inProjCS = [Pt1 ; Pt2 ; Pt3 ; Pt4];
boxPts = boxPts_inProjCS*ProjCS';

%% Convert the bounding box to a triangulation structure
faces = [1 2 3; 3 4 1];
Square.faces = faces;
Square.vertices = boxPts;
% Get a proper triangulation object for debug plotting
TrSquare = triangulation(faces, boxPts);

% Convert the Tr object to a triangulation structure as expected by next
% the SurfaceIntersection function
Tr1.faces = Tr.ConnectivityList;
Tr1.vertices = Tr.Points;

%% Feed the triangulation and plane to the Surface intersection function
% Copyright (c) 2014, Jaroslaw Tuszynski
% All rights reserved.
% ALGORITHM:
% Based on Triangle/triangle intersection test routine by Tomas Möller, 1997.
%  See article "A Fast Triangle-Triangle Intersection Test",
%  Journal of Graphics Tools, 2(2), 1997
%  http://web.stanford.edu/class/cs277/resources/papers/Moller1997b.pdf
%  http://fileadmin.cs.lth.se/cs/Personal/Tomas_Akenine-Moller/code/opttritri.txt
[InterfaceTri, intSurface] = SurfaceIntersection(Tr1, Square);

% Extract the information on the intersection curve.
Segments = intSurface.edges;
PtsInter = intSurface.vertices;


% Check for interaction
if isempty(Segments)
    warning("No intersection found between the plane and the triangulation")
    Curves = struct();
    TotArea = 0;
    return
end

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



%% Debug plots
if debug_plots
    [V_all, CenterVol] = TriInertiaPpties(Tr);
    hold on
    axis equal
    pl3tVectors(CenterVol, V_all(:,1), 250);
    pl3tVectors(CenterVol, V_all(:,2), 100);
    pl3tVectors(CenterVol, V_all(:,3), 175);
    trisurf(Tr,'facealpha',0.6,'facecolor','b',...
        'edgecolor','none');
    trisurf(TrSquare,'facealpha',0.4,'facecolor','r',...
        'edgecolor',[.5 .5 .5], 'edgealpha', 0.8);
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
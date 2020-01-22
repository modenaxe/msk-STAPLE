function [IdCdlPts, U_Axes, Orientation] = processFemoralEpiPhysis(EpiFem, CSs, Inertia_Vects)

% TODO: expose proportion of max edge length

% gets largest convex hull
[ IdxPointsPair , Edges ] = LargestEdgeConvHull(  EpiFem.Points );

% facets are free boundaries if referenced by only one triangle
Idx_Epiphysis_Pts_DF_Slice = unique(EpiFem.freeBoundary);

i=0;
Ikept = [];

% Keep elements that are not connected to the proximal cut and that are
% longer than half of the longest Edge
% NB Edges is an ordered vector -> first is largest
% Maybe median would be less arbitrary?
while length(Ikept) ~= sum(Edges>0.5*Edges(1))
    i=i+1;
    if ~any(IdxPointsPair(i,1)==Idx_Epiphysis_Pts_DF_Slice) &&...
            ~any(IdxPointsPair(i,2)==Idx_Epiphysis_Pts_DF_Slice)
        Ikept(end+1) = i; %#ok<AGROW>
    end
end

% check on number of saved edges
N_edges = size(Edges, 1);
N_saved_edges = size(Ikept,1);
if N_saved_edges/N_edges < 0.1
    warning('Less than 20% edges saved after initial processing.')
end

%Index of nodes identified on condyles:
IdCdlPts = IdxPointsPair(Ikept,:);
 
% % [LM] debugging plot - see the kept points
% plot3(EpiFem.Points(IdCdlPts(:,1),1), EpiFem.Points(IdCdlPts(:,1),2), EpiFem.Points(IdCdlPts(:,1),3),'r*'); hold on
% plot3(EpiFem.Points(IdCdlPts(:,2),1), EpiFem.Points(IdCdlPts(:,2),2), EpiFem.Points(IdCdlPts(:,2),3),'b*')

% Axes vector of points pairs
Axes = EpiFem.Points(IdCdlPts(:,1),:)-EpiFem.Points(IdCdlPts(:,2),:);

% % [LM] debugging plot (see lines of axes)
% P = [EpiFem.Points(IdCdlPts(:,1),:);EpiFem.Points(IdCdlPts(:,2),:)];
% plot3(P(:,1), P(:,2), P(:,3),'-')

I_Axes_duplicate = find(Axes*Axes(round(length(Axes)/2),:)'<0);

% Delete duplicate but inverted Axes
IdCdlPts(I_Axes_duplicate,:)=[];
Axes(I_Axes_duplicate,:)=[];
U_Axes = Axes./repmat(sqrt(sum(Axes.^2,2)),1,3);

% Make all the axes point in the Laterat -> Medial direction
Orientation = round(mean(sign(U_Axes*CSs.Y0)));
U_Axes = Orientation*U_Axes;
Axes = Orientation*Axes;

% delete if too far from inertial medio-Lat axis;
% [LM] 0.75 -> acod(0.75) roughly 41 deg
IdCdlPts(abs(U_Axes*Inertia_Vects(:,2))<0.75,:) = [];
U_Axes(abs(U_Axes*Inertia_Vects(:,2))<0.75,:) = [];

% region growing (point, seed, radius)
[ U_Axes_Good] = PCRegionGrowing(U_Axes, normalizeV( mean(U_Axes) )', 0.1);
LIA = ismember(U_Axes,U_Axes_Good,'rows');
U_Axes(~LIA,:) = [];
Axes(~LIA,:) = [];
IdCdlPts(~LIA,:) = [];

end 
%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault. 
%  Modified by Luca Modenese based on GIBOC-knee prototype.
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [IdCdlPts, U_Axes, med_lat_ind] = GIBOC_femur_processEpiPhysis(EpiFem, CSs, Inertia_Vects, edge_threshold, axes_dev_thresh)

debug_plots = 0;
debug_prints = 0;
% default axes_dev_thresh = 0.75;
% default edge_threshold = 0.5;

% gets largest convex hull
[ IdxPointsPair , Edges ] = LargestEdgeConvHull(  EpiFem.Points );

% facets are free boundaries if referenced by only one triangle
Idx_Epiphysis_Pts_DF_Slice = unique(EpiFem.freeBoundary);

i=0;
Ikept = [];

% Keep elements that are not connected to the proximal cut and that are
% longer than half of the longest Edge (default)
% NB Edges is an ordered vector -> first is largest, and vector Ikept
% should store the largest elements
while length(Ikept) ~= sum(Edges>edge_threshold*Edges(1))
    i=i+1;
    if ~any(IdxPointsPair(i,1)==Idx_Epiphysis_Pts_DF_Slice) &&...
            ~any(IdxPointsPair(i,2)==Idx_Epiphysis_Pts_DF_Slice)
        Ikept(end+1) = i; %#ok<AGROW>
    end
end

% check on number of saved edges
if debug_prints
    N_edges = size(Edges, 1);
    N_saved_edges = size(Ikept,1);
    disp(['Processing ', num2str(N_saved_edges/N_edges*100), '% of edges in convex hull.'])
end

%Index of nodes identified on condyles:
IdCdlPts = IdxPointsPair(Ikept,:);
 
% % [LM] debugging plot - see the kept points
if debug_plots
    plot3(EpiFem.Points(IdCdlPts(:,1),1), EpiFem.Points(IdCdlPts(:,1),2), EpiFem.Points(IdCdlPts(:,1),3),'r*'); hold on
    plot3(EpiFem.Points(IdCdlPts(:,2),1), EpiFem.Points(IdCdlPts(:,2),2), EpiFem.Points(IdCdlPts(:,2),3),'b*');
end

% Axes vector of points pairs
Axes = EpiFem.Points(IdCdlPts(:,1),:)-EpiFem.Points(IdCdlPts(:,2),:);

% % [LM] debugging plot (see lines of axes)
if debug_plots
    P = [EpiFem.Points(IdCdlPts(:,1),:);EpiFem.Points(IdCdlPts(:,2),:)];
    plot3(P(:,1), P(:,2), P(:,3),'-')
end

% proper visualization on U_axes (from JB code to Issue #88)
if debug_plots
    figure;
    trisurf(EpiFem,'facealpha',0.4,'facecolor','y',...
        'edgecolor','k'); hold on
    plot3(EpiFem.Points(IdCdlPts(:,1),1), EpiFem.Points(IdCdlPts(:,1),2), EpiFem.Points(IdCdlPts(:,1),3),'r*');
    plot3(EpiFem.Points(IdCdlPts(:,2),1), EpiFem.Points(IdCdlPts(:,2),2), EpiFem.Points(IdCdlPts(:,2),3),'b*');
    for i = 1:length(IdCdlPts(:,1))
        plot3(EpiFem.Points(IdCdlPts(i,:),1), EpiFem.Points(IdCdlPts(i,:),2), EpiFem.Points(IdCdlPts(i,:),3),'k-','LineWidth',3);
    end
    axis equal;
end

% Remove duplicate Axes that are not directed from Lateral to Medial (CSs.Y0)
I_Axes_duplicate = find(Axes*CSs.Y0 < 0);

IdCdlPts(I_Axes_duplicate,:)=[];
Axes(I_Axes_duplicate,:)=[];

%Normalize Axes to get unitary vectors
U_Axes = Axes./repmat(sqrt(sum(Axes.^2,2)),1,3);

% delete if too far from inertial medio-Lat axis;
% [LM] 0.75 -> acod(0.75) roughly 41 deg
ind_deviant_axes = abs(U_Axes*Inertia_Vects(:,2))<axes_dev_thresh;
IdCdlPts(ind_deviant_axes,:) = [];
U_Axes(ind_deviant_axes,:) = [];

% region growing (point, seed, radius)
[ U_Axes_Good] = PCRegionGrowing(U_Axes, normalizeV( mean(U_Axes) )', 0.1);
LIA = ismember(U_Axes,U_Axes_Good,'rows');
U_Axes(~LIA,:) = [];
IdCdlPts(~LIA,:) = [];

% Compute orientation just to check, should be = 1
Orientation = round(mean(sign(U_Axes*CSs.Y0)));

% Assign indices of points on Lateral or Medial Condyles Variable
if Orientation < 0
    warning('Orientation of Lateral->Medial U_Axes vectors of femoral distal epiphysis is not what expected. Please check manually.')
    med_lat_ind = [2 1];
%     IdxPtsCondylesLat = IdCdlPts(:,1);
%     IdxPtsCondylesMed = IdCdlPts(:,2);
else
    med_lat_ind = [1 2];
%     IdxPtsCondylesMed = IdCdlPts(:,1);
%     IdxPtsCondylesLat = IdCdlPts(:,2);
end


end 
function PtTopCondyle = getFemoralCondyleMostProxPoint(EpiFem, CSs, PtsCondylesTrace, U)

sphere_search_radius = 7.5;
plane_search_thick = 2.5;

% fitting a lq plane to point in the trace
% [Centroid,  Direction cosines of the normal to the best-fit plane]
[P_centr, lsplane_norm] = lsplane(PtsCondylesTrace);

% looking for points 2.5 mm away from the fitting plane
dMed = -P_centr*lsplane_norm;
IonPlan = find(abs(EpiFem.Points*lsplane_norm+dMed)<plane_search_thick & ...
    EpiFem.Points*CSs.Z0>max(PtsCondylesTrace*CSs.Z0-plane_search_thick));

% searches points in a sphere around (7.5 mm)
IonC = rangesearch(EpiFem.Points,PtsCondylesTrace,sphere_search_radius);

% intersect the two sets
IOK = intersect(IonPlan,unique([IonC{:}]'));

% top Points indices and points
[~,Imax] = max(EpiFem.vertexNormal(IOK)*U);
PtTopCondyle = EpiFem.Points(IOK(Imax),:);

end
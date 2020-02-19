function [Curve, N_curves] = GIBOK_getLargerPlanarSect(Curves)

N_curves = length(Curves);

% check to use just the tibial curve, as in GIBOK
for nc = 1: N_curves
    [~, Areas(nc)] = PlanPolygonCentroid3D( Curves(1).Pts);
end
[~, ind_max_area] = max(Areas);
Curve = Curves(ind_max_area);

end
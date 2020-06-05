% gets the larger section in a set of curves.
% use mostly by GIBOC_tibia
% Author: LM
function [Curve, N_curves, Areas] = getLargerPlanarSect(Curves)

N_curves = length(Curves);

% check to use just the tibial curve, as in GIBOK
for nc = 1: N_curves
    Areas(nc) = Curves(nc).Area;
end
[~, ind_max_area] = max(Areas);
Curve = Curves(ind_max_area);

end
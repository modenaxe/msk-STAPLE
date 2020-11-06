function CenterAnkleInside = GIBOC_tibia_DistMaxSectCentre(DistTibTri, Z0)

% Z0: proximal-distal vector

% slice dist tibia an get larger area
slice_step = 0.3;
offset = 1;
[~, ~, ~, ~, maxAlt] = TriSliceObjAlongAxis(DistTibTri, Z0, slice_step, offset);

% section where the are is maximum 
Curves = TriPlanIntersect( DistTibTri, Z0 , -maxAlt );

[Curve, N_curves] = getLargerPlanarSect(Curves);

CenterAnkleInside = PlanPolygonCentroid3D(Curve.Pts);

if N_curves>2
    error(['There are ', num2str(length(Curves)), ' section areas.']);
end

end
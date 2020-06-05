function CenterAnkleInside = GIBOC_tibia_DistMaxSectCentre(DistTib, CSs)

Z0 = CSs.Z0;

% slice dist tibia an get larger area
slice_step = 0.3;
offset = 1;
[~, ~, ~, ~, maxAlt] = TriSliceObjAlongAxis(DistTib, Z0, slice_step, offset);

% section where the are is maximum 
Curves = TriPlanIntersect( DistTib, Z0 , -maxAlt );

[Curve, N_curves] = getLargerPlanarSect(Curves);

CenterAnkleInside = PlanPolygonCentroid3D(Curve.Pts);

if N_curves>2
    error(['There are ', num2str(length(Curves)), ' section areas.']);
end

end
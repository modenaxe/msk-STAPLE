function CenterAnkleInside = GIBOK_tibia_DistMaxSectCentre(DistTib, maxAltDist, Z0)

% section where the are is maximum 
Curves = TriPlanIntersect( DistTib, Z0 , maxAltDist );

% slice at maxArea
[Curve, N_curves] = GIBOK_getLargerPlanarSect(Curves);

if N_curves>2
    error(['There are ', num2str(length(Curves)), ' section areas.']);
else
    % compute centroid of largest curve
    CenterAnkleInside = PlanPolygonCentroid3D(Curve.Pts);
end

end
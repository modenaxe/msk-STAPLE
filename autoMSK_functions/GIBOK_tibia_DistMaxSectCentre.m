function CenterAnkleInside = GIBOK_tibia_DistMaxSectCentre(DistTib, CSs)

Z0 = CSs.Z0;

% this should be a slicing function
%=============================
Alt =  min(DistTib.Points*Z0)+1 : 0.3 : max(DistTib.Points*Z0)-1;
Area = zeros(size(Alt));
i=0;
for d = -Alt
    i = i + 1;
    [ ~ , Area(i), ~ ] = TriPlanIntersect( DistTib, Z0 , d );
end
%=============================
[~,Imax] = max(Area);

% section where the are is maximum 
Curves = TriPlanIntersect( DistTib, Z0 , -Alt(Imax) );

[Curve, N_curves] = GIBOK_getLargerPlanarSect(Curves);

CenterAnkleInside = PlanPolygonCentroid3D( Curve.Pts);

if N_curves>2
    error(['There are ', num2str(length(Curves)), ' section areas.']);
end

end
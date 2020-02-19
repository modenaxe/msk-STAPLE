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

N_curves = length(Curves);
% TODO: check to exclude fibula
if N_curves==1
    % compute centroid, which is consider to be the Ankle joint centre
    CenterAnkleInside = PlanPolygonCentroid3D(Curves.Pts);
elseif N_curves>1
    disp(['There are ', num2str(length(Curves)), ' section areas.']);
    warning('fibular is in geometry');
    % compute areas
    [CenterAnkleInside1, Area1] = PlanPolygonCentroid3D( Curves(1).Pts);
    [CenterAnkleInside2, Area2] = PlanPolygonCentroid3D( Curves(2).Pts);
    if abs(Area1)>abs(Area2)
        CenterAnkleInside = CenterAnkleInside1;
    else
        CenterAnkleInside = CenterAnkleInside2;
    end
else
    error(['There are ', num2str(length(Curves)), ' section areas.']);
end
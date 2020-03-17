% Function to test putting back together a correct orientation of the femur
close all
clear all
load('C:\Users\jbapt\Documents\Research\auto-msk-model\test_geometries\VAKHUM_S6_CT\tri\femur_r.mat')

% Get the principal inertia axis (potentially wrongly orientated)
Femur = triang_geom;
[ V_all, CenterVol ] = TriInertiaPpties( Femur );
Z0 = V_all(:,1);

%Get the convexhull of the whole femur
K = convhull(Femur.Points,'simplify', false);
FemurConvHull = triangulation(K,Femur.Points);

Alt = linspace( min(Femur.Points*Z0)+0.5 ,max(Femur.Points*Z0)-0.5, 100);
Area= zeros(size(Alt));
AreaConvHull= zeros(size(Alt));
CentroidsDist = zeros(size(Alt));
Centroids = zeros(size(Alt,2),3);
CentroidsConvHull = zeros(size(Alt,2),3);

it=0;
for d = -Alt
    it = it + 1;
    [ curves , Area(it), ~ ] = TriPlanIntersect(Femur, Z0 , d );
    centroid_tmp = [0 0 0];
    for j = 1:length(curves)
        [ Centroid_j, area_j ] = PlanPolygonCentroid3D( curves(j).Pts );
        centroid_tmp = centroid_tmp + Centroid_j*area_j;
    end
    Centroids(it,:) = centroid_tmp/Area(it);
    
    [ curves , AreaConvHull(it), ~ ] = TriPlanIntersect(FemurConvHull, Z0 , d );
    centroid_tmp = [0 0 0];
    for j = 1:length(curves)
        [ Centroid_j, area_j ] = PlanPolygonCentroid3D( curves(j).Pts );
        centroid_tmp = centroid_tmp + Centroid_j*area_j;
    end
    CentroidsConvHull(it,:) = centroid_tmp/AreaConvHull(it);
    
    CentroidsDist(it) = sqrt(sum(...
        (CentroidsConvHull(it,:)-Centroids(it,:)).^2)); 
end

plot(Alt, Area)
hold on
plot(Alt, AreaConvHull)
plot(Alt, CentroidsDist*500)

figure
pl3t(Centroids,'r*')
hold on
pl3t(CentroidsConvHull,'b*')
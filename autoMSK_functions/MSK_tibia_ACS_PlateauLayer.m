function CS = MSK_tibia_ACS_PlateauLayer(EpiTib, EpiTibAS, CS)


% Compute the inertial axis of a slice of the tp plateau
% 10% below and the 5% above : Fill it with equally spaced points to
% simulate inside volume

% fit a plane to the resulting tibial epiPhysis 
[oLSP, Ztp] = lsplane(EpiTibAS.Points, CS.Z0);
% not exactly as in GIBOK, where d is computed BEFORE the final filters in
% it2.
d = -oLSP*Ztp;

% fit the ellipsoid and define the axes on it
[ Xel, Yel, EllipsePts ] = EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP );
Xel = sign(Xel'* CS.Y0)*Xel;
Yel = sign(Yel'* CS.Y0)*Yel;

% long axis of ellipse
H = 0.1 * sqrt(4*0.75*maxAreaEpiTib/pi);
Alt_TP = linspace( -d-H ,-d+0.5*H, 20);
PointSpace = mean(diff(Alt_TP));
TPLayerPts = zeros(round(length(Alt_TP)*1.1*maxAreaEpiTib/PointSpace^2),3);
j=0;
i=0;
for alt = -Alt_TP
    [ Curves , ~ , ~ ] = TriPlanIntersect( EpiTib, Ztp , alt );
    for c=1:length(Curves)
        NEEDS A CHECK TO BE THE LARGEST AREA!
        Pts_Tmp = Curves(c).Pts*[Xel Yel Ztp];
        xmg = min(Pts_Tmp(:,1)) -0.1 : PointSpace : max(Pts_Tmp(:,1)) +0.1 ;
        ymg = min(Pts_Tmp(:,2)) -0.1 : PointSpace : max(Pts_Tmp(:,2)) +0.1;
        [XXmg , YYmg] = meshgrid(xmg,ymg);
        in = inpolygon(XXmg(:),YYmg(:),Pts_Tmp(:,1),Pts_Tmp(:,2));
        Iin = find(in, 1);
        if ~isempty(Iin)
            i = j+1;
            j=i+length(find(in))-1;
            TPLayerPts(i:j,:) = transpose([Xel Yel Ztp]*[XXmg(in),YYmg(in),ones(length(find(in)),1)*alt]');
        end
    end
    
end

TPLayerPts(j+1:end,:) = [];

% inertial axes of the tibial plateau layer
[V,~] = eig(cov(TPLayerPts));
Xtp = V(:,2); Ytp = V(:,3);
Xtp = sign(Xtp'*Y0)*Xtp;
Ytp = sign(Ytp'*Y0)*Ytp;

idx = kmeans(TPLayerPts,2);

[ CenterMed ] = ProjectOnPlan( mean(TPLayerPts(idx==1,:)) , Ztp , d );
[ CenterLat ] = ProjectOnPlan( mean(TPLayerPts(idx==2,:)) , Ztp , d );

% centre of the knee as midpoint of centroids ? [LM]
KneeCenter = 0.5*( CenterMed + CenterLat);

% Store body info
CS.Origin   = KneeCenter;
CS.Ztibplat = Ztp;
CS.Ytibplat = Ytp;
CS.Xtibplat = Xtp;
% CS.Centroid_med  = TibArtMed_ppt.Center;
% CS.Centroid_lat  = TibArtLat_ppt.Center;

% common axes: X is orthog to Y and Z, which are not mutually perpend
Y = normalizeV(KneeCenter - CenterAnkleInside);
Z = normalizeV(Ytp);
X = cross(Z, Y);

% define the knee reference system
Ydp_knee  = cross(Z, X);
CS.V_knee = [X Ydp_knee Z];
CS.knee_r.child_orientation = computeZXYAngleSeq(CS.V_knee);
% the knee axis is defined by the femoral fitting
% CS.knee_r.child_location = KneeCenter*dim_fact;

% the talocrural joint is also defined by the talus fitting.
% apart from the reference system -> NB: Z axis to switch with talus Z
CS.ankle_r.parent_orientation = computeZXYAngleSeq(CS.V_knee);

end


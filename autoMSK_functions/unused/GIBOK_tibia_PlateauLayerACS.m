function CSs = GIBOK_tibia_PlateauLayerACS(EpiTibAS, CSs)
%% Technic 3 : Compute the inertial axis of a slice of the tp plateau
% 10% below and the 5% above : Fill it with equally spaced points to
% simulate inside volume
%

% fit a plane to the resulting tibial epiPhysis 
[oLSP, Ztp] = lsplane(EpiTibAS.Points,Z0);

[ Xel, Yel, ellipsePts ] = EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP );
Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Yel'*Y0)*Yel;

H = 0.1 * sqrt(4*0.75*max(Area)/pi);

Alt_TP = linspace( -d-H ,-d+0.5*H, 20);
PointSpace = mean(diff(Alt_TP));
TPLayerPts = zeros(round(length(Alt_TP)*1.1*max(Area)/PointSpace^2),3);
j=0;
i=0;
for alt = -Alt_TP
    [ Curves , ~ , ~ ] = TriPlanIntersect( EpiTib, Ztp , alt );
    for c=1:length(Curves)
        
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

[V,~] = eig(cov(TPLayerPts));

Xtp = V(:,2); Ytp = V(:,3);
Xtp = sign(Xtp'*Y0)*Xtp;
Ytp = sign(Ytp'*Y0)*Ytp;

idx = kmeans(TPLayerPts,2);

[ CenterMed ] = ProjectOnPlan( mean(TPLayerPts(idx==1,:)) , Ztp , d );
[ CenterLat ] = ProjectOnPlan( mean(TPLayerPts(idx==2,:)) , Ztp , d );

CenterKnee = 0.5*( CenterMed + CenterLat);

Zmech = CenterKnee - CenterAnkleInside; Zmech = Zmech' / norm(Zmech);

% Final ACS
Xend = cross(Ytp,Zmech)/norm(cross(Ytp,Zmech));
Yend = cross(Zmech,Xend);


Yend = sign(Yend'*Y0)*Yend;
Zend = Zmech;
Xend = cross(Yend,Zend);

Vend = [Xend Yend Zend];

% Result write
CSs.PIAASL.CenterVol = CenterVol;
CSs.PIAASL.CenterAnkle = ankleCenter;
CSs.PIAASL.CenterKnee = CenterKnee;
CSs.PIAASL.Z0 = Z0;
CSs.PIAASL.Ztp = Ztp;
CSs.PIAASL.Ytp = Ytp;
CSs.PIAASL.Xtp = Xtp;

CSs.PIAASL.Origin = CenterKnee;
CSs.PIAASL.X = Xend;
CSs.PIAASL.Y = Yend;
CSs.PIAASL.Z = Zend;

CSs.PIAASL.V = Vend;
CSs.PIAASL.Name='ArtSurfPIA';

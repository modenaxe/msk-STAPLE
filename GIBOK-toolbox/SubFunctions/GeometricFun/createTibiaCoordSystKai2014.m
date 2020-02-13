function CSs = createTibiaCoordSystKai2014(Tibia, CSs)

% NOTE THAT INERTIAL AXES SHOULD ACTUALLY BE PCA OF TIBIA AND FIBULA
% (COMPLETE BONES)

[ V_all, CenterVol, ~, d] = TriInertiaPpties( Tibia );
V_all = pca(Tibia.Points);

Z0 = V_all(:,1);

% pca(Tibia.Points)
error('need to compute ankle joint centre to ensure med-lat axis');
Y0 = normalizeV(  U_tmp' - (U_tmp*Z0)*Z0  ); 

% Z0 = sign((mean(ProxTib.Points)-mean(DistTib.Points))*Z0)*Z0;

% THIS IS INCORRECT: THEY SHOULD BE SLICED USING PCA AXES
% slice the proximal tibia

%===================================
% Alt = linspace( min(ProxTib.Points*Z0)+0.5 ,max(ProxTib.Points*Z0)-0.5, 100);
% Area=[];
% for d = -Alt
%     [ ~ , Area(end+1), ~ ] = TriPlanIntersect( ProxTib, Z0 , d );
% end
% AltAtMax = Alt(Area==max(Area));
%===================================

% % original
% Alt = AltAtMax-0.6:0.05:AltAtMax+0.6;

Alt = linspace( min(Tibia.Points*Z0)+0.5 ,max(Tibia.Points*Z0)-0.5, 400);

Area=[];
quickPlotTriang(Tibia,'m')
for d = -Alt
    [ Curves , Area(end+1), ~ ] = TriPlanIntersect( Tibia, Z0 , d );
    N_Curves = length(Curves);
    for nn = 1:N_Curves
        plot3(Curves(nn).Pts(:,1), Curves(nn).Pts(:,2), Curves(nn).Pts(:,3),'k-', 'LineWidth',3); hold on
    end
end

% Get the bone outline at maximal CSA
AltAtMax = Alt(Area==max(Area));

% check max area
figure; plot(Alt, Area); hold on; plot(AltAtMax, max(Area),'o')

% slice at max area
[ Curves , ~, ~ ] = TriPlanIntersect(Tibia, Z0 , -AltAtMax );

% keep just tibia section (largest outline)
N_Curves = length(Curves);
max_area = 0;
if N_Curves>1
    for nc = 1:N_Curves
    slice = polyshape(Curves(nc).Pts(:,1), Curves(nc).Pts(:,2));
    plot(slice)
    area_curve = area(slice);
    if area_curve>max_area
        max_area = area_curve;
        slice_to_fit = Curves(nc);
    end
    end
else
    slice_to_fit = Curves;
end

% debug plots
quickPlotTriang(Tibia,'m', 1)
for nn = 1:N_Curves
    plot3(slice_to_fit.Pts(:,1), slice_to_fit.Pts(:,2), slice_to_fit.Pts(:,3),'r-', 'LineWidth',4); hold on
end
    
% Move the outline curve points in the inertial ref system, so the vertical
% component (:,1) is on a plane
PtsCurves = vertcat(Curves(:).Pts)*V_all;

% Fit a planar ellipse to the outline of the tibia section
FittedEllipse = fit_ellipse(PtsCurves(:,2), PtsCurves(:,3));

% back to medical images reference system
CenterEllipse = transpose(V_all*[mean(PtsCurves(:,1)); % constant anyway
                                 FittedEllipse.X0_in;
                                 FittedEllipse.Y0_in]);

YElpsMax = V_all*[  0 ;
                   cos(FittedEllipse.phi);
                   -sin(FittedEllipse.phi)];
YElpsMax = sign(Y0'*YElpsMax)*YElpsMax;

EllipsePts = transpose(V_all*[ones(length(FittedEllipse.data),1)*PtsCurves(1) FittedEllipse.data']');

% Construct the Kai et Al. 2014 CS
Zend = Z0;
Xend = normalizeV( cross(YElpsMax,Zend) );
Yend = cross(Zend,Xend);
Yend = normalizeV( sign(Yend'*Y0)*Yend );
Xend = cross(Yend,Zend);

% Result write
CSs.KAI2014.CenterVol = CenterVol;
CSs.KAI2014.CenterKnee = CenterEllipse;
CSs.KAI2014.YElpsMax = YElpsMax;

CSs.KAI2014.Origin  = CenterEllipse;
CSs.KAI2014.X       = Xend;
CSs.KAI2014.Y       = Yend;
CSs.KAI2014.Z       = Zend;

CSs.KAI2014.V       = [Xend Yend Zend];
CSs.KAI2014.ElpsPts = EllipsePts;


end

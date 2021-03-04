%-------------------------------------------------------------------------%
%  Author:   Luca Modenese & Jean-Baptiste Renault. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [CS, JCS] = CS_tibia_PlateauLayer(EpiTib, EpiTibAS, CS, side)

% Compute the inertial axis of a slice of the tp plateau
% 10% below and the 5% above : Fill it with equally spaced points to
% simulate inside volume

% get sign correspondent to body side
[side_sign, side_low] = bodySide2Sign(side);

% joint names
knee_name   = ['knee_', side_low];
ankle_name  = ['ankle_', side_low];

% fit a plane to the resulting tibial epiPhysis 
[oLSP, Ztp] = lsplane(EpiTibAS.Points, CS.Z0);
% not exactly as in GIBOK, where d is computed BEFORE the filters of it2.
d = -oLSP*Ztp;

% fit the ellipsoid and define the axes on it
[ Xel, Yel, EllipsePts ] = fitEllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP );
Xel = sign(Xel'* CS.Y0)*Xel;
Yel = sign(Yel'* CS.Y0)*Yel;

% slice the epiphysis
slice_step = 1; %mm 
[Areas, Alt, maxArea] = TriSliceObjAlongAxis(EpiTib, CS.Z0, slice_step);

% long axis of ellipse
H = 0.1 * sqrt(4*0.75*maxArea/pi);
Alt_TP = linspace( -d-H ,-d+0.5*H, 20);
PointSpace = mean(diff(Alt_TP));
TPLayerPts = zeros(round(length(Alt_TP)*1.1*maxArea/PointSpace^2),3);
j=0;
i=0;
for alt = -Alt_TP
    [ Curves , ~ , ~ ] = TriPlanIntersect( EpiTib, Ztp , alt );
    N_curves = length(Curves);
    for c=1:N_curves
        % [LM] I think JB needs to check here if the algorithm is robust to the
        % presence of fibula
        % [LM] fibula is now removed xternally
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
Xtp = V(:,2); 
Ytp = V(:,3);
Xtp = sign(Xtp'*CS.Y0)*Xtp;
Ytp = sign(Ytp'*CS.Y0)*Ytp;

idx = kmeans(TPLayerPts,2);

[ CenterMed ] = ProjectOnPlan( mean(TPLayerPts(idx==1,:)) , Ztp , d );
[ CenterLat ] = ProjectOnPlan( mean(TPLayerPts(idx==2,:)) , Ztp , d );

% centre of the knee as midpoint of centroids ? [LM]
KneeCenter = 0.5*( CenterMed + CenterLat);

% Store body info
CS.Ztibplat = Ztp;
CS.Ytibplat = Ytp;
CS.Xtibplat = Xtp;

% common axes: X is orthog to Y and Z, which are not mutually perpend
Y = normalizeV(KneeCenter - CS.CenterAnkleInside); % mechanical axis
Z = normalizeV(Ytp)*side_sign;  % pointing laterally (right), medially (left)
X = normalizeV(cross(Y, Z));

%---------- NOTE------------------
% define the knee reference system
% this was my first guess - keep the medio-lateral direction as identified
% by the algorithm. I don't think it's a good idea, because you lose the
% mechanical axis, while you can still keep the frontal plane.
% % Ydp_knee  = normalizeV(cross(Z, X));
% % JCS.(knee_name).V = [X Ydp_knee Z];
%----------------------------------

% define the knee reference system
Zml_knee  = normalizeV(cross(X,Y));
JCS.(knee_name).V = [X Y Zml_knee];

% define knee child
JCS.(knee_name).child_orientation = computeXYZAngleSeq(JCS.(knee_name).V);
JCS.(knee_name).Origin   = KneeCenter';  % [3x1] as Origin should be

% the knee axis (parent) is defined by the femoral fitting
% CS.(knee_name).child_location = KneeCenter*dim_fact;

% the talocrural joint is also defined by the talus fitting.
% apart from the reference system -> NB: Z axis to switch with talus Z
JCS.(ankle_name).parent_orientation = computeXYZAngleSeq(JCS.(knee_name).V);

end


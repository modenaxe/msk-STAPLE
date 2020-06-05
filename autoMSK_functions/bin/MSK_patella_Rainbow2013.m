function [ CS, TrObjects ] = MSK_patella_Rainbow2013( Patella )
% It is assumed here that the patella is in a standard position in the
% imaging device, so that Z0 point toward Superior direction

% structure for storing RS
CS = struct();

% Get eigen vectors V_all of the Tibia 3D geometry and volumetric center
[ V_all, CenterVol, InertiaMatrix ] = TriInertiaPpties( Patella );
CS.CenterVol = CenterVol;
CS.InertiaMatrix = InertiaMatrix;

%%  Check for the Z Inertia axis to always in anterior direction
% Test for circularity, because on one face the surface is spherical and on the arular surface it's
% more like a Hyperbolic Paraboloid, the countour od the cross section have
% different circularity.

% First 0.5 mm in Start and End are not accounted for, for stability.

% initial guess of Antero-Posterior axis
nAP = V_all(:,3);
Alt = linspace( min(Patella.Points*nAP)+0.5 ,max(Patella.Points*nAP)-0.5, 100);
Area=[];
Circularity=[];
for d = -Alt
    [ Curves , Area(end+1), ~ ] = TriPlanIntersect( Patella, nAP , d );
    PtsTmp=[];
    for i = 1 : length(Curves)
        PtsTmp (end+1:end+length(Curves(i).Pts),:) = Curves(i).Pts;
        if isempty(PtsTmp)
            Curves(i).Pts
        end
    end
    % compute the circularity (criteria ? Coefficient of Variation)
    dist2center = sqrt(sum(bsxfun(@minus,PtsTmp,mean(PtsTmp)).^2,2));
    Circularity(end+1) = std(dist2center)/mean(dist2center);
end

% Get the circularity at both first last quarter of the patella
Circularity1stOffSettedQuart = Circularity(Alt<quantile(Alt,0.3) & Alt>quantile(Alt,0.05));
Circularity3rdOffSettedQuart = Circularity(Alt>quantile(Alt,0.7) & Alt<quantile(Alt,0.95));

% Check that the circularity is higher in the anterior part otherwise
% invert AP axis direction :
if mean(Circularity1stOffSettedQuart)<mean(Circularity3rdOffSettedQuart)
    sprintf('invert AP axis')
    V_all(:,3) = - V_all(:,3);
    V_all(:,2) = cross(V_all(:,3),V_all(:,1));
    V_all(:,1) = cross(V_all(:,2),V_all(:,3));
end

% Move the Patella from CS0 to the Principal Inertia Axis CS
PatPIACS = TriChangeCS( Patella, V_all, CenterVol );

% Make sure the Sup-Inf vector points towards the up;
x0 = 0;
nbCuts = 40;
options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton',...
    'MaxFunctionEvaluations',2500,'StepTolerance',1e-9,...
    'MaxIterations',2500,'OptimalityTolerance',1e-9,'Display','final-detailed');
x1_0 = fminunc(@(x)patRidge(x,PatPIACS,1,1,nbCuts),x0,options);
U_0 = [-sin(x1_0);cos(x1_0);0];


Z0 = V_all*U_0;

% It is assumed here that the patella is in a standard position in the
% imaging device, so that Z0 point toward Superior direction
Z0 = sign( Z0(3) ) * Z0;

X0 = -V_all(:,3);
Y0 = cross(Z0,X0);

% Write Results
CS.Theta = x1_0;
CS.Origin = CenterVol';
CS.X = X0;
CS.Y = Y0;
CS.Z = Z0;
CS.V = [X0 Y0 Z0];

quickPlotRefSystem(CS)
end
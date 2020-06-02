% modified by LM in 2020
function [ CS, JCS, PatellaBL_r] = GIBOK_patella( Patella, algorithm, result_plots, in_mm, debug_plots)
% depends on
% LSSLFitPatellaRidge
% patRidgeFit

% check units
if nargin<3;     result_plots = 1;  end
if nargin<4;     in_mm = 1;  end
if nargin<5;     debug_plots = 0;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% structure to store CS
CS = struct();

% Compute the coefficient for morphology operations
CoeffMorpho = computeTriCoeffMorpho(Patella);

% Get eigen vectors V_all of the Tibia 3D geometry and volumetric center
[ V_all, CenterVol, InertiaMatrix ] = TriInertiaPpties( Patella );

% save in structure
CS.CenterVol = CenterVol;
CS.InertiaMatrix = InertiaMatrix;

%%  Identify the ant-post axis (GIBOK Z axis) based on 'circularity'
% Test for circularity, because on one face the surface is spherical and on the arular surface it's
% more like a Hyperbolic Paraboloid, the countour od the cross section have
% different circularity.
CS.V_all = CS_patella_adjustACSBasedOnCircularity(Patella, V_all);

%% Move the Patella from CS0 to the Principal Inertia Axis CS
PatPIACS = TriChangeCS( Patella, V_all, CenterVol );

%% Identify initial guess of patella posterior ridge
% Optimization to find the ridge orientation
U0 = [1;0;0];
U = LSSLFitPatellaRidge( PatPIACS,U0,30);
% Refine the guess with higher number of slices (75 in original GIBOK tool)
N_slices = 75;
[ U, ~ ,LowestPoints_PIACS ] = LSSLFitPatellaRidge( PatPIACS,U, N_slices);
V = [U(2); -U(1); 0];

%% Separate the ridge region from the apex region
% Move the lowest point to CS updated with initial ridge orientation PIACSU
LowestPoints_PIACSU = LowestPoints_PIACS*[U V [0;0;1]];

% Fit a piecewise linear funtion to the points : [ max(a.x+b , c.x+d) ]
fitresult = patRidgeFit(LowestPoints_PIACSU(:,1),LowestPoints_PIACSU(:,3));

% Find the intersection point
Xintrsctn = (fitresult.d-fitresult.b)/(fitresult.a-fitresult.c);

idx = rangesearch([LowestPoints_PIACSU(:,1),LowestPoints_PIACSU(:,3)],...
    [Xintrsctn,fitresult.a*Xintrsctn+fitresult.b],0.15*range(LowestPoints_PIACSU(:,1)));

[~,Imin] = min(LowestPoints_PIACSU(idx{1},3));

% Seperate an inferior and superior part
SizeInf = sum(LowestPoints_PIACSU(:,1) < Xintrsctn);
SizeSup = sum(LowestPoints_PIACSU(:,1) > Xintrsctn);

% Find the point in the updated PIA CS, ACS0
Xcut = LowestPoints_PIACSU(idx{1}(Imin),1);

% Get the ridge region start and end points
if SizeSup > SizeInf
    RidgePts = LowestPoints_PIACSU(LowestPoints_PIACSU(:,1) > Xintrsctn,:);
    StartDist = 1.1*(Xcut - min(LowestPoints_PIACSU(:,1)));
    EndDist = 0.05*range(LowestPoints_PIACSU(:,1));
    Side = +1;
else
    RidgePts = LowestPoints_PIACSU(LowestPoints_PIACSU(:,1) < Xintrsctn,:);
    EndDist = 1.1*(max(LowestPoints_PIACSU(:,1)) - Xcut);
    StartDist = 0.05*range(LowestPoints_PIACSU(:,1));
    Side = -1;
end

%% Update the ridge orientation with optimisation only on the ridge region
[ U, Uridge , LowestPoints_end ] = LSSLFitPatellaRidge( PatPIACS, U, N_slices, StartDist, EndDist);
U = Side*U;

LowestPoints_CS0 = bsxfun(@plus,LowestPoints_end*V_all',CenterVol');

% LS line fit on the ridge and ridge midpoint
Uridge = sign(U'*Uridge)*Uridge;
quickPlotTriang(Patella, 'm')

switch algorithm
    case 'volume-ridge'
        % volume ridge approach
        [CS, JCS] = CS_patella_VolumeRidge(CS, U);
    case 'ridge-line'
        % ridge line approach (ridge Least Square line fit)
        [CS, JCS] = CS_patella_RidgeLine(CS, Uridge, LowestPoints_CS0);
    case 'artic-surf'
        % principal axes of inertia of the articular surface
        [CS, JCS, PatArtSurf] = CS_patella_PIAAS(Patella, CS, Uridge, LowestPoints_CS0, CoeffMorpho);
    otherwise
        error('Please specify an algorithm for processing the patella among ''volume-ridge'', ''ridge-line'' and ''artic-surf''')
end

% landmark bone according to CS (only Origin and CS.V are used)
PatellaBL_r   = LandmarkGeom(Patella, CS, 'patella_r');

% %% Export Identified Objects
% if nargout > 1
%     TrObjects.Patella = Patella;
%     TrObjects.PatArtSurf = ArtSurf;
%     TrObjects.RidgePts_Separated = LowestPoints_CS0;
%     TrObjects.RidgePts_All = bsxfun(@plus,LowestPoints_PIACS*V_all',CenterVol');
% end

% result plot
if result_plots == 1
    figure;
    alpha = 0.5;
%     subplot(2,2,[1,3]);
    PlotTriangLight(Patella, CS, 0)
    quickPlotRefSystem(CS);
    plot3(LowestPoints_CS0(:,1), LowestPoints_CS0(:,2), LowestPoints_CS0(:,3),'k.')
%     quickPlotRefSystem(JCS.patellofemoral_r);
    % add articular surfaces
    if strcmp(algorithm,'artic-surf')
        quickPlotTriang(PatArtSurf, 'b')
    end
    % plot markers
    BLfields = fields(PatellaBL_r);
    for nL = 1:numel(BLfields)
        cur_name = BLfields{nL};
        plotDot(PatellaBL_r.(cur_name), 'k', 2)
    end
end

end

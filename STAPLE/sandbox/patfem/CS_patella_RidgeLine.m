function [CS, JCS] = CS_patella_RidgeLine(CS, Uridge, LowestPoints_CS0, in_mm, debug_plots)

% check units
if nargin<4;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end
if nargin<5 debug_plots = 0; end

% % Uridge in the initial (CT/MRI) coordinate system
UridgeR0 = CS.V_all*Uridge;

% Construct RL ACS
Center3 = mean(LowestPoints_CS0);
Z3 = UridgeR0;
X3 = -CS.V_all(:,3);
Y3 = normalizeV( cross(Z3,X3) );
X3 = cross(Y3,Z3);

% % GIBOC
CSs.RL.X = X3;
CSs.RL.Uridge = Uridge;
CSs.RL.UridgeR0 = UridgeR0;
CSs.RL.Y = Y3;
CSs.RL.Z = Z3;
CSs.RL.V = [X3 Y3 Z3];
CSs.RL.Origin = Center3;

CS.V = CSs.RL.V ;

% ISB aligned axes
JCS.patellofemoral_r.Uridge = Uridge;
% CS.patellofemoral_r.UridgeR0 = UridgeR0; % this is Z3_GIBOC = Y_ISB
JCS.patellofemoral_r.V = [-X3 Z3 Y3];
JCS.patellofemoral_r.Origin = Center3*dim_fact;

if debug_plots
    quickPlotRefSystem(JCS.patellofemoral_r)
end

end
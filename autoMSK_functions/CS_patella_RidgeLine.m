

function CS = CS_patella_RidgeLine(CS, Uridge, LowestPoints_CS0, in_mm)

% check units
if nargin<4;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% extract inertia matrix
V_all = CS.V_all;

% Uridge in the initial (CT/MRI) coordinate system
UridgeR0 = V_all*Uridge;

% Construct RL ACS
Center3 = mean(LowestPoints_CS0);
Z3 = V_all*Uridge;
X3 = -V_all(:,3);
Y3 = normalizeV( cross(Z3,X3) );
X3 = cross(Y3,Z3);

% % GIBOK
% CSs.RL.X = X3;
% CSs.RL.Uridge = Uridge;
% CSs.RL.UridgeR0 = UridgeR0;
% CSs.RL.Y = Y3;
% CSs.RL.Z = Z3;
% CSs.RL.V = [X3 Y3 Z3];
% CSs.RL.Origin = Center3;

% ISB
CS.patellofemoral_r.X = -X3;
CS.patellofemoral_r.Uridge = Uridge;
CS.patellofemoral_r.UridgeR0 = UridgeR0;
CS.patellofemoral_r.Y = Z3;
CS.patellofemoral_r.Z = Y3;
CS.patellofemoral_r.V = [-X3 Z3 Y3];
CS.patellofemoral_r.Origin = Center3*dim_fact;


quickPlotRefSystem(CS.patellofemoral_r)

end
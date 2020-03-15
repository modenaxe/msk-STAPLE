function CS = ACS_patella_VolumeRidge(CS, U, in_mm)

% check units
if nargin<3;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% Technic VR volume ridge
V_all = CS.V_all;
CenterVol = CS.CenterVol;

Z = V_all*U;
X = -V_all(:,3);
Y = cross(Z,X);

% %GIBOK
% CSs.VR.X = X;
% CSs.VR.Y = Y;
% CSs.VR.Z = Z;
% CSs.VR.Theta = -asin(U(1));
% CSs.VR.V = [X Y Z];
% CSs.VR.Origin = CenterVol';


% ISB standards
CS.patellofemoral_r.X = -X;
CS.patellofemoral_r.Y = Z;
CS.patellofemoral_r.Z = cross(-X, Z);
CS.patellofemoral_r.Theta = -asin(U(1));
CS.patellofemoral_r.V = [-X Z cross(-X, Z)];
CS.patellofemoral_r.Origin = CenterVol'*dim_fact;

% quickPlotTriang(Patella, 'm',1)
quickPlotRefSystem(CS.patellofemoral_r)

end
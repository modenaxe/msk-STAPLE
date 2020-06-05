function [CS, JCS] = CS_patella_VolumeRidge(CS, U, in_mm, debug_plots)

% check units
if nargin<3;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end
if nargin<4; debug_plots = 0; end

% % Technic VR volume ridge
% % GIBOK
% Z = CS.V_all*U;
% X = -CS.V_all(:,3);
% Y = cross(Z,X);

% body (ISB direction of axes)
X = CS.V_all(:,3);
Y = CS.V_all*U;
CS.V = [X, Y, cross(X, Y)];
CS.Origin = CS.CenterVol;

% patellofemoral joint
JCS.patellofemoral_r.Theta = -asin(U(1));
JCS.patellofemoral_r.V = CS.V;
JCS.patellofemoral_r.Origin = CS.CenterVol'*dim_fact;
% JCS.patellofemoral_r.child_location = 
% JCS.patellofemoral_r.child_orientation = 

% quickPlotTriang(Patella, 'm',1)
if debug_plots
    quickPlotRefSystem(CS)
end

end
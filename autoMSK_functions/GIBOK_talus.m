function CS = GIBOK_talus(Talus, in_mm, debug_plots)

% check units
if nargin<2;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end
% debug plot default
if nargin<3;  debug_plots =1;  end

% debug plot for fit quadrilater
fit_debug_plot = 0;

%% 1. Indentify the inertia axis of the Talus
% Get eigen vectors V_all of the Talus 3D geometry and volumetric center
[ V_all, CS.CenterVol, CS.InertiaMatrix, CS.D ] = TriInertiaPpties( Talus );

% X0 can be seen as a initial antero-posterior or postero-anterior axis,
% the orientation of Y0 and Z0 can be inconsistent accross subjects because
% the value of their Moment of inertia are quite close (~15% difference. So
% another function is used to initiliaze Z0 and Y0. It fits a quadrilateral
% on the Talus projected onto a plan perpendicular to X0, the edge
% corresponding to the superior face is identified and provide the
% inferior-superior direction intial guess (Z0). Y0 is made perpendicular
% to X0 and Z0.
CS.X0 = V_all(:,1); 

[CS.Z0,CS.Y0] = fitQuadriTalus(Talus, V_all, fit_debug_plot);

% 2.1 Evolution of the cross section area (CSA) along the X0 axis 
slice_step = 0.3;
cut_offset = 0.3;
[Areas, Alt] = TriSliceObjAlongAxis(Talus, CS.X0, slice_step, cut_offset, 1);

% Plot the curves CSA = f(Alt), Alt : Altitude of the section along X0
% figure()
% plot(Alt,Area,'-*')

% Given the shape of the curve we can fit a bi-gaussian curve to identify
% the two maxima of the Area = f(Alt) curve
%   "or" the orientation parameter is positive if X0 is oriented from 
%   posterior to anterior and negative otherwise
%
%   alt_TlNvc_start, gives the altitude along X0 at wich the CSA is maximal
%   and where the TaloNavicular (TlNvc) articular surface could start.
%   
%   alt_TlNeck_start, gives the altitude along x0 at the approximate start
%   of talus neck
%
%   alt_TlTib_start, gives the altitude along X0 at wich articular surface
%   with the tibia can start

[or, alt_TlNvc_start, alt_TlNeck_start, alt_TlTib_start] = ...
                                                    FitCSATalus(Alt, Areas);
% Change X0 orientation if necessary ( or = +/- 1 )
CS.X0 = or*CS.X0;
CS.Y0 = or*CS.Y0;                    

% fit spheres to talonavicular and talocalcaneal
% debug_plot = 1;
subplot(1,2,1); title('Subtalar Joint Axis');
[SubtalarCS, CS] = MSK_talus_ACS_subtalarSpheres(Talus, CS, alt_TlNvc_start, alt_TlNeck_start, debug_plots);

% fit cylinder to talar trochlea
subplot(1,2,2); title('Talocrural Joint Axis');
TalocruralCS = MSK_talus_ACS_trochleaCylinder(Talus, CS, alt_TlNeck_start, alt_TlTib_start, debug_plots);

% store segment info in structure
CS.Origin       = CS.CenterVol;
CS.subtalar_r   = SubtalarCS;
CS.talocrural_r = TalocruralCS;

% define ankle joint
CS.ankle_r.child_location = TalocruralCS.Origin * dim_fact;
CS.ankle_r.child_orientation = computeZXYAngleSeq(TalocruralCS.V_ankle);

% define subtalar joint
CS.subtalar_r.parent_location = SubtalarCS.Origin * dim_fact;
CS.subtalar_r.parent_orientation = computeZXYAngleSeq(SubtalarCS.V_subtalar);
 
end
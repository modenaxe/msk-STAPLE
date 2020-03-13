function [CS, JCS] = GIBOK_talus(Talus, in_mm, result_plots)

% NOTE: CS contains multiple sets of axes:
% * X0-Y0-Z0 : talus axes
% * X1-Y1-Z1 : subtalar joint axes
% * X2-Y2-Z2 : talocrural joint axes

% check units
if nargin<2;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% debug plot default
if nargin<3;  result_plots =1;  end

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
debug_plot_slice = 0;
[Areas, Alt] = TriSliceObjAlongAxis(Talus, CS.X0, slice_step, cut_offset, debug_plot_slice);

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
[CS, Talocalcn_AS, Talonavic_AS] = CS_talus_subtalarSpheres(Talus, CS, alt_TlNvc_start, alt_TlNeck_start);

% fit cylinder to talar trochlea
[CS, TalTrochAS] = CS_talus_trochleaCylinder(Talus, CS, alt_TlNeck_start, alt_TlTib_start);

% segment reference system
% NOTE: CS contains multiple sets of axes:
% * X0-Y0-Z0 : talus axes
% * X1-Y1-Z1 : subtalar joint axes
% * X2-Y2-Z2 : talocrural joint axes
CS.Origin       = CS.CenterVol;
CS.V = [CS.X0, CS.Z0, -CS.Y0];

% define ankle joint
JCS.ankle_r.V = CS.V_ankle_r;
JCS.ankle_r.child_location = CS.ankle_cyl_centre * dim_fact;
JCS.ankle_r.child_orientation = computeZXYAngleSeq(JCS.ankle_r.V);
JCS.ankle_r.Origin = CS.ankle_cyl_centre;

% define subtalar joint
JCS.subtalar_r.V = CS.V_subtalar_r;
JCS.subtalar_r.parent_location = CS.talocalc_centre * dim_fact;
JCS.subtalar_r.parent_orientation = computeZXYAngleSeq(JCS.subtalar_r.V);
JCS.subtalar_r.Origin = CS.talocalc_centre;

if result_plots == 1
    figure 
    % plot talus and ref systems
    subplot(2,2,[1,3]);
    PlotTriangLight(Talus, CS, 0, 0.7);
    quickPlotRefSystem(CS);
    quickPlotRefSystem(JCS.ankle_r, 30);
    quickPlotRefSystem(JCS.subtalar_r, 30);
    
    subplot(2,2,2); 
    %Visually check the Inertia Axis orientation relative to the Talus geometry
    PlotTriangLight(Talus, CS, 0, 0.7);
    %Plot the inertia Axis & Volumic center
%     plotDot( CS.CenterVol', 'k', 2 )
%     plotArrow( CS.X0, 1, CS.CenterVol, 40, 1, 'r')
%     plotArrow( CS.Y0, 1, CS.CenterVol, 40*CS.D(1,1)/CS.D(2,2), 1, 'g')
%     plotArrow( CS.Z0, 1, CS.CenterVol, 40*CS.D(1,1)/CS.D(3,3), 1, 'b')
    
    %Plot the Tl Nvc part
    trisurf(Talonavic_AS,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
    plotSphere(CS.talonav_centre, CS.talonav_radius , 'm' , 0.3)
    plotDot(CS.talonav_centre, 'm', 2 )
    %Plot the Tl Ccn part
    trisurf(Talocalcn_AS,'Facecolor','b','FaceAlpha',1,'edgecolor','none');
    plotSphere(CS.talocalc_centre, CS.talocalc_radius , 'c' , 0.3)
    plotDot(CS.talocalc_centre, 'c', 2 )
    %Plot the axis
    plotCylinder( CS.subtalar_axis, 0.75, CS.subtalar_axis_centre, CS.subtalar_axis_length, 1, 'k')
    title('Subtalar Joint Axis');
%     axis off
%--------------------------------
    subplot(2,2,4); 
    % plot talocrural fitting results
    PlotTriangLight(Talus, CS, 0, 0.6);

    %Plot ref system Axis & Volumic center
%     plotArrow( CS.X2, 1, CenterVol, 40, 1, 'r')
%     plotArrow( CS.Y2, 1, CenterVol, 40*D(1,1)/D(2,2), 1, 'g')
%     plotArrow( CS.Z2, 1, CenterVol, 40*D(1,1)/D(3,3), 1, 'b')
%     plotDot( CS.CenterVol, 'k', 2 )
    
    %Plot the  talar trochlea articular surface
    % trisurf(TlTrcAS0,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
    trisurf(TalTrochAS,'Facecolor','g','FaceAlpha',1,'edgecolor','none');
    
    %Plot the Cylinder and its axis
    plotCylinder( CS.ankle_cyl_axis, CS.ankle_cyl_radius, CS.ankle_cyl_centre, 40, 0.4, 'r')
    plotArrow( CS.ankle_cyl_axis, 1, CS.ankle_cyl_centre, 40, 1, 'k')
    plotDot( CS.ankle_cyl_centre', 'r', 2 )
    title('Talocrural Joint Axis');
%     axis off
end

end
% STAPLE_talus Process the geometry of talus bone to identify the
% talocrural and subtalar joint axes.
%
% [CS, JCS] = STAPLE_talus(    )
%
% Inputs:
%   Talus - 
%
%   result_plots - 
%
%   debug_plots
%
% Outputs:
%   BCS - 
%
%   JCS - 
%
% depends on
% fitQuadriTalus
% FitCSATalus
%
% See also .
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese & Jean-Baptiste Renault. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [BCS, JCS, ArtSurf, AuxCSInfo] = STAPLE_talus(talusTri,...
                                           side_raw,...
                                           result_plots,...
                                           debug_plots,...
                                           in_mm)

% NOTE: CS contains multiple sets of axes:
% * X0-Y0-Z0 : talus axes
% * X1-Y1-Z1 : subtalar joint axes
% * X2-Y2-Z2 : talocrural joint axes

% result plots on by default, debug off
if nargin<2;    side_raw = 'r';          end
if nargin<3;    result_plots = 1;        end
if nargin<4;    debug_plots = 0;         end
if nargin<5;    in_mm = 1;               end
if in_mm == 1;  dim_fact = 0.001;        else;  dim_fact = 1; end

% compute scaling factor for filters
CoeffMorpho = computeTriCoeffMorpho(talusTri);

% get sign correspondent to body side
[~, side_low] = bodySide2Sign(side_raw);

% joint names
ankle_name     = ['ankle_', side_low];
subtalar_name  = ['subtalar_', side_low];

% inform user about settings
disp('---------------------')
disp('   STAPLE - TALUS    '); 
disp('---------------------')
disp(['* Body Side   : ', upper(side_low)]);
disp(['* Fit Method  : ', 'sphere & cylinder']);
disp(['* Result Plots: ', convertBoolean2OnOff(result_plots)]);
disp(['* Debug  Plots: ', convertBoolean2OnOff(debug_plots)]);
disp(['* Triang Units: ', 'mm']);
disp('---------------------')
disp('Initializing method...')

%% 1. Indentify the inertia axis of the Talus
% Get eigen vectors V_all of the Talus 3D geometry and volumetric center
[ V_all, AuxCSInfo.CenterVol, InertiaMatrix, AuxCSInfo.D ] = TriInertiaPpties( talusTri );

% X0 can be seen as a initial antero-posterior or postero-anterior axis,
% the orientation of Y0 and Z0 can be inconsistent across subjects because
% the value of their Moment of inertia are quite close (~15% difference. So
% another function is used to initiliaze Z0 and Y0. It fits a quadrilateral
% on the Talus projected onto a plan perpendicular to X0, the edge
% corresponding to the superior face is identified and provide the
% inferior-superior direction intial guess (Z0). Y0 is made perpendicular
% to X0 and Z0.
AuxCSInfo.X0 = V_all(:,1); 
[AuxCSInfo.Z0,AuxCSInfo.Y0] = fitQuadriTalus(talusTri, V_all, debug_plots);
if debug_plots == 1
    figure;     quickPlotTriang(talusTri)
    AuxCSInfo.Origin = AuxCSInfo.CenterVol;     quickPlotRefSystem(AuxCSInfo)
    AuxCSInfo.Origin = []; % reset
end

% 2.1 Evolution of the cross section area (CSA) along the X0 axis 
disp('Slicing talus along long dimension...')
slice_step = 0.3;
cut_offset = 0.3;
debug_plot_slice = 0;
[Areas, Alt] = TriSliceObjAlongAxis(talusTri, AuxCSInfo.X0, slice_step, cut_offset, debug_plot_slice);

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

[or, alt_TlNvc_start, alt_TlNeck_start, alt_TlTib_start] = fitCSATalus(Alt,...
                                                            Areas,...
                                                            debug_plots);
% Change X0 orientation if necessary ( or = +/- 1 )
AuxCSInfo.X0 = or*AuxCSInfo.X0;
AuxCSInfo.Y0 = or*AuxCSInfo.Y0; 

if debug_plots == 1
    figure;     quickPlotTriang(talusTri)
    AuxCSInfo.Origin = AuxCSInfo.CenterVol;     quickPlotRefSystem(AuxCSInfo)
    AuxCSInfo.Origin = []; % reset
end

% fit spheres to talonavicular and talocalcaneal
disp('Processing subtalar joint artic surfaces:')
[AuxCSInfo, Talocalcn_AS, Talonavic_AS] = CS_talus_subtalarSpheres(talusTri,...
                                                       side_raw,...
                                                       AuxCSInfo,...
                                                       alt_TlNvc_start,...
                                                       alt_TlNeck_start,...
                                                       CoeffMorpho);

% fit cylinder to talar trochlea
disp('Processing talocrural joint artic surfaces:')
[AuxCSInfo, TalTrochAS] = CS_talus_trochleaCylinder(talusTri,...
                                             side_raw,...
                                             AuxCSInfo, ...
                                             alt_TlNeck_start,...
                                             alt_TlTib_start,...
                                             CoeffMorpho);

% exporting articular surfaces
if nargout>2
    disp('Storing articular surfaces for export...')
    ArtSurf.(['talar_trochlea_', side_low])       = TalTrochAS;
    ArtSurf.(['talo_calcn', side_low])  = Talocalcn_AS;
    ArtSurf.(['talo_navic', side_low])  = Talonavic_AS;
end

% segment reference system
% NOTE: CS contains multiple sets of axes:
% * X0-Y0-Z0 : talus axes (to transform)
% * X1-Y1-Z1 : subtalar joint axes
% * X2-Y2-Z2 : talocrural joint axes
% segment reference system
BCS.CenterVol     = AuxCSInfo.CenterVol;
BCS.Origin        = AuxCSInfo.CenterVol;
BCS.InertiaMatrix = InertiaMatrix;
BCS.V = [AuxCSInfo.X0, AuxCSInfo.Z0, -AuxCSInfo.Y0];

% define ankle joint
JCS.(ankle_name).V = AuxCSInfo.V_ankle;
JCS.(ankle_name).child_location = AuxCSInfo.ankle_cyl_centre * dim_fact;
JCS.(ankle_name).child_orientation = computeXYZAngleSeq(JCS.(ankle_name).V);
JCS.(ankle_name).Origin = AuxCSInfo.ankle_cyl_centre;

% define subtalar joint
JCS.(subtalar_name).V = AuxCSInfo.V_subtalar;
JCS.(subtalar_name).parent_location = AuxCSInfo.talocalc_centre * dim_fact;
JCS.(subtalar_name).parent_orientation = computeXYZAngleSeq(JCS.(subtalar_name).V);
JCS.(subtalar_name).Origin = AuxCSInfo.talocalc_centre;

% figure used in paper (bone+articular surfaces)
paper_figure = 0;
if paper_figure == 1
    figure()
    plotTriangLight(talusTri, BCS, 0, 1);
    trisurf(Talonavic_AS,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
    trisurf(Talocalcn_AS,'Facecolor','b','FaceAlpha',1,'edgecolor','none');
    trisurf(TalTrochAS,'Facecolor','g','FaceAlpha',1,'edgecolor','none');
    axis off
    % adjusted lengths of arrow (otherwise too long)
    length_arrow = 30;
    plotArrow( BCS.V(:,1), 1, BCS.Origin, 43, 1, 'r')
    plotArrow( BCS.V(:,2), 1, BCS.Origin, length_arrow, 1, 'g')
    plotArrow( BCS.V(:,3), 1, BCS.Origin, length_arrow, 1, 'b')
end

if result_plots == 1
    figure('Name', ['STAPLE | bone: talus | side: ', side_low])
    % plot talus and ref systems
    subplot(2,2,[1,3]);
    plotTriangLight(talusTri, BCS, 0, 0.7);
%     quickPlotRefSystem(BCS);
    quickPlotRefSystem(JCS.(ankle_name), 30);
    quickPlotRefSystem(JCS.(subtalar_name), 30);
    
    subplot(2,2,2); 
    %Visually check the Inertia Axis orientation relative to the Talus geometry
    plotTriangLight(talusTri, BCS, 0, 0.7);
    
    %Plot the inertia Axis & Volumic center
%     plotDot( CS.CenterVol', 'k', 2 )
%     plotArrow( CS.X0, 1, CS.CenterVol, 40, 1, 'r')
%     plotArrow( CS.Y0, 1, CS.CenterVol, 40*CS.D(1,1)/CS.D(2,2), 1, 'g')
%     plotArrow( CS.Z0, 1, CS.CenterVol, 40*CS.D(1,1)/CS.D(3,3), 1, 'b')
    
    %Plot the Tl Nvc part
    trisurf(Talonavic_AS,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
    plotSphere(AuxCSInfo.talonav_centre, AuxCSInfo.talonav_radius , 'm' , 0.3)
    plotDot(AuxCSInfo.talonav_centre, 'm', 2 )
    %Plot the Tl Ccn part
    trisurf(Talocalcn_AS,'Facecolor','b','FaceAlpha',1,'edgecolor','none');
    plotSphere(AuxCSInfo.talocalc_centre, AuxCSInfo.talocalc_radius , 'c' , 0.3)
    plotDot(AuxCSInfo.talocalc_centre, 'c', 2 )
    %Plot the axis
    plotCylinder( AuxCSInfo.subtalar_axis, 0.75, AuxCSInfo.subtalar_axis_centre, AuxCSInfo.subtalar_axis_length, 1, 'k')
    title('Subtalar Joint Axis');
%     axis off
%--------------------------------
    subplot(2,2,4); 
    % plot talocrural fitting results
    plotTriangLight(talusTri, BCS, 0, 0.6);

    %Plot ref system Axis & Volumic center
%     plotArrow( CS.X2, 1, CenterVol, 40, 1, 'r')
%     plotArrow( CS.Y2, 1, CenterVol, 40*D(1,1)/D(2,2), 1, 'g')
%     plotArrow( CS.Z2, 1, CenterVol, 40*D(1,1)/D(3,3), 1, 'b')
%     plotDot( CS.CenterVol, 'k', 2 )
    
    %Plot the  talar trochlea articular surface
    % trisurf(TlTrcAS0,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
    trisurf(TalTrochAS,'Facecolor','g','FaceAlpha',1,'edgecolor','none');
    
    %Plot the Cylinder and its axis
    plotCylinder( AuxCSInfo.ankle_cyl_axis, AuxCSInfo.ankle_cyl_radius, AuxCSInfo.ankle_cyl_centre, 40, 0.4, 'r')
    plotArrow( AuxCSInfo.ankle_cyl_axis, 1, AuxCSInfo.ankle_cyl_centre, 40, 1, 'k')
    plotDot( AuxCSInfo.ankle_cyl_centre', 'r', 2 )
    title('Talocrural Joint Axis');
%     axis off
end

disp('Done.')

end
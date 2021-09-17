% GIBOC_HUMERUS Automatically define a reference system based on bone
% morphology by fitting analytical shapes to the articular surfaces. 
% The algorithm leverages GIBOC_femur.m, of which it shared the inputs.
% The GIBOC algorithm can also extract articular
% surfaces.
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2021 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function [BCS, JCS, HumerusBL, ArtSurf, AuxCSInfo] = GIBOC_humerus(humerusTri,...
                                                   side_raw,...
                                                   fit_method,...
                                                   result_plots,...
                                                   debug_plots,...
                                                   in_mm)

% NOTE THAT fit_method = 'cylinder' is HARDCODED
fit_method = 'cylinder';

% defaults
if nargin<2;    side_raw = 'r';          end
if nargin<4;    result_plots = 1;        end
if nargin<5;    debug_plots = 0;         end
if nargin<6;    in_mm = 1;               end
if in_mm == 1;  dim_fact = 0.001;        else;  dim_fact = 1; end %placeholder

% get sign correspondent to body side
[~, side_low] = bodySide2Sign(side_raw);

% run a GIBOC_femur-cylinder analysis without plotting anything
[BCS, JCS, ~, ArtSurf, AuxCSInfo] = GIBOC_femur(humerusTri,...
                                                   side_raw,...
                                                   fit_method,...
                                                   0,...
                                                   debug_plots,...
                                                   in_mm);

% landmark bone according to CS but for the humerus (overwrite femoral BL)
HumerusBL   = landmarkBoneGeom(humerusTri, BCS, ['humerus_', side_low]);

% field names used in script
hip_name = ['hip_', side_low];
knee_name = ['knee_', side_low];
glenohumeral_name = ['glenohumeral_', side_low];
elbow_name = ['elbow_', side_low];

% change structs to elbow
JCS.(glenohumeral_name) = JCS.(hip_name);
JCS.(elbow_name) = JCS.(knee_name);

% upd ArtSurf struct
ArtSurf.(glenohumeral_name) = ArtSurf.(hip_name);
ArtSurf.(['dist_humerus_', side_low]) = ArtSurf.(['dist_femur_', side_low]);

% remove femur structs
JCS = rmfield(JCS, {hip_name, knee_name});
ArtSurf = rmfield(ArtSurf, {hip_name, ['dist_femur_', side_low]});

%% plotting

% cut humerus for plotting
[ProxHumTri, DistHumTri] = cutLongBoneMesh(humerusTri, BCS.V(:,3));

label_switch=1;
if result_plots == 1
    figure('Name', ['GIBOC | bone: humerus | fit: ',fit_method,' | side: ', side_low])
    alpha = 0.5;
    
    % plot full femur and final JCSs
    subplot(2,2,[1,3]);
    plotTriangLight(humerusTri, BCS, 0)
    quickPlotRefSystem(JCS.(glenohumeral_name));
    quickPlotRefSystem(JCS.(elbow_name));
    % plot humerus condyle surface
    quickPlotTriang(ArtSurf.condyles_r, 'r', alpha);
    
    % add markers and labels
    plotBoneLandmarks(HumerusBL, label_switch);
    
    % glenohumeral head
    subplot(2,2,2); 
    plotTriangLight(ProxHumTri, BCS, 0); hold on
    quickPlotRefSystem(JCS.(glenohumeral_name));
    plotSphere(AuxCSInfo.CenterFH_Renault, AuxCSInfo.RadiusFH_Renault, 'g', alpha);
    
    % distal humerus
    subplot(2,2,4);
    plotTriangLight(DistHumTri, BCS, 0); hold on
    quickPlotRefSystem(JCS.(elbow_name));
    % plot fitting method
    plotCylinder( AuxCSInfo.Cyl_Y, AuxCSInfo.Cyl_Radius, AuxCSInfo.Cyl_Pt, AuxCSInfo.Cyl_Range*1.1, alpha, 'g')

end
grid off

end


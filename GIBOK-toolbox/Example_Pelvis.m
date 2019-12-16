
clearvars; clc; close all

% SETTING
% the global reference system:
x_pelvis_in_global = [0 -1 0];
y_pelvis_in_global = [0 0 1];
z_pelvis_in_global = [-1 0 0];

addpath(genpath(strcat(pwd,'/SubFunctions')));
addpath(genpath('./SupportFunctions'))
bone_geom_folder = './test_geom_full';

%% Example for a Femur composed of two parts (distal and proximal)
% [Pelvis] = ReadMesh(strcat(bone_geom_folder,'/pelvis_remeshed_10.stl'));
% save('pelvis_remeshed_10', 'Pelvis')
% load(fullfile(bone_geom_folder,'pelvis_sacrum_10'));
load(fullfile(bone_geom_folder,'pelvis_remeshed_10'));

% building the rot mat from global to pelvis ISB (roughly)
RGlob2Pelvis = [x_pelvis_in_global; y_pelvis_in_global; z_pelvis_in_global];

% Get eigen vectors V_all and volumetric center
[eigVctrs, CenterVol, InertiaMatrix ] =  TriInertiaPpties( Pelvis );

% clarifying what I am dealing with
RInert2Glob = eigVctrs;

% aligning pelvis ref system to ISB one provided
[~, ind_x_pelvis] = max(abs(RInert2Glob'*x_pelvis_in_global'));
[~, ind_y_pelvis] = max(abs(RInert2Glob'*y_pelvis_in_global'));
[~, ind_z_pelvis] = max(abs(RInert2Glob'*z_pelvis_in_global'));

% signs of axes
sign_x_pelvis = sign(RInert2Glob'*x_pelvis_in_global');
sign_y_pelvis = sign(RInert2Glob'*y_pelvis_in_global');
sign_z_pelvis = sign(RInert2Glob'*z_pelvis_in_global');
sign_x_pelvis = sign_x_pelvis(ind_x_pelvis);
sign_y_pelvis = sign_y_pelvis(ind_y_pelvis);
sign_z_pelvis = sign_z_pelvis(ind_z_pelvis);

RotISB2Glob = [sign_x_pelvis*eigVctrs(:, ind_x_pelvis),...  
                sign_y_pelvis*eigVctrs(:, ind_y_pelvis),...
                sign_z_pelvis*eigVctrs(:, ind_z_pelvis)];
% RInert2ISB = RInert2Glob*RotISB2Glob';

% generating a triangulated pelvis with coordinate system ISB (see comment
% in function
[ PelvisISB, V ,T ] = TriChangeCS( Pelvis, RotISB2Glob, CenterVol);
% PelvisRS.Z = eigVctrs(:,ind_z_pelvis)';

% search for ASIS
R_side_ind = PelvisISB.Points(:,3)>0;
[~, RASIS_ind] = max(PelvisISB.Points(:,1).*R_side_ind);
[~, LASIS_ind] = max(PelvisISB.Points(:,1).*~R_side_ind);
[x, RPSIS_ind] = min(PelvisISB.Points(:,1).*R_side_ind);
[~, LPSIS_ind] = min(PelvisISB.Points(:,1).*~R_side_ind);

% extract points
RASIS = [Pelvis.Points(RASIS_ind,1),Pelvis.Points(RASIS_ind,2), Pelvis.Points(RASIS_ind,3)];
LASIS = [Pelvis.Points(LASIS_ind,1),Pelvis.Points(LASIS_ind,2), Pelvis.Points(LASIS_ind,3)];
RPSIS = [Pelvis.Points(RPSIS_ind,1),Pelvis.Points(RPSIS_ind,2), Pelvis.Points(RPSIS_ind,3)];
LPSIS = [Pelvis.Points(LPSIS_ind,1),Pelvis.Points(LPSIS_ind,2), Pelvis.Points(LPSIS_ind,3)];


% defining the ref system (global)
PelvisOr = (RASIS+LASIS)'/2.0;
Z = (RASIS-LASIS)/norm(RASIS-LASIS);
temp_X = ((RASIS+LASIS)/2.0) - ((RPSIS+LPSIS)/2.0);
pseudo_X = temp_X/norm(temp_X);
Y = cross(Z, pseudo_X)/norm(cross(Z, pseudo_X));
X = cross(Y, Z)/norm(cross(Y, Z));

% ISB reference system
PelvisRS.Origin = PelvisOr;
PelvisRS.X = X;
PelvisRS.Y = Y;
PelvisRS.Z = Z;
PelvisRS.V = [X', Y', Z'];
PlotPelvis( PelvisRS, Pelvis )

save('PelvisRS', 'PelvisRS')

% % intermediate plot with inertial axis and center of volume
% PelvisRS.Origin = CenterVol;
% PelvisRS.X = RotISB2Glob(:,1)';
% PelvisRS.Y = RotISB2Glob(:,2)';
% PelvisRS.Z = RotISB2Glob(:,3)';
% PlotPelvis( PelvisRS, Pelvis )

% defining the ref system (ISB) - TO VERIFY THAT THE TRANSFORMATION WORKED
% PelvisISBRS.Origin = [0 0 0]';
% PelvisISBRS.X = [1 0 0];
% PelvisISBRS.Y = [0 1 0];
% PelvisISBRS.Z = [0 0 1];
% PlotPelvis( PelvisISBRS, PelvisISB )
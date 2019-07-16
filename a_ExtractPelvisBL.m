% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %
%

clear;clc; close all

addpath(genpath('./SupportFunctions'))
% ======================= SETTINGS ===========================
% GEOMETRIES WITHOUT SACRUM
bone_geom_file = '_test_geom/pelvis_LHDL_remeshed_10.stl';
density = 1;
%=============================================================

% import mesh
stl_file_path = fullfile(bone_geom_file);
[v_MRI, f, n, c, stltitle] = stlread(stl_file_path, 1);

% ====== calculating inertia tensor as point cloud =======
MassInfo = calcMassInfo_Mirtich1996(v_MRI, f, density);

%======= principal axis of inertia ========
InertiaInfo  = calcPrincInertiaAxes(MassInfo.Imat);

% PointCloud = v_MRI;
% InertiaInfo  = calcInertiaMatrix(PointCloud);
coeff = 1;
v = transfMeshPointsRefSyst(v_MRI, MassInfo.COM, coeff*InertiaInfo.PrincAxes);
% v = v_MRI;
% BL description
Markers.LASIS = getBonyLandmark(pickPointsInOctant(v, 1),'max','z');
Markers.LICT  = getBonyLandmark(pickPointsInOctant(v, 1),'max','x');
Markers.RASIS = getBonyLandmark(pickPointsInOctant(v, 2),'max','z');
Markers.RICT  = getBonyLandmark(pickPointsInOctant(v, 2),'min','x');
Markers.LPSIS = getBonyLandmark(pickPointsInOctant(v, 5),'min','z');
Markers.RPSIS = getBonyLandmark(pickPointsInOctant(v, 6),'min','z');
Markers.RLPP  = getBonyLandmark(pickPointsInOctant(v, 7),'min','y');
Markers.RIIT  = getBonyLandmark(pickPointsInOctant(v, 7),'min','z');
Markers.LLPP  = getBonyLandmark(pickPointsInOctant(v, 8),'min','y');
Markers.LIIT  = getBonyLandmark(pickPointsInOctant(v, 8),'min','z');

% HJC estimation via regression equations
if isfield(Markers,{'RASIS', 'LASIS','LPSIS', 'RPSIS'})
    Markers = appendHJCHarrington2008(Markers);
end

% PICK RPTUB (BELOW HJC CONDITION)
v_oct2 = pickSubsetBetweenPlanes(pickPointsInOctant(v, 3), 'y', [], Markers.RHJC(2));
Markers.RPTUB = getBonyLandmark(v_oct2,'max','z');

% PICK RAIIS (ABOVE HJC CONDITION)
v_oct3 = pickSubsetBetweenPlanes(pickPointsInOctant(v, 3), 'y', Markers.RHJC(2), 0);
Markers.RAIIS = getBonyLandmark(v_oct3,'max','z');

%  PICK LPTUB (BELOW HJC CONDITION)
v_oct2 = pickSubsetBetweenPlanes(pickPointsInOctant(v, 4), 'y', [], Markers.RHJC(2));
Markers.LPTUB = getBonyLandmark(v_oct2,'max','z');

% PICK LAIIS (ABOVE HJC CONDITION)
v_oct3 = pickSubsetBetweenPlanes(pickPointsInOctant(v, 4), 'y', Markers.LHJC(2), 0);
Markers.LAIIS = getBonyLandmark(v_oct3,'max','z');

% plot
patch('Faces',f,'Vertices',v,'FaceColor',[0.8 0.8 0.8]);hold on;grid on
% plot3(v(:,1),v(:,2),v(:,3),'.','Color',color_set{1});  
plot_refsyst(gca, [0 0 0], eye(3), 100);
% plot bony landmarks with label
label_switch =0;
plotBL(Markers, label_switch);

%============== TO DO FUNCTION =============
% Ffield = fields(Markers);
% fid = fopen('C:\Users\Luca M\Desktop\Package_for_test\Pelvis_BL.txt','w+');
% fprintf(fid, '%s\n', 'Time    0'); 
% Or_COM_in_InAxes = -((coeff*InertiaInfo.PrincAxes)*(InertiaInfo.COM)')';
% for n_m = 1:size(fields(Markers))
%     BL.colheaders(n_m) = {Ffield{n_m}};
%      BL.data(n_m,:) = transfMeshPointsRefSyst(Markers.(Ffield{n_m}), Or_COM_in_InAxes, coeff*InertiaInfo.PrincAxes');
%     fprintf(fid, '%s %f %f %f\n', BL.colheaders{n_m},   BL.data(n_m,:))
% end
% fclose all

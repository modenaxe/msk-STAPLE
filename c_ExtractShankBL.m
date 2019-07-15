% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %
clear;clc; close all

[v_MRI, f, n, c, stltitle] = stlread('./Test_Geometries/Test_Shank/TibiaFibula_left.stl', 1);
PointCloud = v_MRI;
side = -1;
InertiaInfo  = calcInertiaMatrix(PointCloud);
v = transfMeshPointsRefSyst(v_MRI, InertiaInfo.COM, InertiaInfo.PrincAxes);

% makes left femur becoming right
if side == -1
    v(:,2) = -v(:,2);
end

% PLOT 
color_set = {'b','r','g','y','k','m','c','r'};
patch('Faces',f,'Vertices',v,'FaceColor',color_set{1}); hold on;grid on;axis equal
plot3(v(:,1),v(:,2),v(:,3),'.','Color',color_set{1});
plot_refsyst(gca, [0 0 0], eye(3), 100); hold on;axis equal;grid on

% Upper part of the tibia/fibula: extracting most medial points
v_cran = pickSubsetBetweenPlanes(v, 'x', 0, []);
Markers.RFIB = getBonyLandmark(v_cran,'min','y');
Markers.RFME = getBonyLandmark(v_cran,'max','y');

% caudal part of the tibia: extracting malleoli
v_caud = pickSubsetBetweenPlanes(v, 'x', [], 0);
Markers.MMAL = getBonyLandmark(v_caud,'max','y');
Markers.LMAL = getBonyLandmark(v_caud,'min','y');

% plot bony landmarks with label
label_switch = 1;
plotBL(Markers, label_switch);

patch('Faces',f,'Vertices',v,'FaceColor',[0.4 0.4 0.4]); 
plot_refsyst(gca, [0 0 0], eye(3), 100); hold on;axis equal;grid on

%============== TO DO FUNCTION =============
Ffield = fields(Markers);
for n_m = 1:size(fields(Markers))
    Markers.(Ffield{n_m})(2) = -Markers.(Ffield{n_m})(2);
end

fid = fopen('C:\Users\Luca M\Desktop\Package_for_test\Shank_BL.txt','w+');
fprintf(fid, '%s\n', 'Time    0'); 
Or_COM_in_InAxes = -((InertiaInfo.PrincAxes)*(InertiaInfo.COM)')';
for n_m = 1:size(fields(Markers))
    BL.colheaders(n_m) = {Ffield{n_m}};
     BL.data(n_m,:) = transfMeshPointsRefSyst(Markers.(Ffield{n_m}), Or_COM_in_InAxes, InertiaInfo.PrincAxes');
    fprintf(fid, '%s %f %f %f\n', BL.colheaders{n_m},   BL.data(n_m,:))
end
fclose all
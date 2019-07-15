% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %
clear;clc; close all

% [v_MRI, f, n, c, stltitle] = stlread('./Test_Femur/Femur_l_Poisson2.stl', 1);
% [v_MRI, f, n, c, stltitle] = stlread('./Test_Femur/R_Femur_6m.stl', 1);
% [v_MRI, f, n, c, stltitle] = stlread('./Test_Geometries/Test_Femur/Femur_l_Poisson2.stl', 1);
[v_MRI, f, n, c, stltitle] = stlread('./Test_Geometries/R_Femur.stl', 1);
density = 1;



% ====== calculating inertia tensor as point cloud =======
MassInfo = calcMassInfo_Mirtich1996(v_MRI, f, density, 'Femur_l_Poisson2.stl');

%======= principal axis of inertia ========
InertiaInfo  = calcPrincInertiaAxes(MassInfo.Imat);

PointCloud = v_MRI;
side = 1;
% InertiaInfo  = calcInertiaMatrix(PointCloud);
v = transfMeshPointsRefSyst(v_MRI, MassInfo.COM, InertiaInfo.PrincAxes);

% makes left femur becoming right
if side == -1
    v(:,2) = -v(:,2);
end
color_set = {'b','r','g','y','k','m','c','r'};

for n_oct = [1:8]
    
    v_oct = pickPointsInOctant(v, n_oct);
    plot3(v_oct(:,1),v_oct(:,2),v_oct(:,3),'.','Color',color_set{n_oct}); 
    hold on;grid on
    
    % GLOBAL REF
%     plot_refsyst(gca, [0 0 0], eye(3), 100);
    
    switch n_oct
        case 1 %======== OCTANT 1 =========
            Markers.RTROC = getBonyLandmark(v_oct,'max','y');
        
        case 2
            Markers.RFLE = getBonyLandmark(v_oct,'max','y');
            v_oct2 = pickSubsetBetweenPlanes(v_oct, 'x', [], Markers.RFLE(1));
            Markers.RLFRONT = getBonyLandmark(v_oct2,'max','z');
            Markers.RLBOTTOM1 = getBonyLandmark(v_oct2,'min','x');
        case 3
            Markers.RFME1 = getBonyLandmark(v_oct,'min','y');
           
            v_oct3 = pickSubsetBetweenPlanes(v_oct, 'x', [], Markers.RFME1(1));
            Markers.RLFRONT = getBonyLandmark(v_oct3,'max','z');
            Markers.RMBOTTOM = getBonyLandmark(v_oct3,'min','x');
        
        case 4
            v_oct3 = pickSubsetBetweenPlanes(v_oct, 'x', [], 0.85*Markers.RTROC(1));
            Markers.RSMALLTROC = getBonyLandmark(v_oct3,'min','y');
        
        case 5
            Markers.RFTA = getBonyLandmark(v_oct,'max','y');
            Markers.RFTP = getBonyLandmark(v_oct,'min','z');
        case 6
            Markers.RFME2 = getBonyLandmark(v_oct,'max','y');
            Markers.RLBOTTOM2 = getBonyLandmark(v_oct,'min','x');
            Markers.RLBACK = getBonyLandmark(v_oct,'min','z');
        
        case 7
            Markers.RMBACK = getBonyLandmark(v_oct,'min','z');
            Markers.RLBOTTOM2 = getBonyLandmark(v_oct,'min','x');
            Markers.RFME2 = getBonyLandmark(v_oct,'min','y');
            
        case 8
           v_oct3 = pickSubsetBetweenPlanes(v_oct, 'x', [], 0.85*Markers.RTROC(1));
            Markers.RSMALLTROC2 = getBonyLandmark(v_oct3,'min','y');
        otherwise
    end  
    
    % plot bony landmarks with label
    label_switch = 1;
    plotBL(Markers, label_switch);
    
    % clear memory
    clear v_oct v_oct2 v_oct3
end

patch('Faces',f,'Vertices',v,'FaceColor',[0.4 0.4 0.4]); 
plot_refsyst(gca, [0 0 0], eye(3), 100); hold on;axis equal;grid on


%============== TO DO FUNCTION =============
Ffield = fields(Markers);
for n_m = 1:size(fields(Markers))
    Markers.(Ffield{n_m})(2) = -Markers.(Ffield{n_m})(2);
end

fid = fopen('C:\Users\Luca M\Desktop\Package_for_test\Femur2_BL.txt','w+');
fprintf(fid, '%s\n', 'Time    0'); 
Or_COM_in_InAxes = -((InertiaInfo.PrincAxes)*(InertiaInfo.COM)')';
for n_m = 1:size(fields(Markers))
    BL.colheaders(n_m) = {Ffield{n_m}};
     BL.data(n_m,:) = transfMeshPointsRefSyst(Markers.(Ffield{n_m}), Or_COM_in_InAxes, InertiaInfo.PrincAxes');
    fprintf(fid, '%s %f %f %f\n', BL.colheaders{n_m},   BL.data(n_m,:))
end
fclose all
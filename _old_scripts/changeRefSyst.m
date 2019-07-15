clear all;clc
close all

[v, f, n, c, stltitle] = stlread('./Test_Femur/Femur_l_Poisson2.stl', 1);
[v, f, n, c, stltitle] = stlread('./Test_Shank/TibiaFibula_left.stl', 1);

% plot3(v(:,1),v(:,2),v(:,3),'.'); hold on;axis equal;grid on

InertiaInfo  = calcInertiaMatrix(v);
orig = InertiaInfo.COM;
R = InertiaInfo.PrincAxes';

% transforming points
v_trasf = transfMeshPointsRefSyst(v, orig, R);

% identification long axis
[~,long_axis_ind] = min(diag(InertiaInfo.PrincMom));
g = 50;
v_trasf = v_trasf(v_trasf(:,long_axis_ind)>0,:);
    v_trasf = v_trasf(v_trasf(:,2)>0,:);
        v_trasf = v_trasf(v_trasf(:,3)>0,:);
% plot3(v_trasf(1:g:end,1),v_trasf(1:g:end,2),v_trasf(1:g:end,3),'r.'); hold on; axis equal, grid on
plot3(v_trasf(1:g:end,1),v_trasf(1:g:end,2),v_trasf(1:g:end,3),'r.'); hold on; axis equal, grid on
[~, topPoint_ind] = max(v_trasf(:,long_axis_ind));
[~, lowPoint_ind] = min(v_trasf(:,long_axis_ind));
plot3(v_trasf(topPoint_ind,1),v_trasf(topPoint_ind,2),v_trasf(topPoint_ind,3),'ks')



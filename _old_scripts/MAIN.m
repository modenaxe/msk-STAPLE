clear;clc
close all

%[v, f, n, c, stltitle] = stlread('./Test_Femur/Femur_l_Poisson2.stl', 1);
[v, f, n, c, stltitle] = stlread('./Test_Pelvis/Pelvis_NO_SACRUM_single_file.stl', 1);
% [v, f, n, c, stltitle] = stlread('./Test_Shank/TibiaFibula_left.stl', 1);

% calculate inertial properties
PointCloud = v;
InertiaInfo  = calcInertiaMatrix(PointCloud);

% plot geometry 
% plot3(v(:,1),v(:,2),v(:,3),'.'); hold on;axis equal;grid on
% patch('Faces',f,'Vertices',v); 

% plot axes
% scale = 300;
% plot_refsyst(gca, InertiaInfo.COM, InertiaInfo.PrincAxes, scale);

% change reference system
v_trasf = transfMeshPointsRefSyst(v, InertiaInfo.COM, InertiaInfo.PrincAxes);
% plot3(v_trasf(:,1),v_trasf(:,2),v_trasf(:,3),'.'); hold on;axis equal;grid on
% plot axes
scale = 300;
scale_BL = 50;
plot_refsyst(gca, [0 0 0], eye(3), scale);

% pelvis
% close all
% FIRST OCTANT & SECOND
v_quad1 = v_trasf((v_trasf(:,1)>0 &  v_trasf(:,2)>0), :);
[~, ind_LASIS] = max(v_quad1(:,3));
[~, ind_LPSIS] = min(v_quad1(:,3));
LASIS = v_quad1(ind_LASIS,:);
LPSIS = v_quad1(ind_LPSIS,:);

% plot
% highlight the region of interest in red
plot3(v_quad1(:,1),v_quad1(:,2),v_quad1(:,3),'r.');hold on;
%plot landmarks
plot_refsyst(gca, LASIS, eye(3), scale_BL);
plot_refsyst(gca, LPSIS, eye(3), scale_BL);axis equal;grid on

% 4 OCTANT
v_quad2 = v_trasf((v_trasf(:,1)<0 &  v_trasf(:,2)>0), :);
[~, ind_RASIS] = max(v_quad2(:,3));
[~, ind_RPSIS] = min(v_quad2(:,3));
RASIS = v_quad2(ind_RASIS,:);
RPSIS = v_quad2(ind_RPSIS,:);

plot3(v_quad2(:,1),v_quad2(:,2),v_quad2(:,3),'g.');hold on;
plot_refsyst(gca, RASIS, eye(3), scale_BL);
plot_refsyst(gca, RPSIS, eye(3), scale_BL);axis equal;grid on


% 5 OCTANT
v_quad3 = v_trasf((v_trasf(:,1)<0 & v_trasf(:,2)<0 & v_trasf(:,3)>0),:);
plot3(v_quad3(:,1),v_quad3(:,2),v_quad3(:,3),'k.');hold on;
[~, ind_RPTUB] = max(v_quad3(:,3));
RPTUB = v_quad3(ind_RPTUB,:);
plot_refsyst(gca, RPTUB, eye(3), scale_BL);

v_quad4 = v_trasf((v_trasf(:,1)>0 & v_trasf(:,2)<0),:);
[~, ind_LPTUB] = max(v_quad4(:,3));
LPTUB = v_quad4(ind_LPTUB,:);
plot3(v_quad4(:,1),v_quad4(:,2),v_quad4(:,3),'y.');hold on;
plot_refsyst(gca, LPTUB, eye(3), scale_BL);axis equal;grid on


% Harrington equations
PW = norm(LASIS-RASIS);
% Calculating the midpoint of PSIS markers
Sacrum = (RPSIS+LPSIS)/2.0;
% Calculating the area of the triangle between the two ASIS and the Sacrum
% marker (Heron's formula).
% semiperimeter
c = norm(RASIS-Sacrum);
b = norm(LASIS-Sacrum);
a = PW;
s= (a+b+c)/2.0;
%formula
Area = (s.*(s-a).*(s-b).*(s-c)).^0.5;
% Pelvic depth is the height of the triangle wrt the segment connecting the
% ASIS
%vector
PD  = 2*Area./a;

x = -0.24*PD-9.9; 
y = -0.30*PW-10.9;
z = 0.33*PW+7.3;

% pelvis ref syst
MID_ASIS = (RASIS+LASIS)/2;
MID_PSIS = (RPSIS+LPSIS)/2;
Z_axis = (RASIS-LASIS)/norm((RASIS-LASIS));
X_axis_temp = MID_ASIS-MID_PSIS;
Y_axis = cross(Z_axis, X_axis_temp)/norm(cross(Z_axis, X_axis_temp));
X_axis = cross(Y_axis, Z_axis);
% from ISB to inertial
Rmat = [X_axis; Y_axis; Z_axis];
Or = (RASIS+LASIS)'/2;
plot_refsyst(gca, Or, Rmat, scale_BL);

% RIGHT

sideCoeff  = 1;
HJC_Regr = [x;y;sideCoeff*z];
HJC_inertia = Or+Rmat*HJC_Regr;
% plot_refsyst(gca, HJC_inertia, eye(3), scale_BL);axis equal;grid on



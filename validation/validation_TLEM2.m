% knee fitting
KJC = [-72.1561, -117.1155, -685.4722];
P_Cyl = [-26.8376, -137.8607, -689.4559];
manual_axis = (P_Cyl - KJC)/norm(P_Cyl - KJC);
% copied 
auto_axis = [-0.9068	0.4131	0.0835];
% angle difference
acosd(manual_axis * auto_axis')

% ankle fitting
tal_calc_centre = [-73.438289     -96.894524     -1062.1392];
tal_nav_centre = [-92.723211     -128.18213     -1062.0908];
manual_subtalar_axis = (tal_nav_centre-tal_calc_centre)/norm(tal_nav_centre-tal_calc_centre);
auto_subtalar_axis = [-0.5548	-0.8301	   -0.0563];
% angle difference
acosd(manual_subtalar_axis * auto_subtalar_axis')

% ankle
ankle_JC =[ -85.491744     -116.04859     -1055.2037];
P_cyl_axis = [-60.100641     -158.87726      -1059.786];
manual_ankle_axis = (P_cyl_axis-ankle_JC)/norm(P_cyl_axis-ankle_JC);
auto_ankle_axis = [0.5195	-0.8506	-0.0805];
acosd(manual_ankle_axis * auto_ankle_axis')
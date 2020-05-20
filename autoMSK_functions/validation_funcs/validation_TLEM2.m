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


%------------
% LHDL
%------------
% ground-pelvis
LHDL.ground_pelvis.parent = eye(4);
LHDL.ground_pelvis.child = [ 0.00586843 -0.00671522 -0.99996 237.879 
                            -0.987773 -0.155824 -0.00475047 180.732 
                            -0.155786 0.987762 -0.00754756 -360.65 
                            0 0 0 1 ];

% hip joint
LHDL.hip_r.parent = [   0.00586196 -0.00671624 -0.99996 143.646 
                        -0.987773 -0.155824 -0.00474392 243.261 
                        -0.155786 0.987762 -0.00754756 -432.356 
                        0 0 0 1 ];

LHDL.hip_r.child = [-0.01564 0.053077 -0.998468 143.646 
                    -0.992453 -0.122288 0.00904522 243.261 
                    -0.12162 0.991074 0.054589 -432.356 
                    0 0 0 1 ];

% knee joint
LHDL.knee_r.parent =[   -0.01564 0.0800826 -0.996666 122.35 
                        -0.992453 -0.122488 0.005732 292.326 
                        -0.12162 0.989234 0.081394 -830.007 
                        0 0 0 1 ];

LHDL.knee_r.child = [   -0.0079477 0.0812076 -0.996666 122.35 
                        -0.999606 -0.0274812 0.005732 292.326 
                        -0.0269241 0.996318 0.081394 -830.007 
                        0 0 0 1 ];

% ankle joint
LHDL.ankle_r.parent = [ -0.637314 -0.0901888 -0.765308 122.99 
                        -0.770298 0.0465357 0.635984 303.239 
                        -0.0217445 0.994837 -0.0991301 -1235.35 
                        0 0 0 1 ];      

LHDL.ankle_r.child = [  -0.493043 -0.413777 -0.765308 122.99 
                        -0.678232 -0.368137 0.635984 303.239 
                        -0.544894 0.832625 -0.0991301 -1235.35 
                        0 0 0 1 ];


% subtalar
LHDL.subtalar.parent = [0.943713 0.0834633 -0.320061 132.425 
                        -0.330754 0.230164 -0.915219 324.57 
                        -0.00272076 0.969566 0.244814 -1254.95 
                        0 0 0 1 ];
LHDL.subtalar.child = LHDL.subtalar.parent;

% foot sole (origin is heel)
LHDL_foot_sole = [  -0.296368 -0.294874 -0.908414 153.112 
                    -0.810301 -0.425837 0.402587 346.122 
                    -0.505548 0.855402 -0.112733 -1242.65
                    0 0 0 1 ];

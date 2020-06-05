clear all;

% import mesh
[v, f, n, c, stltitle] = stlread('R_Femur_6m.stl', 1);

% ====== calculating inertia tensor as point cloud =======
MassInfo = calcMassInfo_Mirtich1996(v, f, 1);

%======= principal axis of inertia ========
InertiaInfo  = calcPrincInertiaAxes(MassInfo.Imat);

% InertiaInfo.PrincAxes
% InertiaInfo.PrincMom

% data from meshlab
Mesh.Volume = 432153.187500;
Mesh.Surface = 89967.570313;
% Thin shell barycenter -92.444260 32.099567 -224.402176
Mesh.COM = [-91.634438 33.403984 -238.264206];
I.Mat = [ 10414691328.000000 -39343212.000000 413215520.000000 ;
 -39343212.000000 10392838144.000000 845144704.000000 ;
 413215520.000000 845144704.000000 236261744.000000 ];
I.princAxes =  [ 0.040400 0.082315 -0.995787 ;
                 0.986421 0.155490 0.052874 ;
                 -0.159187 0.984402 0.074916 ];
I.D = [149634160.000000 10430637056.000000 10463520768.000000 ];


(MassInfo.COM - Mesh.COM)/Mesh.COM*100
(MassInfo.mass-Mesh.Volume)/Mesh.Volume*100
(I.Mat-MassInfo.Imat)/
(InertiaInfo.PrincMom - I.D)

%%-------------------------------------------------------------------------  
% GOAL :
% Read the results and compute the minimal bounding sphere radii
% of the origins of each algorithm, for the patella,femur and tibia.

% Output ? 3 tables :
% - mBSF.txt
% - mBST.txt
% - mBSP.txt
% Tables will be subsequently exploited in R
%% ------------------------------------------------------------------------
clearvars
addpath(strcat(pwd,'\Quat'));

qI = qGetQ(eye(3));
load('Results.mat')
N = length(Results);


%% Compute mean coordinate system for every patient
Rmean =  struct();

% The Miranda et Al. 2010 tibial algorithm is reoriented to be consistent with
% others tibia algoithms
for i = 1 : N
    for k = 1 : 3
        Results(i, k).Tib.Miranda.Zend = sign(Results(i, k).Tib.Miranda.Zend(3))*Results(i, k).Tib.Miranda.Zend;
        Results(i, k).Tib.Miranda.Yend = sign(Results(i, k).Tib.Miranda.Yend(1))*Results(i, k).Tib.Miranda.Yend;
        Results(i, k).Tib.Miranda.Xend = cross(Results(i, k).Tib.Miranda.Yend,Results(i, k).Tib.Miranda.Zend);
    end
end


for i = 1 : N
    %% Femur, 5 compared algorithms
    Q1 = zeros(4,3); Q2 = zeros(4,3); Q3 = zeros(4,3); Q4 = zeros(4,3); Q5 = zeros(4,3);
    for k = 1 : 3
        Rcyl =  [Results(i, k).Fem.Xend , Results(i, k).Fem.Yend , Results(i, k).Fem.Zend];
        Rsph =  [Results(i, k).Fem.Xend_sph , Results(i, k).Fem.Yend_sph , Results(i, k).Fem.Zend_sph];
        Relpsd =  [Results(i, k).Fem.Xend_elpsd , Results(i, k).Fem.Yend_elpsd , Results(i, k).Fem.Zend_elpsd];
        RKai = [Results(i, k).Fem.Xend_Kai , Results(i, k).Fem.Yend_Kai , Results(i, k).Fem.Zend_Kai];
        RMir = [Results(i, k).Fem.Xend_Miranda , Results(i, k).Fem.Yend_Miranda , Results(i, k).Fem.Zend_Miranda];
                
        Q1(:,k) = qGetQ(Rcyl);
        Q2(:,k) = qGetQ(Rsph);
        Q3(:,k) = qGetQ(Relpsd);
        Q4(:,k) = qGetQ(RKai);
        Q5(:,k) = qGetQ(RMir);
        
    end
    % Get the mean quaternions of each algorithm for the current subject
    [V1,~] = eig(Q1*Q1'); [V2,~] = eig(Q2*Q2'); [V3,~] = eig(Q3*Q3'); [V4,~] = eig(Q4*Q4'); [V5,~] = eig(Q5*Q5');
    Rmean(i).Q_Fem1 = V1(:,end);Rmean(i).Q_Fem2 = V2(:,end);Rmean(i).Q_Fem3 = V3(:,end);Rmean(i).Q_Fem4 = V4(:,end);Rmean(i).Q_Fem5 = V5(:,end);
    
    % Ensure direction of the mean orientation matrices are consistent
    if sum(Rmean(i).Q_Fem1'*Q1) < 0
        Rmean(i).Q_Fem1 = -Rmean(i).Q_Fem1;
    end
    if sum(Rmean(i).Q_Fem2'*Q2) < 0
        Rmean(i).Q_Fem2 = -Rmean(i).Q_Fem2;
    end
    if sum(Rmean(i).Q_Fem3'*Q3) < 0
        Rmean(i).Q_Fem3 = -Rmean(i).Q_Fem3;
    end
    if sum(Rmean(i).Q_Fem4'*Q4) < 0
        Rmean(i).Q_Fem4 = -Rmean(i).Q_Fem4;
    end
    if sum(Rmean(i).Q_Fem5'*Q5) < 0
        Rmean(i).Q_Fem5 = -Rmean(i).Q_Fem5;
    end
    
    clearvars Q1 Q2 Q3 Q4 Q5 Rcyl Rsph Relpsd RKai RMir
    
    %% Tibia
    Q1 = zeros(4,3); Q2 = zeros(4,3); Q3 = zeros(4,3); Q4 = zeros(4,3); Q5 = zeros(4,3);
    for k = 1 : 3
        R1 =  [Results(i, k).Tib.tech1.Xend Results(i, k).Tib.tech1.Yend Results(i, k).Tib.tech1.Zend];
        R2 =  [Results(i, k).Tib.tech2.Xend Results(i, k).Tib.tech2.Yend Results(i, k).Tib.tech2.Zend];
        R3 =  [Results(i, k).Tib.tech3.Xend Results(i, k).Tib.tech3.Yend Results(i, k).Tib.tech3.Zend];
        RKai = [Results(i, k).Tib.Kai.Xend Results(i, k).Tib.Kai.Yend Results(i, k).Tib.Kai.Zend];
        RMir = [Results(i, k).Tib.Miranda.Xend Results(i, k).Tib.Miranda.Yend Results(i, k).Tib.Miranda.Zend];
        
        Q1(:,k) = qGetQ(R1);
        Q2(:,k) = qGetQ(R2);
        Q3(:,k) = qGetQ(R3);
        Q4(:,k) = qGetQ(RKai);
        Q5(:,k) = qGetQ(RMir);
        
    end
    % Get the mean quaternions of each algorithm for the current subject
    [V1,~] = eig(Q1*Q1'); [V2,~] = eig(Q2*Q2'); [V3,~] = eig(Q3*Q3'); [V4,~] = eig(Q4*Q4'); [V5,~] = eig(Q5*Q5');
    Rmean(i).Q_Tib1 = V1(:,end);Rmean(i).Q_Tib2 = V2(:,end);Rmean(i).Q_Tib3 = V3(:,end);Rmean(i).Q_Tib4 = V4(:,end);Rmean(i).Q_Tib5 = V5(:,end);
    
    % Ensure direction of the mean orientation matrices are consistent
    if sum(Rmean(i).Q_Tib1'*Q1) < 0
        Rmean(i).Q_Tib1 = -Rmean(i).Q_Tib1;
    end
    if sum(Rmean(i).Q_Tib2'*Q2) < 0
        Rmean(i).Q_Tib2 = -Rmean(i).Q_Tib2;
    end
    if sum(Rmean(i).Q_Tib3'*Q3) < 0
        Rmean(i).Q_Tib3 = -Rmean(i).Q_Tib3;
    end
    if sum(Rmean(i).Q_Tib4'*Q4) < 0
        Rmean(i).Q_Tib4 = -Rmean(i).Q_Tib4;
    end
    if sum(Rmean(i).Q_Tib5'*Q5) < 0
        Rmean(i).Q_Tib5 = -Rmean(i).Q_Tib5;
    end
    
    clearvars Q1 Q2 Q3 Q4 Q5 R1 R2 R3 RKai RMir
    
    %% Patella
    Q0 = zeros(4,3); Q1 = zeros(4,3); Q3 = zeros(4,3); Q4 = zeros(4,3); 
    for k = 1 : 3
        R0 =  [Results(i, k).Pat.X0 , Results(i, k).Pat.Y0 , Results(i, k).Pat.Z0];
        R1 =  [Results(i, k).Pat.X , Results(i, k).Pat.Y , Results(i, k).Pat.Z];
        R3 =  [Results(i, k).Pat.X3 , Results(i, k).Pat.Y3 , Results(i, k).Pat.Z3];
        R4 =  [-Results(i, k).Pat.X4 , -Results(i, k).Pat.Y4 , Results(i, k).Pat.Z4];
        
        Q0(:,k) = qGetQ(R0);
        Q1(:,k) = qGetQ(R1);
        Q3(:,k) = qGetQ(R3);
        Q4(:,k) = qGetQ(R4);
    end
    % Get the mean quaternions of each algorithm for the current subject
    [V0,~] = eig(Q0*Q0');          [V1,~] = eig(Q1*Q1'); 
    [V3,~] = eig(Q3*Q3');          [V4,~] = eig(Q4*Q4');
    Rmean(i).Q_Pat0 = V0(:,end);           Rmean(i).Q_Pat1 = V1(:,end);
    Rmean(i).Q_Pat3 = V3(:,end);           Rmean(i).Q_Pat4 = V4(:,end);
    
    % Ensure direction of the mean orientation matrices are consistent
    if sum(Rmean(i).Q_Pat1'*Q1) < 0
        Rmean(i).Q_Pat1 = -Rmean(i).Q_Pat1;
    end
    if sum(Rmean(i).Q_Pat4'*Q4) < 0
        Rmean(i).Q_Pat4 = -Rmean(i).Q_Pat4;
    end
    if sum(Rmean(i).Q_Pat3'*Q3) < 0
        Rmean(i).Q_Pat3 = -Rmean(i).Q_Pat3;
    end
    if sum(Rmean(i).Q_Pat0'*Q0) < 0
        Rmean(i).Q_Pat0 = -Rmean(i).Q_Pat0;
    end
    
    clearvars Q1 Q0 Q3 Q4 R1 R4 R3 R0
end


for i = 1 : length(Results)
    for k = 1 : 3
        
        %% Femur
        R1 =  [Results(i, k).Fem.Xend , Results(i, k).Fem.Yend , Results(i, k).Fem.Zend];
        R2 =  [Results(i, k).Fem.Xend_sph , Results(i, k).Fem.Yend_sph , Results(i, k).Fem.Zend_sph];
        R3 =  [Results(i, k).Fem.Xend_elpsd , Results(i, k).Fem.Yend_elpsd , Results(i, k).Fem.Zend_elpsd];
        RKai = [Results(i, k).Fem.Xend_Kai , Results(i, k).Fem.Yend_Kai , Results(i, k).Fem.Zend_Kai];
        RMir = [Results(i, k).Fem.Xend_Miranda , Results(i, k).Fem.Yend_Miranda , Results(i, k).Fem.Zend_Miranda];
         
        % Compute the Global Variability Angle (GVA) for each algorithms
        % for each subject :
        qFem1(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Fem1,qGetQ(R1))));
        qFem2(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Fem2,qGetQ(R2))));
        qFem3(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Fem3,qGetQ(R3))));
        qFemKai(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Fem4,qGetQ(RKai))));
        qFemMir(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Fem5,qGetQ(RMir))));
        
        clearvars R1 R2 R3 RKai RMir
        
        
        %% Tibia
        R1 =  [Results(i, k).Tib.tech1.Xend Results(i, k).Tib.tech1.Yend Results(i, k).Tib.tech1.Zend];
        R2 =  [Results(i, k).Tib.tech2.Xend Results(i, k).Tib.tech2.Yend Results(i, k).Tib.tech2.Zend];
        R3 =  [Results(i, k).Tib.tech3.Xend Results(i, k).Tib.tech3.Yend Results(i, k).Tib.tech3.Zend];
        RKai = [Results(i, k).Tib.Kai.Xend Results(i, k).Tib.Kai.Yend Results(i, k).Tib.Kai.Zend];
        RMir = [Results(i, k).Tib.Miranda.Xend Results(i, k).Tib.Miranda.Yend Results(i, k).Tib.Miranda.Zend];
        
        % Compute the Global Variability Angle (GVA) for each algorithms
        % for each subject :
        qTib1(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Tib1,qGetQ(R1))));
        qTib2(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Tib2,qGetQ(R2))));
        qTib3(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Tib3,qGetQ(R3))));
        qTibKai(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Tib4,qGetQ(RKai))));
        qTibMir(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Tib5,qGetQ(RMir))));
        
        clearvars R1 R2 R3 RKai RMir
        
        %% Patella
        R0 =  [Results(i, k).Pat.X0 , Results(i, k).Pat.Y0 , Results(i, k).Pat.Z0];
        R =  [Results(i, k).Pat.X , Results(i, k).Pat.Y , Results(i, k).Pat.Z];
        R3 =  [Results(i, k).Pat.X3 , Results(i, k).Pat.Y3 , Results(i, k).Pat.Z3];
        R4 =  [-Results(i, k).Pat.X4 , -Results(i, k).Pat.Y4 , Results(i, k).Pat.Z4];
        
        % Compute the Global Variability Angle (GVA) for each algorithms
        % for each subject :
        qPatRbw(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Pat0,qGetQ(R0))));
        qPat(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Pat1,qGetQ(R))));
        qPat3(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Pat3,qGetQ(R3))));
        qPat4(i,k) = 2*rad2deg(acos(dot(Rmean(i).Q_Pat4,qGetQ(R4))));
        
        clearvars R1 R4 R3 R0
        
    end
end

% Ensure that angles are centered over 0;
qFem1 = min(360-qFem1,qFem1); qFem2 = min(360-qFem2,qFem2); qFem3 = min(360-qFem3,qFem3);
qFemKai = min(360-qFemKai,qFemKai); qFemMir = min(360-qFemMir,qFemMir);

qTib1 = min(360-qTib1,qTib1); qTib2 = min(360-qTib2,qTib2); qTib3 = min(360-qTib3,qTib3);
qTibKai = min(360-qTibKai,qTibKai); qTibMir = min(360-qTibMir,qTibMir);

qPatRbw = min(360-qPatRbw,qPatRbw); qPat = min(360-qPat,qPat);
qPat3 = min(360-qPat3,qPat3); qPat4 = min(360-qPat4,qPat4);


%% Write results in files

%% Femur

Methods = [repmat({'Cylinder'}, [N 1]); repmat({'Spheres'}, [N 1]); repmat({'Elipsoids'}, [N 1]); repmat({'Kai2014'}, [N 1]) ;repmat({'Miranda2010'}, [N 1])];
Rb = [ mean(qFem1,2) ; mean(qFem2,2) ;mean(qFem3,2); mean(qFemKai,2); mean(qFemMir, 2)] ;

TF = table(Methods,Rb);

writetable(TF);

Methods = [repmat({'CondylesASB'}, [N 1]); repmat({'EllipseAS'}, [N 1]);...
    repmat({'SliceIA'}, [N 1]) ; repmat({'Kai2014'}, [N 1]); repmat({'Miranda2010'}, [N 1])];

Rb = [ mean(qTib1,2) ; mean(qTib2,2) ;mean(qTib3,2); mean(qTibKai,2); mean(qTibMir,2)] ;

TT = table(Methods,Rb);
writetable(TT);

%% Patella

Methods = [repmat({'Rainbow2013'}, [N 1]); repmat({'Vol'}, [N 1]); repmat({'Ridge'}, [N 1]); repmat({'ArtSurf'}, [N 1])];
Rb = [ mean(qPatRbw,2); mean(qPat,2) ; mean(qPat3,2) ;mean(qPat4,2) ] ;

TP = table(Methods,Rb);


writetable(TP);





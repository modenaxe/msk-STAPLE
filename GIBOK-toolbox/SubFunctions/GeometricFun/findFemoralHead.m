function CSs = findFemoralHead(ProxFem, CSs)
    
% from CSs structures we need:
% - CSs.CenterVol
% - CSs.Z0

% populates
% CSs.Y0
% CSs.CenterFH0
% CSs.CenterFH
% CSs.RadiusFH

% Find the most proximal on femur top head
[~ , I_Top_FH] = max( ProxFem.incenter*CSs.Z0 ); 
% most prox point
I_Top_FH = [I_Top_FH ProxFem.neighbors(I_Top_FH)]; 
% triang around it
Face_Top_FH = TriReduceMesh(ProxFem,I_Top_FH); 
% create a triang with them
[ Patch_Top_FH ] = TriDilateMesh( ProxFem ,Face_Top_FH , 40 );

% Get an initial ML Axis Y0 (pointing posteriorly)
% NB: from centerVol, OT points upwards to ~HJC, that is more medial than
% Z0. The new Y0 is backwards pointing.
OT = mean(Patch_Top_FH.Points)' - CSs.CenterVol;
CSs.Y0 = normalizeV(  cross(cross(CSs.Z0,OT),CSs.Z0)  );

% Find a the most medial (MM) point on the femoral head (FH)
[~ , I_MM_FH] = max( ProxFem.incenter*CSs.Y0 );
I_MM_FH = [I_MM_FH ProxFem.neighbors(I_MM_FH)];
Face_MM_FH = TriReduceMesh(ProxFem,I_MM_FH);
[ Patch_MM_FH ] = TriDilateMesh( ProxFem ,Face_MM_FH , 40 );

FemHead0 = TriUnite(Patch_MM_FH,Patch_Top_FH);

% Initial sphere fit
[~,Radius] = sphereFit(FemHead0.Points);
[ FemHead1] = TriDilateMesh( ProxFem ,FemHead0 , round(1.5*Radius) );
[CenterFH,Radius] = sphereFit(FemHead1.Points);

CenterFH0 = CenterFH;

% Theorial Normal of the face
CPts_PF_2D  = bsxfun(@minus,FemHead1.incenter,CenterFH);
normal_CPts_PF_2D = CPts_PF_2D./repmat(sqrt(sum(CPts_PF_2D.^2,2)),1,3);

% Keep points that display a less than 10° difference between the actual
% normals and the sphere simulated normals &
Cond1 = sum((normal_CPts_PF_2D.*FemHead1.faceNormal),2)>0.975 ;

% Delete points far from sphere surface outside [90%*Radius 110%*Radius]
Cond2 = abs(sqrt(sum(bsxfun(@minus,FemHead1.incenter,CenterFH).^2,2))...
    -1*Radius)<0.1*Radius ;

% search within conditions Cond1 and Cond2
Face_ID_PF_2D_onSphere = find(Cond1 & Cond2);

% get the mesh and points on the femoral head
FemHead = TriReduceMesh(FemHead1,Face_ID_PF_2D_onSphere);
FemHead = TriOpenMesh(ProxFem ,FemHead,3);

% Fit the last Sphere
[CenterFH,Radius] = sphereFit(FemHead.Points);

% Write to the results struct
CSs.CenterFH0 = CenterFH0;
CSs.CenterFH  = CenterFH;
CSs.RadiusFH  =  Radius;

end
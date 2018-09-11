% EXAMPLE %
addpath(genpath(strcat(pwd,'\SubFunctions')));

[FemDist,FemProx] = ReadMesh(strcat(pwd,'\S1_R_FEM.msh'),...
    strcat(pwd,'\S1_R_HIP.msh'));

[ Results ] = RFemurFun( FemDist , FemProx);
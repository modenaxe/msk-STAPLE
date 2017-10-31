close all
clearvars

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the anatomical coordinate system of all the subject for all the bones and operators
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Subject_IDs = ['S1_L';
    'S2_R';
    'S3_L';
    'S4_R';
    'S5_R';
    'S6_R';
    'S7_L';
    'S8_L';
    'S9_R';
    'S10_R';
    'S11_L';
    'S12_R';
    'S13_L';
    'S14_R';
    'S15_L';
    'S16_R';
    'S17_R';
    'S18_R';
    'S19_L';
    'S20_L';
    'S21_R';
    'S22_L';
    'S23_R';
    'S24_L'];

Subject_IDs = cellstr(Subject_IDs);

Operator_IDs = ['_OP1_';'_OP2_';'_OP3_'];
Operator_IDs = cellstr(Operator_IDs);

Results = struct();
% ResultsRATM = struct();

load('Results.mat')

for subjId = 1 : length(Subject_IDs)
    close all
    for OprtrId  = 1 : length(Operator_IDs)
        tic
        PatResults = RPatellaFun(Subject_IDs{subjId },Operator_IDs{OprtrId},0);
        TibResults = RTibiaFun(Subject_IDs{subjId },Operator_IDs{OprtrId},0);
        Results(subjId,OprtrId).Tib = TibResults;
        TibResults = TibiaMirandaFun(Subject_IDs{subjId },Operator_IDs{OprtrId},0,Results(subjId,OprtrId).Tib);
        Results(subjId,OprtrId).Tib = TibResults;
        FemResults = RFemurFun(Subject_IDs{subjId },Operator_IDs{OprtrId},0);
        FemResults = FemurKaiFun(Subject_IDs{subjId},Operator_IDs{OprtrId},0,FemResults);
        Results(subjId,OprtrId).Fem = FemResults;
        FemResults = FemurMirandaFun(Subject_IDs{subjId},Operator_IDs{OprtrId},0,Results(subjId,OprtrId).Fem);
        Results(subjId,OprtrId).Fem = FemResults;
        
        Results(subjId,OprtrId).Pat = PatResults;
        Results(subjId,OprtrId).Tib = TibResults;
        Results(subjId,OprtrId).Name = names{subjId};
        %         ResultsRATM(nameIndx,OprtrIndx).Pat = PatResultsRATM;
        %         ResultsRATM(nameIndx,OprtrIndx).Tib = TibResultsRATM;
        %         ResultsRATM(nameIndx,OprtrIndx).Fem = FemResultsRATM;
        toc
    end
    for ii = 1:2
        sprintf('\n')
    end
    sprintf(Subject_IDs{subjId})
    for ii = 1:2
        sprintf('\n')
    end
    save('Results','Results')
    % %     save('ResultsRATM','ResultsRATM')
    
end


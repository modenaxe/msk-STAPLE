% % function [EpiTibASMed, EpiTibASLat] = GIBOK_tibia_it3(EpiTib, EpiTibASMed, EpiTibASLat, CSs)
% % 
% % Z0 = CSs.Z0;
% % % third time this AS is built
% % EpiTibAS3 = TriUnite(EpiTibASMed,EpiTibASLat);
% % 
% % [oLSP,Ztp] = lsplane(EpiTibAS3.Points,  Z0);
% % d = -oLSP*Ztp;
% % EpiTibASMedElmtsOK = find(abs(EpiTibASMed.incenter  *Ztp+d)<5 & ...
% %                               EpiTibASMed.faceNormal*Ztp>0.95 );
% % EpiTibASMed = TriReduceMesh(EpiTibASMed,EpiTibASMedElmtsOK);
% % EpiTibASMed = TriOpenMesh(EpiTib,EpiTibASMed,2);
% % EpiTibASMed = TriConnectedPatch( EpiTibASMed, MedPtsInit );
% % EpiTibASMed = TriCloseMesh(EpiTib,EpiTibASMed,10);
% % 
% % EpiTibASLatElmtsOK = find(abs(EpiTibASLat.incenter*Ztp+d)<3 & ...
% %                               EpiTibASLat.faceNormal*Ztp>0.95 );
% % EpiTibASLat = TriReduceMesh(EpiTibASLat,EpiTibASLatElmtsOK);
% % EpiTibASLat = TriOpenMesh(EpiTib,EpiTibASLat,2);
% % EpiTibASLat = TriConnectedPatch( EpiTibASLat, LatPtsInit );
% % EpiTibASLat = TriCloseMesh(EpiTib,EpiTibASLat,10);
% % 
% % end
function [EpiTibASMed, EpiTibASLat, EpiTibAS_it2] = GIBOK_tibia_ProxArtSurf_it2(EpiTib, EpiTibAS, CSs)

Z0 = CSs.Z0;
Y0 = CSs.Y0;
    
% Update the AS and the fitted LS plane
[oLSP,Ztp] = lsplane(EpiTibAS.Points, Z0);
d = -oLSP * Ztp;

% Seperate Medial and lateral
[ Xel, Yel, ellipsePts , ellipsePpties] = ...
                        EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP);
a = ellipsePpties.a;
b = ellipsePpties.b;
Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Yel'*Y0)*Yel;

% this are medial (1) and lateral (-1)
coeff_set = [1, -1];

%------------
% parameters for filters
%------------
norm_thresh = 0.9;
dist_thresh = 5;
%------------
for nc = 1:2
    coeff = coeff_set(nc);
    PtsInitv = mean(ellipsePts) + coeff*2/3*b*Yel';
    PtsInit(:,:,nc) = [PtsInitv; PtsInitv - 1/3*a*Xel'; PtsInitv + 1/3*a*Xel'];
    cEpiTibAS = TriConnectedPatch( EpiTibAS, PtsInit(:,:,nc));
    
    % Filter out element with wrong normal or too far from LS plane + Smoothing
    EpiTibASElmtsOK = find(abs(cEpiTibAS.incenter*Ztp+d) < dist_thresh & ...
        cEpiTibAS.faceNormal*Ztp > norm_thresh );
    cEpiTibAS = TriReduceMesh(cEpiTibAS,EpiTibASElmtsOK);
    cEpiTibAS = TriOpenMesh(EpiTib,cEpiTibAS,2);
    cEpiTibAS = TriConnectedPatch( cEpiTibAS, PtsInit(:,:,nc) );
    cEpiTibAS = TriCloseMesh(EpiTib,cEpiTibAS,10);
    s(nc) = {cEpiTibAS};
    clear PtsInitv cEpiTibAS EpiTibASElmtsOK
end

EpiTibASMed_it2 = s{1};
EpiTibASLat_it2 = s{2};

% fit again to the new obtain surface
% this triangulation was used to check the output against original GIBOK
EpiTibAS_it2 = TriUnite(EpiTibASMed_it2,EpiTibASLat_it2);

% recompute plane
[oLSP,Ztp] = lsplane(EpiTibAS_it2.Points,  Z0);
d = -oLSP*Ztp;

%------------
% parameters for filters
%------------
norm_thresh = 0.95;
dist_thresh = [5, 3];
%------------
for ncc =1:2
    cur_EpiTibAS = s{ncc};
    EpiTibASElmtsOK = find(abs(cur_EpiTibAS.incenter*Ztp+d)<dist_thresh(ncc) & ...
        cur_EpiTibAS.faceNormal*Ztp>norm_thresh);
    cur_EpiTibAS = TriReduceMesh(cur_EpiTibAS,EpiTibASElmtsOK);
    cur_EpiTibAS = TriOpenMesh(EpiTib,cur_EpiTibAS,2);
    cur_EpiTibAS = TriConnectedPatch( cur_EpiTibAS, PtsInit(:,:,ncc) );
    cur_EpiTibAS = TriCloseMesh(EpiTib,cur_EpiTibAS,10);
    s2(ncc) = {cur_EpiTibAS};
    clear cur_EpiTibAS EpiTibASElmtsOK
end

EpiTibASMed  = s2{1};
EpiTibASLat = s2{2};

end
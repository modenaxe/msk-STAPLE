function EpiTibAS = GIBOK_tibia_ProxArtSurf_it2(EpiTib, EpiTibAS, CSs)

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
dist_thresh = 0.5;

for nc = 1:2
    coeff = coeff_set(nc);
    PtsInit = mean(ellipsePts) + coeff*2/3*b*Yel';
    PtsInit = [PtsInit; PtsInit - 1/3*a*Xel'; PtsInit + 1/3*a*Xel'];
    cEpiTibAS = TriConnectedPatch( EpiTibAS, PtsInit);
    
    % Filter out element with wrong normal or too far from LS plane + Smoothing
    EpiTibASElmtsOK = find(abs(cEpiTibAS.incenter*Ztp+d) < dist_thresh & ...
        cEpiTibAS.faceNormal*Ztp > norm_thresh );
    cEpiTibAS = TriReduceMesh(cEpiTibAS,EpiTibASElmtsOK);
    cEpiTibAS = TriOpenMesh(EpiTib,cEpiTibAS,2);
    cEpiTibAS = TriConnectedPatch( cEpiTibAS, PtsInit );
    cEpiTibAS = TriCloseMesh(EpiTib,cEpiTibAS,10);
    s(nc) = {cEpiTibAS};
    clear PtsInit cEpiTibAS
end

EpiTibAS = TriUnite(s{1},s{2});

end
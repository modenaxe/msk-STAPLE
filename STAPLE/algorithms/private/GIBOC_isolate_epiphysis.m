function EpiTri = GIBOC_isolate_epiphysis(TriObj, Z0, prox_epi)

% First 0.5 mm in Start and End are not accounted for, for stability.
slice_step = 1; %mm 
[Areas, Alt] = TriSliceObjAlongAxis(TriObj, Z0, slice_step);

% removes mesh above the limit of epiphysis (Zepi)
[~ , Zepi, ~] = fitCSA(Alt, Areas);

% choose the bone part of interest
if strcmp(prox_epi, 'proximal')
    ElmtsEpi = find(TriObj.incenter*Z0>Zepi);
elseif strcmp(prox_epi, 'distal')
    ElmtsEpi = find(TriObj.incenter*Z0<Zepi);
end

% return the triangulation
EpiTri = TriReduceMesh( TriObj, ElmtsEpi);
end
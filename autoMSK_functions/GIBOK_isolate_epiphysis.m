function EpiTri = GIBOK_isolate_epiphysis(TriObj, Z0, prox_epi)

% First 0.5 mm in Start and End are not accounted for, for stability.
Alt = linspace( min(TriObj.Points*Z0)+0.5 ,max(TriObj.Points*Z0)-0.5, 100);
it=1;
for d = -Alt
    [ ~ , Area(it), ~ ] = TriPlanIntersect(TriObj, Z0 , d );
    it = it + 1;
end

% removes mesh above the limit of epiphysis (Zepi)
[~ , Zepi, ~] = FitCSA(Alt, Area);
% choose the bone part of interest
if strcmp(prox_epi, 'proximal')
    ElmtsEpi = find(TriObj.incenter*Z0>Zepi);
elseif strcmp(prox_epi, 'distal')
    ElmtsEpi = find(TriObj.incenter*Z0<Zepi);
end
% return the triangulation
EpiTri = TriReduceMesh( TriObj, ElmtsEpi);
end
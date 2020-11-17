%-------------------------------------------------------------------------%
%  Author:   Jean-Baptiste Renault. 
%  Modified by Luca Modenese based on GIBOC-knee prototype.
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function AnkleArtSurf = GIBOC_tibia_DistArtSurf(DistTib, Z0, V_all, CoeffMorpho)

% Get mean curvature of Distal Tibia
Cmean = TriCurvature(DistTib,false);

% first pass for estimating the ankle articular surface
% 1st : Find triangles with less than 30° relative to the tibia principal
% inertia axis (longitudinal) and low curvature then smooth the result with
% morphology operations.
%------------
% parameters
%--------------------
lb_quant = 0.65;
ub_quant = 0.95;
Z0_ang_dev_it1 = 30;
%--------------------
AnkleArtSurfNodesOK0 =  find(Cmean>quantile(Cmean,lb_quant) & ...%cond1
                             Cmean<quantile(Cmean,ub_quant) & ...%cond2
                             rad2deg(acos(-DistTib.vertexNormal*Z0))<Z0_ang_dev_it1);%cond3
% filtering the surface
AnkleArtSurf0 = TriReduceMesh(DistTib,[],double(AnkleArtSurfNodesOK0));
AnkleArtSurf0 = TriCloseMesh(DistTib,AnkleArtSurf0,6*CoeffMorpho);
AnkleArtSurf0 = TriOpenMesh(DistTib,AnkleArtSurf0,4*CoeffMorpho);
AnkleArtSurf0 = TriConnectedPatch( AnkleArtSurf0, mean(AnkleArtSurf0.Points));

% 2nd : fit a polynomial surface to it AND 
% exclude points that are two far (1mm) from the fitted surface,
% then smooth the results with open & close morphology operations
TibiaElmtsIDOK = ankleSurfFit( AnkleArtSurf0, DistTib, V_all );
AnkleArtSurf = TriReduceMesh(DistTib , TibiaElmtsIDOK);
AnkleArtSurf = TriErodeMesh(AnkleArtSurf,2);
AnkleArtSurf = TriCloseMesh(DistTib,AnkleArtSurf,6*CoeffMorpho);
AnkleArtSurf = TriOpenMesh(DistTib,AnkleArtSurf,4*CoeffMorpho);
AnkleArtSurf = TriCloseMesh(DistTib,AnkleArtSurf,2*CoeffMorpho);

% Filter elements that are not oriented towards the "axis" of the AS
AnkleArtSurfProperties = TriMesh2DProperties(AnkleArtSurf);
ZAnkleSurf = AnkleArtSurfProperties.meanNormal;
CAnkle = AnkleArtSurfProperties.onMeshCenter;

% filter surface again and remove more those not aligned with Z0 (<35deg)
% parameters
%--------------
Z0_ang_dev_it2 = 35;
%-----------------
term = bsxfun(@minus,AnkleArtSurf.incenter,CAnkle);
AnkleArtSurfElmtsOK = find(rad2deg(acos(AnkleArtSurf.faceNormal*ZAnkleSurf))<Z0_ang_dev_it2 & ...
                                 sum(term.*AnkleArtSurf.faceNormal,2)./...
                                 sqrt(sum(term.^2,2))<0.1);
% filter the surface (iter 2)
AnkleArtSurf = TriReduceMesh(AnkleArtSurf,AnkleArtSurfElmtsOK);
AnkleArtSurf = TriOpenMesh(DistTib,AnkleArtSurf,4*CoeffMorpho);
AnkleArtSurf = TriCloseMesh(DistTib,AnkleArtSurf,10*CoeffMorpho);

end

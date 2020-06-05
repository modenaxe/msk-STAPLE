function EpiTibCenterRidge = GIBOC_tibia_removePartBetweenRidges_it1(ProxTib, EpiTib, CSs, CoeffMorpho, ELP1, Ztp , is_medial)

Z0 = CSs.Z0;

% using ellipse
a = ELP1.a;
b = ELP1.b;
Xel = ELP1.Xel;
Yel = ELP1.Yel;
ellipsePts = ELP1.ellipsePts;
% Find highest point on medial ridge on an anterior section of the plateau
d = -(mean(ellipsePts)*Xel + 0.5*a);
Curves = TriPlanIntersect( ProxTib, Xel , d );

% % TODO: can I not use this? [LM]
% Curves = TriPlanIntersect( EpiTibAS, Xel , d );
% No this is a 2D surface, not a triangular solid

% just keeping the largest curve
Curve = getLargerPlanarSect(Curves);

% term used in checks below
term = bsxfun(@minus,Curve.Pts,mean(ellipsePts));

if strcmp(is_medial, 'medial')    
    Pts_tmp = Curve.Pts(term*Yel>0,:);
    [~,IDPtsMax] = max(Pts_tmp*Z0);
    coeff = 1;
elseif strcmp(is_medial, 'lateral')
    Pts_tmp = Curve.Pts( term*Yel<0 & ...
                         term*Yel>-b/3&...
                         abs(term*Z0)<a/2,:);
    [~,IDPtsMax] = min(Pts_tmp*Z0);
    coeff = -1;
else
    error('Please specify if medial or lateral');
end

PtsMax = Pts_tmp(IDPtsMax,:);

% Get normal of the plan containing the highest point, the ellipse center
% and Z0 (initial Distal-To-Proximal axis) 
U_tmp =  PtsMax'-mean(ellipsePts)';
np = cross(U_tmp,Ztp); 

np = normalizeV(  coeff*sign(cross(Xel,Yel)'*Z0)*np  ); 
dp = -mean(ellipsePts)*np;

nm = coeff*Yel;
dm = -mean(ellipsePts)*nm;

% Identify the point contained between this plan and ellipse middle plan
NodesOnCenterID = find(sign(EpiTib.Points*np+dp) + sign(EpiTib.Points*nm+dm)>0.1);

if isempty(NodesOnCenterID)
    warning(['No areas near the ridge to remove on the ', is_medial, ' side of knee'])
    EpiTibCenterRidge = [];
    return
end
    
EpiTibCenterRidge = TriReduceMesh( EpiTib, [] , NodesOnCenterID );

% as in original GIBOC
if strcmp(is_medial, 'lateral')
    EpiTibCenterRidge = TriDilateMesh(EpiTib, EpiTibCenterRidge,5*CoeffMorpho);
end

end

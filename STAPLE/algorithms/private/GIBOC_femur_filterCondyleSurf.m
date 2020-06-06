function Condyle_end = GIBOC_femur_filterCondyleSurf(EpiFem, CSs, PtsCondyle, Pts_0_C, CoeffMorpho)


% NOTE in the original toolbox lateral and medial condyles were processed
% differently in the last step. I assume was a typo, given the entire code
% of this function was duplicated. I expect the difference to be small
% between the two versions.

% Using:
% CSs.Z0
% CSs.Y1

Y1 = CSs.Y1;

Center = sphereFit(PtsCondyle);
Condyle = TriReduceMesh(EpiFem, [], PtsCondyle);
Condyle = TriCloseMesh(EpiFem, Condyle, 4*CoeffMorpho);

% Get Curvature
[Cmean,Cgaussian,~,~,~,~] = TriCurvature(Condyle, false);

% Compute a Curvtr norm
Curvtr = sqrt(4*Cmean.^2-2*Cgaussian);

% Calculate the "probability" of a vertex to be on an edge, depends on :
% - Difference in normal orientation from fitted cylinder
% - Curvature Intensity
% - Orientation relative to Distal Proximal axis
CylPts = bsxfun(@minus, Condyle.Points, Center);
Ui = (CylPts - (CylPts*Y1)*Y1');
Ui = Ui ./ repmat(sqrt(sum(Ui.^2,2)),1,3);

AlphaAngle = abs(90-rad2deg(acos(sum(Condyle.vertexNormal.*Ui,2))));
GammaAngle = rad2deg(acos(Condyle.vertexNormal*CSs.Z0));

% Sigmoids functions to compute probability of vertex to be on an edge
Prob_Edge_Angle = 1 ./ (1 + exp((AlphaAngle-50)/10));
Prob_Edge_Angle = Prob_Edge_Angle / max(Prob_Edge_Angle);

Prob_Edge_Curv =  1 ./ ( 1 + exp( - ( Curvtr - 0.25)/0.05));
Prob_Edge_Curv = Prob_Edge_Curv / max(Prob_Edge_Curv);

Prob_FaceUp = 1 ./ (1 + exp((GammaAngle-45)/15));
Prob_FaceUp = Prob_FaceUp / max(Prob_FaceUp);

Prob_Edge = 0.6*sqrt(Prob_Edge_Angle.*Prob_Edge_Curv) +...
			0.05*Prob_Edge_Curv +...
			0.15*Prob_Edge_Angle +...
			0.2*Prob_FaceUp;

Condyle_edges = TriReduceMesh(Condyle,[],find(Prob_Edge_Curv.*Prob_Edge_Angle>0.5));
Condyle_end = TriReduceMesh(Condyle,[],find(Prob_Edge<0.20));
Condyle_end = TriConnectedPatch( Condyle_end, Pts_0_C  );
Condyle_end = TriCloseMesh(EpiFem,Condyle_end,10*CoeffMorpho);

% medial condyle (in original script)
Condyle_end = TriKeepLargestPatch( Condyle_end );
Condyle_end = TriDifferenceMesh( Condyle_end , Condyle_edges );

%%%% TO TEST DIFFERENCES %%%
% % lateral condyle (in original script)
% Condyle_end2 = TriDifferenceMesh( Condyle_end , Condyle_edges );
% Condyle_end2 = TriKeepLargestPatch( Condyle_end2 );
% figure
% quickPlotTriang(Condyle_end, 'r'); hold on
% quickPlotTriang(Condyle_end2, 'g'); hold on

end
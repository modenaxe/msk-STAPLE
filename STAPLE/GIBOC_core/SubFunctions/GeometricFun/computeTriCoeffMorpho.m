function CoeffMorpho = computeTriCoeffMorpho(TriObj)

% Get the mean edge length of the triangles composing the femur
% This is necessary because the functions were originally developed for
% triangulation with constant mean edge lengths of 0.5 mm
PptiesTriObj = TriMesh2DProperties( TriObj );

% Assume triangles are equilaterals
meanEdgeLength = sqrt( 4/sqrt(3) * PptiesTriObj.TotalArea / TriObj.size(1) );

% Get the coefficient for morphology operations
CoeffMorpho = 0.5 / meanEdgeLength ;

end
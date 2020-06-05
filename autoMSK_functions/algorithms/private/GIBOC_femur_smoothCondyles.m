% written by Luca Modenese based on GIBOC code
function fullCondyle = femur_smoothCondyles(EpiFem, PtsFullCondyle, CoeffMorpho)

Condyle = TriReduceMesh(EpiFem, [], PtsFullCondyle );
Condyle2 = TriCloseMesh(EpiFem, Condyle, 5*CoeffMorpho);
fullCondyle = TriOpenMesh(EpiFem, Condyle2, 15*CoeffMorpho);

end
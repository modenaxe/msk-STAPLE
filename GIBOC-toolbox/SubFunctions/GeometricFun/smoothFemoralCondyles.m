% written by Luca Modenese based on GIBOK code
function fullCondyle = smoothFemoralCondyles(EpiFem, PtsFullCondyle, CoeffMorpho)

Condyle = TriReduceMesh(EpiFem, [], PtsFullCondyle );
Condyle2 = TriCloseMesh(EpiFem, Condyle, 5*CoeffMorpho);
fullCondyle = TriOpenMesh(EpiFem, Condyle2, 15*CoeffMorpho);

end
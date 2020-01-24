% written by Luca Modenese based on GIBOK code
function fullCondyle = smoothFemoralCondyles(EpiFem, PtsFullCondyle)

Condyle = TriReduceMesh(EpiFem, [], PtsFullCondyle );
Condyle2 = TriCloseMesh(EpiFem, Condyle, 5);
fullCondyle = TriOpenMesh(EpiFem, Condyle2, 15);

end
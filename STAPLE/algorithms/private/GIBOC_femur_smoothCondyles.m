%-------------------------------------------------------------------------%
%  Author:   Luca Modenese, loosely based on GIBOC-knee prototype. 
%  Copyright 2020 Luca Modenese & Jean-Baptiste Renault
%-------------------------------------------------------------------------%
function fullCondyle = GIBOC_femur_smoothCondyles(EpiFem, PtsFullCondyle, CoeffMorpho)

Condyle = TriReduceMesh(EpiFem, [], PtsFullCondyle );
Condyle2 = TriCloseMesh(EpiFem, Condyle, 5*CoeffMorpho);
fullCondyle = TriOpenMesh(EpiFem, Condyle2, 15*CoeffMorpho);

end
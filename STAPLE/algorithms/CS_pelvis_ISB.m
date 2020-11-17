%-------------------------------------------------------------------------%
%  Author:   Luca Modenese 
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function V = CS_pelvis_ISB(RASIS, LASIS, RPSIS, LPSIS)
% defining the ref system (global)
% with origin at midpoint fo ASIS
Z = normalizeV(RASIS-LASIS);
temp_X = ((RASIS+LASIS)/2.0) - ((RPSIS+LPSIS)/2.0);
pseudo_X = temp_X/norm(temp_X);
Y = normalizeV(cross(Z, pseudo_X));
X = normalizeV(cross(Y, Z));
V = [X Y Z];
end
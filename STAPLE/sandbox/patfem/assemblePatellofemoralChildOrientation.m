function PatellaCS = assemblePatellofemoralChildOrientation(FemurCS, PatellaCS)

%TODO: correct using tibia offset

% take Z from ankle joint (axis of rotation)
Zpar = FemurCS.patellofemoral_r.V(:,3);
% take vertical axis of the tibia
Ytemp = PatellaCS.patellofemoral_r.V(:,2);
% Y and Z orthogonal
Ypar  = normalizeV(Ytemp - Zpar* dot(Zpar,Ytemp)/norm(Zpar));
Xpar  = normalizeV(cross(Ytemp, Zpar));
PatellaCS.V_patellofemoral = [Xpar Ypar Zpar];
PatellaCS.patellofemoral_r.parent_orientation = computeZXYAngleSeq(PatellaCS.V_patellofemoral);
disp(PatellaCS.patellofemoral_r.parent_orientation)
end
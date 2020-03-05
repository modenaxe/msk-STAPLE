function TibiaCS = assembleAnkleParentOrientation(TibiaCS, TalusCS)
% take Z from ankle joint (axis of rotation)
Zpar  = TalusCS.talocrural_r.V_ankle(:,3);
% take vertical axis of the tibia
Ytemp = TibiaCS.V_knee(:,2);
% Y and Z orthogonal
Ypar = normalizeV(Ytemp - Zpar* dot(Zpar,Ytemp)/norm(Zpar));
Xpar  = normalizeV(cross(Ytemp, Zpar));
TibiaCS.V_ankle = [Xpar Ypar Zpar];
TibiaCS.ankle_r.parent_orientation = computeZXYAngleSeq(TibiaCS.V_ankle);
disp(TibiaCS.ankle_r.parent_orientation)
end
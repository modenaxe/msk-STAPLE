function TibiaCS = assembleAnkleParentOrientation(TibiaCS, TalusCS)
% take Z from ankle joint (axis of rotation)
Zpar  = TalusCS.ankle_r.V(:,3);
% take vertical axis of the tibia
Ytemp = TibiaCS.knee_r.V(:,2);
% Y and Z orthogonal
Ypar = normalizeV(Ytemp - Zpar* dot(Zpar,Ytemp)/norm(Zpar));
Xpar  = normalizeV(cross(Ytemp, Zpar));
TibiaCS.ankle_r.V = [Xpar Ypar Zpar];
TibiaCS.ankle_r.parent_orientation = computeZXYAngleSeq(TibiaCS.ankle_r.V);
% disp(TibiaCS.ankle_r.parent_orientation)
end
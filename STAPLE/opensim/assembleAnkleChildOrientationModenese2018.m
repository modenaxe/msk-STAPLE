function TalusCS = assembleAnkleChildOrientationModenese2018(TalusCS, CalcnCS)

% take Z from ankle joint (axis of rotation)
Zchild  = normalizeV(TalusCS.ankle_r.V(:,3));
% take X ant-post axis of the calcaneus
Xtemp = CalcnCS.V(:,1);
% X and Z orthogonal
Xchild = normalizeV(Xtemp - Zchild* dot(Zchild,Xtemp)/norm(Zchild));
Ychild  = normalizeV(cross(Zchild, Xtemp));
TalusCS.ankle_r.V = [Xchild Ychild Zchild];
TalusCS.ankle_r.child_orientation = computeXYZAngleSeq(TalusCS.ankle_r.V);


end
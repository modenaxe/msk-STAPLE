function TibiaCS = assembleAnkleParentOrientationModenese2018(TibiaCS, TalusCS)
% take Z from ankle joint (axis of rotation)
Zparent  = TalusCS.ankle_r.V(:,3);
% take line joining talus and knee centres
if isequal(size(TibiaCS.knee_r.Origin), [1, 3])
    TibiaCS.knee_r.Origin = TibiaCS.knee_r.Origin';
end
Ytemp = (TibiaCS.knee_r.Origin - TalusCS.ankle_r.Origin)/...
    norm(TibiaCS.knee_r.Origin - TalusCS.ankle_r.Origin);
% Y and Z orthogonal
Yparent = normalizeV(Ytemp - Zparent* dot(Zparent,Ytemp)/norm(Zparent));
Xparent  = normalizeV(cross(Ytemp, Zparent));
TibiaCS.ankle_r.V = [Xparent Yparent Zparent];
TibiaCS.ankle_r.parent_orientation = computeXYZAngleSeq(TibiaCS.ankle_r.V);
% disp(TibiaCS.ankle_r.parent_orientation)
end
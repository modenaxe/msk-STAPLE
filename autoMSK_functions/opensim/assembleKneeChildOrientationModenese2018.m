function TibiaCS = assembleKneeChildOrientationModenese2018(FemurCS, TibiaCS, TalusCS)

% take Z from knee joint (axis of rotation)
Zparent  = FemurCS.knee_r.V(:,3);
% take line joining talus and knee centres
if isequal(size(FemurCS.knee_r.Origin), [1, 3])
    TibiaCS.knee_r.Origin = FemurCS.knee_r.Origin';
else
    TibiaCS.knee_r.Origin = FemurCS.knee_r.Origin;
end
% vertical axis joining knee and ankle joint centres
Ytemp = (TibiaCS.knee_r.Origin - TalusCS.ankle_r.Origin)/...
    norm(TibiaCS.knee_r.Origin - TalusCS.ankle_r.Origin);
% Y and Z orthogonal
Yparent = normalizeV(Ytemp - Zparent* dot(Zparent,Ytemp)/norm(Zparent));
Xparent  = normalizeV(cross(Ytemp, Zparent));
TibiaCS.knee_r.V = [Xparent Yparent Zparent];
TibiaCS.knee_r.child_orientation = computeXYZAngleSeq(TibiaCS.knee_r.V);

end
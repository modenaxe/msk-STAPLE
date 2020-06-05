function TalusCS = assembleSubtalarParentOrientationModenese2018(FemurCS, TalusCS)

% take Z from subtalar joint (axis of rotation)
Zparent  = TalusCS.subtalar_r.V(:,3);
% take Y pointing to the knee joint centre
Ytemp = (FemurCS.knee_r.parent_location - TalusCS.subtalar_r.parent_location)/...
        norm((FemurCS.knee_r.parent_location - TalusCS.subtalar_r.parent_location));
% X and Z orthogonal
Yparent = normalizeV(Ytemp' - Zparent* dot(Zparent,Ytemp')/norm(Zparent));
Xparent  = normalizeV(cross(Yparent, Zparent));
TalusCS.subtalar_r.V = [Xparent Yparent Zparent];
TalusCS.subtalar_r.parent_orientation = computeXYZAngleSeq(TalusCS.subtalar_r.V);

end
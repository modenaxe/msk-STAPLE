function CSs = createFemurCoordSystKai2014(DistFem, CSs)

[Ok_FC_Pts1, Ok_FC_Pts2] = sliceFemoralCondyles(DistFem, CSs.X0);

% fitting spheres to points from the sliced curves
[center1,radius1] = sphereFit(Ok_FC_Pts1);
[center2,radius2] = sphereFit(Ok_FC_Pts2);

% define the reference system (NB: this is different from the other ref
% systems - mechanical axis just defines the plane, not an axis)
Yml = normalizeV(center2-center1);
Xap = normalizeV(cross(Yml,( center2 - CSs.CenterFH_Kai)'));
Zdp = cross(Xap,Yml);
CenterKneeKai = 0.5*(center1+center2);

% store axes in structure
CSs.Kai.Center1 = center1;
CSs.Kai.Center2 = center2;
CSs.Kai.Radius1 = radius1;
CSs.Kai.Radius2 = radius2;
CSs.Kai.Origin  = CenterKneeKai;
CSs.Kai.X       = Xap;
CSs.Kai.Y       = Yml;
CSs.Kai.Z       = Zdp;
CSs.Kai.V       = [Xap Yml Zdp];
end
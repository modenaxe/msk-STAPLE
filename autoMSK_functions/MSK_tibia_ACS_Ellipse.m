function MSK_tibia_ACS_Ellipse(EpiTibAS, CS)

% fit a plane to the resulting tibial epiPhysis 
[oLSP, Ztp] = lsplane(EpiTibAS.Points,CS.Z0);

% fit ellipse to articular surface
[~, Yel, ellipsePts ] = EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP );

% origin of the ellipse is considered knee centre on tibia
KneeCenter = mean(ellipsePts);

% common axes: X is orthog to Y and Z, which are not mutually perpend
Yel = sign(Yel'*CS.Y0)*Yel;
Zmech = normalizeV(KneeCenter-ankleCenter); 
Xend = cross(Yel,Zmech);

% Final ACS

Yend = cross(Zmech,Xend);

Yend = sign(Yend'*Y0)*Yend;
Zend = Zmech;
Xend = cross(Yend,Zend);

Vend = [Xend Yend Zend];

% Result write
CS.ECASE.CenterVol = CenterVol;
CS.ECASE.CenterAnkle = ankleCenter;
CS.ECASE.CenterKnee = KneeCenter;
CS.ECASE.Z0 = Z0;
CS.ECASE.Ztp = Ztp;
CS.ECASE.Zmech = Zmech;

CS.ECASE.Origin = KneeCenter;
CS.ECASE.X = Xend;
CS.ECASE.Y = Yend;
CS.ECASE.Z = Zend;

CS.ECASE.Origin = KneeCenter;
CS.ECASE.V = Vend;

end
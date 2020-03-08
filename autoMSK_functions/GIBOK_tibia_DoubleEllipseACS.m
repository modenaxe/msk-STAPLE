function CSs = GIBOK_tibia_DoubleEllipseACS(EpiTibASMed, EpiTibASLat, CSs)
[ TibArtLat_ppt ] = TriMesh2DProperties( EpiTibASLat );
[ TibArtMed_ppt ] = TriMesh2DProperties( EpiTibASMed );
Pt_Knee = 0.5*TibArtMed_ppt.Center + 0.5*TibArtLat_ppt.Center;

Zmech = normalizeV(Pt_Knee-ankleCenter);

Y2 = TibArtMed_ppt.Center - TibArtLat_ppt.Center;
Y2 = Y2' / norm(Y2);

% Final ACS
Xend = cross(Y2,Zmech)/norm(cross(Y2,Zmech));
Yend = cross(Zmech,Xend);

Xend = sign(Xend'*Y0)*Xend;
Yend = sign(Yend'*Y0)*Yend;
Zend = Zmech;
Xend = cross(Yend,Zend);

Vend = [Xend Yend Zend];

% Result write
CSs.CASC.CenterVol = CenterVol;
CSs.CASC.CenterAnkle = ankleCenter;
CSs.CASC.CenterKnee = Pt_Knee;
CSs.CASC.Z0 = Z0;
CSs.CASC.Ztp = Ztp;

CSs.CASC.Origin = Pt_Knee;
CSs.CASC.X = Xend;
CSs.CASC.Y = Yend;
CSs.CASC.Z = Zend;

CSs.CASC.V  = Vend ;


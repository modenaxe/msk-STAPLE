function GIBOK_tibia_EllipseACS(EpiTibAS, CSs)

% fit a plane to the resulting tibial epiPhysis 
[oLSP, Ztp] = lsplane(EpiTibAS.Points,CSs.Z0);

%% Technic 1 : Fitted Ellipse
[ Xel, Yel, ellipsePts ] = EllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP );
Xel = sign(Xel'*Y0)*Xel;
Yel = sign(Yel'*Y0)*Yel;
Pt_Knee = mean(ellipsePts);

Zmech = Pt_Knee - ankleCenter; 
Zmech = Zmech' / norm(Zmech);

% Final ACS
Xend = cross(Yel,Zmech)/norm(cross(Yel,Zmech));
Yend = cross(Zmech,Xend);

Yend = sign(Yend'*Y0)*Yend;
Zend = Zmech;
Xend = cross(Yend,Zend);

Vend = [Xend Yend Zend];

% Result write
CSs.ECASE.CenterVol = CenterVol;
CSs.ECASE.CenterAnkle = ankleCenter;
CSs.ECASE.CenterKnee = Pt_Knee;
CSs.ECASE.Z0 = Z0;
CSs.ECASE.Ztp = Ztp;
CSs.ECASE.Zmech = Zmech;

CSs.ECASE.Origin = Pt_Knee;
CSs.ECASE.X = Xend;
CSs.ECASE.Y = Yend;
CSs.ECASE.Z = Zend;

CSs.ECASE.Origin = Pt_Knee;
CSs.ECASE.V = Vend;
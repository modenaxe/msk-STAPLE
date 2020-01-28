function CSs = createFemurCoordSystEllipsoidOnCondyles(Condyle_1,Condyle_2, CSs)
% REFERENCE SYSTEM
% centred in the midpoint of the ellipsoid
% Z: upwards (Orig->HJC)
% X: perpendicolar to Z and the plane with sphere centres (Yelpsd)
% Y: cross of XZ

% fitting ellipsoids
center1 = ellipsoid_fit( Condyle_1.Points , '' );
center2 = ellipsoid_fit( Condyle_2.Points , '' );

% normalize and check axis direction
Yelpsd =  normalizeV(center2-center1);
Yelpsd = sign(Yelpsd'*CSs.Y0)*Yelpsd;

% knee joint centre is midpoint of ellipsoid centres
KneeCenterElpsd = 0.5*(center2+center1)';

% define axes
Zend =  normalizeV( CSs.CenterFH - KneeCenterElpsd);
Xend =  normalizeV(cross(Yelpsd, Zend));
Yend = cross(Zend, Xend);

% [LM] this was in the original GIBOK code.
% not needed, the Yend)sph is actually defined in the same way as Yend
% here.
% Yend = sign(Yend'*Yend_sph)*Yend;
% Xend = cross(Yend,Zend);

% store axes
CSs.CE.Yelpsd   = Yelpsd;
CSs.CE.Origin   = KneeCenterElpsd;
CSs.CE.X        = Xend;
CSs.CE.Y        = Yend;
CSs.CE.Z        = Zend;
CSs.CE.V        = [Xend Yend Zend];

end
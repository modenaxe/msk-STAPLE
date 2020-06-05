function CSs = createFemurCoordSystCylinderOnCondyles(Condyle_Lat, Condyle_Med, CSs, tolp, tolg)
% REFERENCE SYSTEM
% centred in the midpoint of the spheres
% Z: upwards (Orig->HJC)
% X: perpendicolar to Z and the plane with cylinder axis (Y2)
% Y: cross of XZ

if nargin < 4
    % tolp     Tolerance for test on step length. 
    tolp = 0.001;
    % tolg     Tolerance for test on gradient.
    tolg = 0.001;
end

% get all points of triangulations
PtsCondyle    = [Condyle_Lat.Points; Condyle_Med.Points];

% initialise the least square search for cylinder

% if available use results of sphere fitting 
if isfield(CSs, 'PCS')
    Axe0 = (CSs.PCS.Center1-CSs.PCS.Center2)';
    Center0 = 0.5*(CSs.PCS.Center1 + CSs.PCS.Center2)';
    Radius0 = 0.5*(CSs.PCS.Radius1 +CSs.PCS.Radius2);
    lat_med_vec = CSs.PCS.Y;
else
    % if results of sphere fitting are not available use the fem geometry
    % centre as centroid of points
    Center0 = mean(PtsCondyle)';
    % radius as average distance of point from centre
    dist_vecs = bsxfun(@minus,PtsCondyle,Center0');
    Radius0 =  mean(sqrt(dist_vecs(:,1).^2.0+dist_vecs(:,2).^2.0+dist_vecs(:,3).^2.0));
    Axe0    = CSs.Y1;
    lat_med_vec = CSs.Y1;
end

% fit least square cylinder
[x0n, an, rn] = lscylinder(PtsCondyle, Center0, Axe0, Radius0, tolp, tolg);

% Y2 is the cylinder axis versor
Y2 =  normalizeV(an);

% compute areas properties of condyles
PptiesLat = TriMesh2DProperties(Condyle_Lat);
PptiesMed = TriMesh2DProperties(Condyle_Med);

% and extract computed centroid
CenterPtsLat = PptiesLat.Center;
CenterPtsMed = PptiesMed.Center;

% project centroid of each condyle on Y2 (the axis of the cylinder)
OnAxisPtLat = x0n' + ((CenterPtsLat-x0n')*Y2) * Y2';
OnAxisPtMed = x0n' + ((CenterPtsMed-x0n')*Y2) * Y2';

% knee centre is the midpoint of the two projects points
Pt_Knee = 0.5*OnAxisPtLat + 0.5*OnAxisPtMed;

% projecting condyle points on cylinder axis
PtsCondyldeOnCylAxis = bsxfun(@plus,(bsxfun(@minus,PtsCondyle,x0n')*Y2)*Y2',x0n');

%======================================
% [LM] - unsure if this is of any help. 
% Commented for now.
%======================================
% % Alternative way to define the CS origin ?
% % Define the Knee point by using the range of the articular surfaces
% %   projected on the articular surfaces
% points at one extremity of these projections
% [~,Itmp] = min(PtsCondyldeOnCylAxis*Y2) ; 
% Pt_tmp = PtsCondyldeOnCylAxis(Itmp,:);
% Pt_Knee0 = Pt_tmp + range(PtsCondyldeOnCylAxis*Y2)/2*Y2';
% subtract to Z0 (prox-dist axis) the Y2 component
%===================================
% [LM] this line might be wrong
%===================================
% Z2 =  normalizeV( CSs.Z0 - CSs.Z0'*Y2*Y2 );
%===================================
% Pt_Knee0 = Pt_Knee0 - rn*Z2';
% CSs.PCC.CenterKneeRange     = Pt_Knee0;
%===================================

% Final steps to construct direct ACS
Zmech =  normalizeV(CSs.CenterFH-Pt_Knee); %mech axis of femur
Xend =  normalizeV(cross(Y2, Zmech));
Yend = cross(Zmech, Xend);
Yend = sign(Yend'*lat_med_vec)*Yend; % check direction
Xend = cross(Yend, Zmech);

% assembling the output structure
% store Y used in convex hull
CSs.PCC.YCvxHull            = CSs.Y1;% [LM] is this necessary?

% store cylinder data
CSs.PCC.cyl_Y               = Y2; %normalised axis from lst
CSs.PCC.cyl_Pt              = x0n;
CSs.PCC.cyl_Radius          = rn;
CSs.PCC.cyl_Range           = range(PtsCondyldeOnCylAxis*Y2);
CSs.PCC.Origin              = Pt_Knee;

% store reference system
CSs.PCC.X                   = Xend;
CSs.PCC.Y                   = Yend;
CSs.PCC.Z                   = Zmech;
CSs.PCC.V                   = [Xend Yend Zmech];

end
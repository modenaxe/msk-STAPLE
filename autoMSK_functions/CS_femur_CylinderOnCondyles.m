function [CS, JCS] = CS_femur_CylinderOnCondyles(Condyle_Lat, Condyle_Med, CS, in_mm, debug_plots, tolp, tolg)

% check units
if nargin<4;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end
% debug plots off by default
if nargin<5; debug_plots = 0; end

% check tolerances (tolp: tol step length; tolg: tol test of gradient)
if nargin < 6  ;     tolp = 0.001;    tolg = 0.001;  end

% get all points of triangulations
PtsCondyle    = [Condyle_Lat.Points; Condyle_Med.Points];

% initialise the least square search for cylinder with the sphere fitting
[CSSph, JCSSph] = CS_femur_SpheresOnCondyles(Condyle_Lat, Condyle_Med, CS, 0);

% initialise variables
Axe0 = (CSSph.sphere_center_lat - CSSph.sphere_center_med)';
Center0 = 0.5*(CSSph.sphere_center_lat + CSSph.sphere_center_med)';
Radius0 = 0.5*(CSSph.sphere_radius_lat +CSSph.sphere_radius_med);
Z_dir = JCSSph.knee_r.V(:, 3);

% fit least square cylinder
[x0n, an, rn] = lscylinder(PtsCondyle, Center0, Axe0, Radius0, tolp, tolg);

% Y2 is the cylinder axis versor
Y2 =  normalizeV(an);

% compute areas properties of condyles
PptiesLat = TriMesh2DProperties(Condyle_Lat);
PptiesMed = TriMesh2DProperties(Condyle_Med);

% extract computed centroid
CenterPtsLat = PptiesLat.Center;
CenterPtsMed = PptiesMed.Center;

% project centroid of each condyle on Y2 (the axis of the cylinder)
OnAxisPtLat = x0n' + ((CenterPtsLat-x0n')*Y2) * Y2';
OnAxisPtMed = x0n' + ((CenterPtsMed-x0n')*Y2) * Y2';

% knee centre is the midpoint of the two projects points
KneeCenter = 0.5*OnAxisPtLat + 0.5*OnAxisPtMed;

% projecting condyle points on cylinder axis
PtsCondyldeOnCylAxis = bsxfun(@plus,(bsxfun(@minus,PtsCondyle,x0n')*Y2)*Y2',x0n');

% store cylinder data
CS.Cyl_Y               = Y2; %normalised axis from lst
CS.Cyl_Pt              = x0n;
CS.Cyl_Radius          = rn;
CS.Cyl_Range           = range(PtsCondyldeOnCylAxis*Y2);

% common axes: X is orthog to Y and Z, which are not mutually perpend
Y = normalizeV(CS.CenterFH_Renault - KneeCenter); %mech axis of femur
Z = normalizeV(sign(Y2'*Z_dir)* Y2);% cylinder axis
X = cross(Y, Z);

% define hip joint
Zml_hip = cross(X, Y);
JCS.hip_r.V = [X Y Zml_hip];
JCS.hip_r.child_location = CS.CenterFH_Renault * dim_fact;
JCS.hip_r.child_orientation = computeZXYAngleSeq(JCS.hip_r.V);
JCS.hip_r.Origin = CS.CenterFH_Renault;

% define knee joint
Y_knee = cross(Z, X);
JCS.knee_r.V = [X Y_knee Z];
JCS.knee_r.parent_location = KneeCenter * dim_fact;
JCS.knee_r.parent_orientation = computeZXYAngleSeq(JCS.knee_r.V);
JCS.knee_r.Origin = KneeCenter;

% % debug plots
if debug_plots == 1
    quickPlotTriang(Condyle_Lat, 'b')
    quickPlotTriang(Condyle_Med, 'r')
    plotCylinder( Y2, rn, KneeCenter, CS.Cyl_Range*1.1, 1, 'g')
end

end
function CS = MSK_femur_ACS_CylinderOnCondyles(Condyle_Lat, Condyle_Med, CS, in_mm, tolp, tolg)

% check units
if nargin<4;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% check tolerances (tolp: tol step length; tolg: tol test of gradient)
if nargin < 6     ;     tolp = 0.001;    tolg = 0.001;  end

% get all points of triangulations
PtsCondyle    = [Condyle_Lat.Points; Condyle_Med.Points];

% initialise the least square search for cylinder with the sphere fitting
CSSph = MSK_femur_ACS_SpheresOnCondyles(Condyle_Lat, Condyle_Med, CS);

% initialise variables
Axe0 = (CSSph.Center_Lat - CSSph.Center_Med)';
Center0 = 0.5*(CSSph.Center_Lat + CSSph.Center_Med)';
Radius0 = 0.5*(CSSph.Radius_Lat +CSSph.Radius_Med);
Z_dir = CSSph.V_knee(:, 3);

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

% store cylinder data
CS.Cyl_Y               = Y2; %normalised axis from lst
CS.Cyl_Pt              = x0n;
CS.Cyl_Radius          = rn;
CS.Cyl_Range           = range(PtsCondyldeOnCylAxis*Y2);
CS.Origin              = KneeCenter;

% common axes: X is orthog to Y and Z, which are not mutually perpend
Y = normalizeV(CS.CenterFH - KneeCenter); %mech axis of femur
Z = normalizeV(sign(Y2'*Z_dir)* Y2);% cylinder axis
X = cross(Y, Z);

% define hip joint
Zml_hip = cross(X, Y);
CS.V_hip = [X Y Zml_hip];
CS.hip_r.child_location = CS.CenterFH * dim_fact;
CS.hip_r.child_orientation = computeZXYAngleSeq(CS.V_hip);

% define knee joint
Y_knee = cross(Z, X);
CS.V_knee = [X Y_knee Z];
CS.knee_r.parent_location = KneeCenter * dim_fact;
CS.knee_r.parent_orientation = computeZXYAngleSeq(CS.V_knee);

end
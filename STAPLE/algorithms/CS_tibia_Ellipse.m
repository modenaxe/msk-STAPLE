% fitting one ellipse to the articular surfaces identified on the proximal
% tibia.
%    TODO: copy description from paper
function [CS, JCS] = CS_tibia_Ellipse(EpiTibAS, CS, side)

% get sign correspondent to body side
[side_sign, side_low] = bodySide2Sign(side);

% joint names
knee_name   = ['knee_', side_low];
ankle_name  = ['ankle_', side_low];

% fit a plane to the resulting tibial epiPhysis 
[oLSP, Ztp] = lsplane(EpiTibAS.Points,CS.Z0);

% fit ellipse to articular surface
[~, Yelps, EllipsePts ] = fitEllipseOnTibialCondylesEdge( EpiTibAS, Ztp , oLSP );

% centroid of the ellipse is considered knee centre on tibia
KneeCenter = mean(EllipsePts);

% Store body info
CS.ElpsMaxPtVect = Yelps;
CS.ElpsPts       = EllipsePts;

% common axes: X is orthog to Y and Z, which are not mutually perpend
Z = normalizeV(sign(Yelps'*CS.Y0)*Yelps) * side_sign;
Y = normalizeV(KneeCenter-CS.AnkleCenter); % mechanical axis
X = normalizeV(cross(Y, Z));

% define the knee reference system
% this was my first guess - keep the medio-lateral direction as identified
% by the algorithm. I don't think it's a good idea, because you lose the
% mechanical axis, while you can still keep the frontal plane.
% % Ydp_knee  = normalizeV(cross(Z, X));
% % JCS.knee_r.V = [X Ydp_knee Z];

% define the knee reference system
Zml_knee  = normalizeV(cross(X,Y));
JCS.(knee_name).V = [X Y Zml_knee];

% define knee child
JCS.(knee_name).child_orientation = computeXYZAngleSeq(JCS.(knee_name).V);
JCS.(knee_name).Origin        = KneeCenter;
% the knee axis is defined by the femoral fitting
% CS.knee_r.child_location = KneeCenter*dim_fact;

% the talocrural joint is also defined by the talus fitting.
% apart from the reference system -> NB: Z axis to switch with talus Z
JCS.(ankle_name).parent_orientation = computeXYZAngleSeq(JCS.(knee_name).V);

end
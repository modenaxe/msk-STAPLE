%Reference system built from the centroids of the articular surfaces
function [CS, JCS] = CS_tibia_ArtSurfCentroids(EpiTibASMed, EpiTibASLat, CS)

% compute 2D prop  for articular surfaces
[ TibArtLat_ppt ] = TriMesh2DProperties( EpiTibASLat );
[ TibArtMed_ppt ] = TriMesh2DProperties( EpiTibASMed );

% midpoint of centroids is knee centre
KneeCenter = 0.5*(TibArtMed_ppt.Center + TibArtLat_ppt.Center);

% Store body info
CS.Centroid_AS_med  = TibArtMed_ppt.Center;
CS.Centroid_AS_lat  = TibArtLat_ppt.Center;

% common axes: X is orthog to Y and Z, which are not mutually perpend
Y = normalizeV(KneeCenter-CS.AnkleCenter); % mechanical axis
Z = normalizeV(TibArtLat_ppt.Center-TibArtMed_ppt.Center); % pointing laterally
X = normalizeV(cross(Y, Z));

% define the knee reference system
% define the knee reference system
% this was my first guess - keep the medio-lateral direction as identified
% by the algorithm. I don't think it's a good idea, because you lose the
% mechanical axis, while you can still keep the frontal plane.
% % Ydp_knee  = normalizeV(cross(Z, X));
% % JCS.knee_r.V = [X Ydp_knee Z];
Zml_knee  = normalizeV(cross(X,Y));
JCS.knee_r.V = [X Y Zml_knee];

% define knee child
JCS.knee_r.child_orientation = computeXYZAngleSeq(JCS.knee_r.V);
JCS.knee_r.Origin        = KneeCenter;
% the knee axis is defined by the femoral fitting
% CS.knee_r.child_location = KneeCenter*dim_fact;

% the talocrural joint is also defined by the talus fitting.
% apart from the reference system -> NB: Z axis to switch with talus Z
JCS.ankle_r.parent_orientation = computeXYZAngleSeq(JCS.knee_r.V);

end

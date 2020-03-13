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
X = cross(Y, Z);

% define the knee reference system
Ydp_knee  = cross(Z, X);
JCS.knee_r.V = [X Ydp_knee Z];
JCS.knee_r.child_orientation = computeZXYAngleSeq(JCS.knee_r.V);
JCS.knee_r.Origin        = KneeCenter;
% the knee axis is defined by the femoral fitting
% CS.knee_r.child_location = KneeCenter*dim_fact;

% the talocrural joint is also defined by the talus fitting.
% apart from the reference system -> NB: Z axis to switch with talus Z
JCS.ankle_r.parent_orientation = computeZXYAngleSeq(JCS.knee_r.V);

end

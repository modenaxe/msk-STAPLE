%Reference system built from the centroids of the articular surfaces
function [CS, JCS] = CS_tibia_ArtSurfCentroids(EpiTibASMed, EpiTibASLat, CS, side)

% get sign correspondent to body side
[side_sign, side_low] = bodySide2Sign(side);

% joint names
knee_name   = ['knee_', side_low];
ankle_name  = ['ankle_', side_low];

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
Z = normalizeV(TibArtLat_ppt.Center-TibArtMed_ppt.Center)*side_sign; % pointing laterally (right), medially (left)
X = normalizeV(cross(Y, Z));

%---------- NOTE------------------
% define the knee reference system
% this was my first guess - keep the medio-lateral direction as identified
% by the algorithm. I don't think it's a good idea, because you lose the
% mechanical axis, while you can still keep the frontal plane.
% % Ydp_knee  = normalizeV(cross(Z, X));
% % JCS.knee_r.V = [X Ydp_knee Z];
%----------------------------------

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

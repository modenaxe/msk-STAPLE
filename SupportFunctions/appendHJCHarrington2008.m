% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %
%
% Function written specifically for MRI models. It appends the HJC in the
% Markers structure of bony landmarks detected automatically.

function  Markers = appendHJCHarrington2008(Markers)

% extract markers
LASIS = Markers.LASIS;
RASIS = Markers.RASIS;
LPSIS = Markers.LPSIS;
RPSIS = Markers.RPSIS;

% measure geometrical parameters needed for regression
MID_ASIS = (LASIS+RASIS)/2;
MID_PSIS = (LPSIS+RPSIS)/2;
PW = norm(LASIS-RASIS);
PD = norm(MID_ASIS-MID_PSIS);

% HArrington regression equations
x = -0.24*PD-9.9;
y = -0.30*PW-10.9;
z = 0.33*PW+7.3;

% build reference system
Z_axis = (RASIS-LASIS)/norm((RASIS-LASIS));
X_axis_temp = MID_ASIS-MID_PSIS;
Y_axis = cross(Z_axis, X_axis_temp)/norm(cross(Z_axis, X_axis_temp));
X_axis = cross(Y_axis, Z_axis);

% from ISB to inertial reference system
Or = MID_ASIS';
Rmat = [X_axis; Y_axis; Z_axis]';

% place Markers in the set
RHJC = [x;y;z];
LHJC = [x;y;-z];

% move HJCs in the inertial reference frame
Markers.RHJC = (Or+Rmat*RHJC)';
Markers.LHJC = (Or+Rmat*LHJC)';

end
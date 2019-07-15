%__________________________________________________________________________
% Author: Luca Modenese, July 2013
% email: l.modenese@griffith.edu.au
%__________________________________________________________________________
%
function PD = calculateMeanPelvicDepth(pelvisMarkersInGlob,varargin)

% varargin gives a value for the correction due to calculating the
% pelvis depth from markers.
% Default is 14 mm: no skin layer considered
if ~isempty(varargin)
    markerCorrection = varargin{1};
else
    markerCorrection = 0.014;
end

% Assignment to internal variables
ASIS1 = pelvisMarkersInGlob.R_ASIS;
ASIS2 = pelvisMarkersInGlob.L_ASIS;

% Calculating the midpoint of PSIS markers
Sacrum = (pelvisMarkersInGlob.R_PSIS+pelvisMarkersInGlob.L_PSIS)/2.0;

% Calculating the area of the triangle between the two ASIS and the Sacrum
% marker (Heron's formula).

% semiperimeter
c = ASIS1-Sacrum;
b = ASIS2-Sacrum;
a = ASIS1-ASIS2;

% calculating norms
for k = 1:size(ASIS1,1)
    a_norm(k,1) = norm(a(k,:));
    b_norm(k,1) = norm(b(k,:));
    c_norm(k,1) = norm(c(k,:));
end
s= (a_norm+b_norm+c_norm)/2.0;

%formula
Area = (s.*(s-a_norm).*(s-b_norm).*(s-c_norm)).^0.5;

% Pelvic depth is the height of the triangle wrt the segment connecting the
% ASIS

%vector
pelvicDepthVect  = 2*Area./a_norm;

% mean value of the pelvic depth
PD = mean(pelvicDepthVect)- markerCorrection;
end

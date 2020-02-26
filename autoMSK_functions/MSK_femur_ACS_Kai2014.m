%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         % 
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
% script that takes as an input a femur geometry and computes the ISB
% reference system based on Kai et al. 2014.

function CS = MSK_femur_ACS_Kai2014(Femur, DistFem, in_mm)

% check units
if nargin<3;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% if this is an entire femur then cut it in two parts
% but keep track of all geometries
if ~exist('DistFem','var')
      V_all = pca(Femur.Points);
      [ProxFem, DistFem] = cutLongBoneMesh(Femur);
      [ ~, CenterVol] = TriInertiaPpties(Femur);
      
else
    % join two parts in one triangulation
    ProxFem = Femur;
    Femur = TriUnite(DistFem, ProxFem);
    [ V_all, CenterVol] = TriInertiaPpties( Femur );
end

%-------------------------------------
% Z0: points upwards (inertial axis) 
% Y0: points medio-lat (from OT and Z0 in findFemoralHead.m)
% X0: used only in Kai2014
%-------------------------------------

% Initial estimate of the Distal-to-Proximal (DP) axis Z0
% Check that the distal femur is 'below' the proximal femur,
% invert Z0 direction otherwise
Z0 = V_all(:,1);
Z0 = sign((mean(ProxFem.Points)-mean(DistFem.Points))*Z0)*Z0;

% store approximate Z direction and centre of mass of triangulation
CS.Z0 = Z0;
CS.CenterVol = CenterVol;

% find femoral head
[CS, MostProxPoint] = findFemoralHead_Kai2014(ProxFem, CS);

% completing the inertia-based reference system
% the most proximal point on the fem head is medial wrt to the inertial
% axes. However, if is better to decouple the vector from the global
% reference system to ensure robustness (JIA dataset gives problems
% otherwise).
medial_to_z = MostProxPoint-CenterVol';
CS.Y0 = normalizeV(cross(cross(CS.Z0, medial_to_z'),CS.Z0));
CS.X0 = cross(CS.Y0, CS.Z0);

% debug plots
plot3(MostProxPoint(1), MostProxPoint(2), MostProxPoint(3),'ro','LineWidth',4)
CS.Origin  = CenterVol;
quickPlotRefSystem(CS)

% slicing the femoral condyles
[CS, FC_Med_Pts1, FC_Lat_Pts2] = sliceFemoralCondyles(DistFem, CS);

% fitting spheres to points from the sliced curves
[center_med,radius_med] = sphereFit(FC_Med_Pts1);
[center_lat,radius_lat] = sphereFit(FC_Lat_Pts2);

% centre of the knee if the midpoint between spheres
CenterKneeKai = 0.5*(center_med+center_lat);

% store axes in structure
CS.Center1 = center_med;
CS.Center2 = center_lat;
CS.Radius1 = radius_med;
CS.Radius2 = radius_lat;
CS.Origin  = CenterKneeKai;

% common axes
Z = normalizeV(center_lat-center_med);
Y = normalizeV(CS.CenterFH_Kai- CenterKneeKai);
X = cross(Y,Z);

% define the knee reference system
Ori_knee = CenterKneeKai;
Ydp_knee = cross(Z, X);
CS.V_knee  = [X Ydp_knee Z];

% define the hip reference system
Ori_hip = CS.CenterFH_Kai;
Zml_hip = cross(X, Y);
CS.V_hip  = [X Y Zml_hip];

% define hip_r joint
CS.hip_r.child_location    = Ori_hip*dim_fact;
CS.hip_r.child_orientation = computeZXYAngleSeq(CS.V_hip);

% define knee_r joint
CS.knee_r.parent_location = Ori_knee*dim_fact;
CS.knee_r.parent_orientation = computeZXYAngleSeq(CS.V_knee);

end


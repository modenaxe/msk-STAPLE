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

function CS = MSK_femur_Kai2014(Femur, DistFem)

% if this is an entire femur then cut it in two parts
% but keep track of all geometries
if ~exist('DistFem','var')
      [ProxFem, DistFem] = cutLongBoneMesh(Femur);
else
    % join two parts in one triangulation
    Femur = TriUnite(DistFem, ProxFem);
end

%-------------------------------------
% Z0: points upwards (inertial axis) 
% Y0: points medio-lat (from OT and Z0 in findFemoralHead.m)
% X0: used only in Kai2014
%-------------------------------------

% Get eigen vectors V_all of the Femur 3D geometry and volumetric center
[ V_all, CenterVol ] = TriInertiaPpties(Femur);

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
[center1,radius1] = sphereFit(FC_Med_Pts1);
[center2,radius2] = sphereFit(FC_Lat_Pts2);

% define the reference system (NB: this is different from the other ref
% systems - mechanical axis just defines the plane, not an axis)
CenterKneeKai = 0.5*(center1+center2);
Zml = normalizeV(center2-center1);
Xap = normalizeV(cross((CS.CenterFH_Kai- CenterKneeKai), Zml));
Ydp = cross(Zml,Xap);

% store axes in structure
CS.Center1 = center1;
CS.Center2 = center2;
CS.Radius1 = radius1;
CS.Radius2 = radius2;
CS.Origin  = CenterKneeKai;
CS.X       = Xap;
CS.Y       = Ydp;
CS.Z       = Zml;
CS.V       = [Xap Ydp Zml];

end


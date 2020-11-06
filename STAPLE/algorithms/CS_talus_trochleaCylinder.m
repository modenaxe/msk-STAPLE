% NOTE: uses axis computed in the subtalar analysis
function [CS, TalTrochAS] = CS_talus_trochleaCylinder(Talus, side, CS, alt_TlNeck_start, alt_TlTib_start, CoeffMorpho)

% get sign correspondent to body side
[sign_side, ~] = bodySide2Sign(side);

debug_plots = 0;

X0 = CS.X0;
Y0 = CS.Y0;
Z0 = CS.Z0;
D = CS.D;
CenterVol = CS.CenterVol;

%% 5. Identification of the ankle joint cylinder
% 5.1 Get a new CS from the subaxis 
X1 = CS.X1;
Z1 = CS.Z1;
Y1 = CS.Y1;

% 5.2 Identify the 'articular surfaces' of the ankle joint
% Get mean curvature of the Talus
[Cmean, Cgaussian, ~, ~, k1, k2] = TriCurvature(Talus,false);
maxAbsCurv =  max(abs(k1), abs(k2));

TlTrcASNodesOK0 =  find(maxAbsCurv<quantile(maxAbsCurv,0.5) & ...
    rad2deg(acos(Talus.vertexNormal*Z0))<60 & ...
    rad2deg(acos(Talus.vertexNormal*Y0))>60 &...% this was Y1
    Talus.Points*X0 < alt_TlNeck_start);

TlTrcASNodesOK1 =  find(maxAbsCurv<quantile(maxAbsCurv,0.5) & ...
    rad2deg(acos(Talus.vertexNormal*Z0))<60 & ...% this was Z1
    rad2deg(acos(Talus.vertexNormal*Y0))>60 &...% this was Y1
    Talus.Points*X0 < alt_TlNeck_start);

TlTrcASNodesOK = unique([TlTrcASNodesOK0;TlTrcASNodesOK1],'rows');
TlTrcAS0 = TriReduceMesh(Talus,[],double(TlTrcASNodesOK));

% Keep largest connected region and smooth results
TlTrcAS0 = TriCloseMesh(Talus,TlTrcAS0,1*CoeffMorpho);
TlTrcAS0 = TriKeepLargestPatch( TlTrcAS0 );
TlTrcAS0 = TriErodeMesh(TlTrcAS0,2*CoeffMorpho);
TlTrcAS0 = TriKeepLargestPatch( TlTrcAS0 );
TlTrcAS0 = TriCloseMesh(Talus,TlTrcAS0,3*CoeffMorpho);
TlTrcAS0 = TriDilateMesh(Talus,TlTrcAS0,2*CoeffMorpho);

% 5.3 Get the first cylinder 
% Fit a sphere to a get an initial guess at the radius and a point on the
% axis
[Center_TlTrc_0,Radius_TlTrc_0] = sphereFit(TlTrcAS0.incenter) ;
[x0n, an, rn, d] = lscylinder( TlTrcAS0.incenter, Center_TlTrc_0', Y0,...%this was Y1
                            Radius_TlTrc_0, 0.001, 0.001);
ankleAxis =  normalizeV( an );

% checking Z0
if debug_plots == 1
    figure
    quickPlotTriang(Talus); hold on
    quickPlotTriang(TlTrcAS0, 'm')
    T.X=X0; T.Y=Y0; T.Z=Z0;T.Origin=CenterVol;
    quickPlotRefSystem(T)
end

% T1 is much more skewed
if debug_plots == 1
    figure
    quickPlotTriang(Talus); hold on
    quickPlotTriang(TlTrcAS0, 'g')
    T.X=X1; T.Y=Y1; T.Z=Z1;T.Origin=CenterVol;
    quickPlotRefSystem(T)
end

% 5.4 Refine the articular surface 
% Remove elements that are too for from from initial cylinder fit
%   more than 5% of radius inside or more than 10% outside
% Also remove elements that are too posterior
TlTrcASElmtsOK =  find( d > -0.05*rn &...% cond1
                        abs(d) < 0.1*rn &... % cond2
                        TlTrcAS0.incenter*X0 > alt_TlTib_start);% cond3
TlTrcAS1 = TriReduceMesh(TlTrcAS0, TlTrcASElmtsOK);
% TlTrcAS1 = TriCloseMesh(TlTrcAS0, TlTrcAS1, 3);
TlTrcAS1 = TriKeepLargestPatch( TlTrcAS1 );

% final articular surface for tibial throclea (output for plotting)
TalTrochAS = TlTrcAS1 ;

% fitting a cylinder
[x0n, an, rn] = lscylinder( TlTrcAS1.incenter, x0n, ankleAxis,...
                            rn, 0.001, 0.001);
                        
% ankle axis
ankleAxis =  normalizeV(an);

% align Z2 with -Y1, which is Z in ISB conventions (see debug plot)
CS.Z2 = normalizeV(sign(-Y1'*ankleAxis)*ankleAxis)*sign_side; % right: lateral, left: medial
CS.Y2 = normalizeV(cross(CS.Z2, X0));
CS.X2 = normalizeV(cross(CS.Y2, CS.Z2));

% store ankle info (NB: only CS.V is needed for plotting and joints)
CS.V_ankle        = [CS.X2 CS.Y2 CS.Z2];
CS.ankle_cyl_radius = rn;
CS.ankle_cyl_centre = x0n;% this could be the middle point of the cyl
CS.ankle_cyl_axis   = ankleAxis;

end
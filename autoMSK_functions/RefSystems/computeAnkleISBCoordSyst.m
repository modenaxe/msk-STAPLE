function CS = computeAnkleISBCoordSyst(Talus)


debug_plot = 1;

% structure to store ref system info
CS = computeSubtalarISBCoordSyst(Talus);

[ V_all, CenterVol, InertiaMatrix, D ] = TriInertiaPpties( Talus );
X0 = V_all(:,1); 
[Z0,Y0] = fitQuadriTalus(Talus, V_all, 1);

%=========== THIS WILL BE A FUNCTION ===============
slice_thickness = 0.3;
Alt =  min(Talus.Points*X0)+0.3 : slice_thickness : max(Talus.Points*X0)-0.3;
Area = zeros(size(Alt));
i=0;
for d = -Alt
    i = i + 1;
    [ ~ , Area(i), ~ ] = TriPlanIntersect( Talus, X0 , d );
end
%====================================================
[or, alt_TlNvc_start, alt_TlNeck_start, alt_TlTib_start] = ...
                                                    FitCSATalus(Alt, Area);

% Change X0 orientation if necessary ( or = +/- 1 )
X0 = or*X0;
Y0 = or*Y0;
%% 5. Identification of the ankle joint cylinder
% 5.1 Get a new CS from the subaxis 
X1 = CS.SubTal_axis;
Z1 = normalizeV(cross(X1,Y0));
Y1 = cross(Z1,X1);

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
TlTrcAS0 = TriCloseMesh(Talus,TlTrcAS0,1);
TlTrcAS0 = TriKeepLargestPatch( TlTrcAS0 );
TlTrcAS0 = TriErodeMesh(TlTrcAS0,2);
TlTrcAS0 = TriKeepLargestPatch( TlTrcAS0 );
TlTrcAS0 = TriCloseMesh(Talus,TlTrcAS0,3);
TlTrcAS0 = TriDilateMesh(Talus,TlTrcAS0,2);

% 5.3 Get the first cylinder 
% Fit a sphere to a get an initial guess at the radius and a point on the
% axis
[Center_TlTrc_0,Radius_TlTrc_0] = sphereFit(TlTrcAS0.incenter) ;
[x0n, an, rn, d] = lscylinder( TlTrcAS0.incenter, Center_TlTrc_0', Y0,...%this was Y1
                            Radius_TlTrc_0, 0.001, 0.001);
Y2 =  normalizeV( an );

quickPlotTriang(Talus); hold on
quickPlotTriang(TlTrcAS0, 'm')
T.X=X0; T.Y=Y0; T.Z=Z0;T.Origin=CenterVol;
quickPlotRefSystem(T)

% T1 is much more skewed
figure
quickPlotTriang(Talus); hold on
quickPlotTriang(TlTrcAS0, 'g')
T.X=X1; T.Y=Y1; T.Z=Z1;T.Origin=CenterVol;
quickPlotRefSystem(T)
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


% final articular surface for tibial throclea
TlTrcAS = TlTrcAS1 ;

% fitting a cylinder
[x0n, an, rn] = lscylinder( TlTrcAS1.incenter, x0n, Y2,...
                            rn, 0.001, 0.001);
                        
% ankle axis
Y2 =  normalizeV( an );

% align with -Y1, which is Z for ISB (see debug plot
Z3 = normalizeV(sign(-Y1'*Y2)*Y2);

% NB X0 SHOULD BE X from foot sole!!
Y3 = normalizeV(cross(Z3, X0));
X3 = cross(Y3, Z3);


% store ankle info
CS.cyl_rad    = rn;
CS.cyl_centre = x0n;
CS.cyl_axis   = Y2;
CS.Origin = x0n; % this could be the middle point of the cyl
CS.X = X3;
CS.Y = Y3;
CS.Z = Z3;
CS.V = [X3 Y3 Z3];
if debug_plot
    % 5.5 Plot the results
    figure()
    trisurf(Talus,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',.6,'edgecolor','none');
    hold on
    axis equal
    
    % handle lighting of objects
    light('Position',CenterVol' + 500*Y0' + 500*X0','Style','local')
    light('Position',CenterVol' + 500*Y0' - 500*X0','Style','local')
    light('Position',CenterVol' - 500*Y0' + 500*X0' - 500*Z0','Style','local')
    light('Position',CenterVol' - 500*Y0' - 500*X0' + 500*Z0','Style','local')
    lighting gouraud
    
    % Remove grid
    grid off
    
    %Plot the Axis & Volumic center
    
    % axis based on subtalar estimation
%     plotDot( CenterVol', 'k', 2 )
%     plotArrow( X1, 1, CenterVol, 40, 1, 'r')
%     plotArrow( Y1, 1, CenterVol, 40*D(1,1)/D(2,2), 1, 'g')
%     plotArrow( Z1, 1, CenterVol, 40*D(1,1)/D(3,3), 1, 'b')
    
    % orginal inertial + quad axes
    plotArrow( X0, 1, CenterVol, 40, 1, 'r')
    plotArrow( Y0, 1, CenterVol, 40*D(1,1)/D(2,2), 1, 'g')
    plotArrow( Z0, 1, CenterVol, 40*D(1,1)/D(3,3), 1, 'b')
    
    %Plot the  talar trochlea articular surface
    % trisurf(TlTrcAS0,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
    trisurf(TlTrcAS,'Facecolor','k','FaceAlpha',1,'edgecolor','none');
    
    %Plot the Cylinder and its axis
    plotCylinder( Y2, rn, x0n, 40, 0.4, 'r')
    plotArrow( Y2, 1, x0n, 40, 1, 'r')
    plotDot( x0n', 'r', 2 )
end
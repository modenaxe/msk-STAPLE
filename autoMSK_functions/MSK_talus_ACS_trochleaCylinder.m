function TalocruralCS = MSK_talus_ACS_trochleaCylinder(Talus, CS, alt_TlNeck_start, alt_TlTib_start, debug_plot)

TalocruralCS = struct;

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

% % checking Z0
% quickPlotTriang(Talus); hold on
% quickPlotTriang(TlTrcAS0, 'm')
% T.X=X0; T.Y=Y0; T.Z=Z0;T.Origin=CenterVol;
% quickPlotRefSystem(T)

% % T1 is much more skewed
% figure
% quickPlotTriang(Talus); hold on
% quickPlotTriang(TlTrcAS0, 'g')
% T.X=X1; T.Y=Y1; T.Z=Z1;T.Origin=CenterVol;
% quickPlotRefSystem(T)

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
TalocruralCS.cyl_rad    = rn;
TalocruralCS.cyl_centre = x0n;
TalocruralCS.cyl_axis   = Y2;
TalocruralCS.Origin = x0n; % this could be the middle point of the cyl

% reference system for talocrural joint
TalocruralCS.X = X3;
TalocruralCS.Y = Y3;
TalocruralCS.Z = Z3;
TalocruralCS.V_ankle = [X3 Y3 Z3];

if debug_plot
    % 5.5 Plot the results
%     figure()
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
    plotArrow( X3, 1, CenterVol, 40, 1, 'r')
    plotArrow( Y3, 1, CenterVol, 40*D(1,1)/D(2,2), 1, 'g')
    plotArrow( Z3, 1, CenterVol, 40*D(1,1)/D(3,3), 1, 'b')
    plotDot( x0n', 'k', 2 )
    
    %Plot the  talar trochlea articular surface
    % trisurf(TlTrcAS0,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
    trisurf(TlTrcAS,'Facecolor','k','FaceAlpha',1,'edgecolor','none');
    
    %Plot the Cylinder and its axis
    plotCylinder( Y2, rn, x0n, 40, 0.4, 'r')
    plotArrow( Y2, 1, x0n, 40, 1, 'r')
    plotDot( x0n', 'r', 2 )
    
    axis off
end

end
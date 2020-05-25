function [ PtsCondyle_end, PtsKeptID ] = PtsOnCondylesFemur( PtsCondyle_0 , Pts_Epiphysis, CutAngle, InSetRatio, ellip_dilat_fact )
%PtsOnCondylesF : Find points on condyles from a first 2D ellipse Fit on
%points identifies as certain to be on the condyle [PtsCondyle_0] and get
% points in +- 5 % intervall of the fitted ellipse
% Points must be expressed in Coordinate system where Y has been identified
% as a good initial candidates for ML axis

Elps = fit_ellipse( PtsCondyle_0(:,3),PtsCondyle_0(:,1));

Ux = [cos(Elps.phi);-sin(Elps.phi)];
Uy = [sin(Elps.phi);cos(Elps.phi)];

% CutDistance = Elps.a/sqrt(tan(deg2rad(CutAngle))^(-2) + (Elps.a/Elps.b)^2);

R = [ Ux Uy ];

% the ellipse
theta_r         = linspace(0,2*pi,36); %linspace(0,2*pi);
ellipse_x_r     = Elps.X0 + InSetRatio*Elps.a*cos( theta_r );
ellipse_y_r     = Elps.Y0 + InSetRatio*Elps.b*sin( theta_r );
rotated_ellipse = transpose(R * [ellipse_x_r;ellipse_y_r]);

IN = inpolygon(Pts_Epiphysis(:,3),Pts_Epiphysis(:,1),rotated_ellipse(:,1),rotated_ellipse(:,2));
OUT_Elps = ~IN;


K = convhull(PtsCondyle_0(:,[3 1]));
% CHull = triangulation(K,PtsCondyle_0);
% Elmts2D = fixNormals( CHull.Points, CHull.ConnectivityList );
% CHull = triangulation(Elmts2D,CHull.Points);

% PtsCondyle_0_Expanded = CHull.Points + CHull.vertexNormal*0.03*(Elps.a+Elps.b);

% PtsCondyle_0_Expanded = [PtsCondyle_0(K,3)+0.03*(PtsCondyle_0(K,3)-Elps.X0_in),...
%     PtsCondyle_0(K,1)+0.03*(PtsCondyle_0(K,1)-Elps.Y0_in)];

% ConvexHull dilated by 2.5% relative to the ellipse center distance
% ellip_dilat_fact = 0.025;
IN_CH = inpolygon(Pts_Epiphysis(:,3),Pts_Epiphysis(:,1),...
    PtsCondyle_0(K,3)+ellip_dilat_fact*(PtsCondyle_0(K,3)-Elps.X0_in),...
    PtsCondyle_0(K,1)+ellip_dilat_fact*(PtsCondyle_0(K,1)-Elps.Y0_in));

% find furthest point
SqrdDist2Center = (bsxfun(@minus,Pts_Epiphysis(:,[3 1]), [Elps.X0_in Elps.Y0_in])*Ux).^2 + ...
    (bsxfun(@minus,Pts_Epiphysis(:,[3 1]), [Elps.X0_in Elps.Y0_in])*Uy).^2;

[~,I] = max(SqrdDist2Center);

PtsinEllipseCF = bsxfun(@minus,Pts_Epiphysis(:,[3 1]), [Elps.X0_in Elps.Y0_in]);
UEllipseCF = PtsinEllipseCF./repmat(sqrt(sum(PtsinEllipseCF.^2,2)),1,2);

if (Pts_Epiphysis(I,[3 1])-[Elps.X0_in Elps.Y0_in])*Uy<0
    
    EXT_Posterior = UEllipseCF*Uy < -cos(deg2rad(90 - CutAngle)) |...
        (UEllipseCF*Uy < 0 & UEllipseCF*Ux > 0);
        
else
    EXT_Posterior = UEllipseCF*Uy > cos(deg2rad(90 - CutAngle)) |...
        (UEllipseCF*Uy > 0 & UEllipseCF*Ux > 0);
end


% Points must be Outsided of the reduced ellipse and inside the Convexhull
I_kept = OUT_Elps & IN_CH & ~EXT_Posterior;
% logical(OUT_Elps.*IN_CH); %(IN_CH.*0+1)

% outputs
PtsCondyle_end = Pts_Epiphysis(I_kept,:);
PtsKeptID = find(I_kept);

%% plotting
% line calc
ver_line        = [ [Elps.X0 Elps.X0]; Elps.Y0+Elps.b*[-1 1] ];
horz_line       = [ Elps.X0+Elps.a*[-1 1]; [Elps.Y0 Elps.Y0] ];
new_ver_line    = R*ver_line;
new_horz_line   = R*horz_line;

% figure()
% plot(Pts_Epiphysis(:,3),Pts_Epiphysis(:,1),'g.')
% hold on
% axis equal
% % plot(Pts_Epiphysis(OUT_Elps,3),Pts_Epiphysis(OUT_Elps,1),'c*')
% plot( rotated_ellipse(:,1),rotated_ellipse(:,2),'r' );
% plot(Pts_Epiphysis(I_kept,3),Pts_Epiphysis(I_kept,1),'rs')
% plot( new_ver_line(1,:),new_ver_line(2,:),'r' );
% plot( new_horz_line(1,:),new_horz_line(2,:),'r' );
% quiver(Elps.X0_in,Elps.Y0_in,50*cos(-Elps.phi),50*sin(-Elps.phi));
% quiver(Elps.X0_in,Elps.Y0_in,50*sin(Elps.phi),50*cos(Elps.phi));
% plot(mean(Pts_Epiphysis(:,3)),mean(Pts_Epiphysis(:,1)),'ks')
% plot(Pts_Epiphysis(I,3),Pts_Epiphysis(I,1),'ks')
% plot(PtsCondyle_0(K,3),PtsCondyle_0(K,1),'k-')
% plot(PtsCondyle_0(:,3),PtsCondyle_0(:,1),'kd')
% plot(PtsCondyle_0(:,3),PtsCondyle_0(:,1),'k*')
end


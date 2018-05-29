function [ Results ] = TibiaMirandaFun( name , oprtr , RATM_on, Results  )
%TibiaMirandaFun Function that build an ACS using the Miranda et Al. 2010 methods
%   Detailed explanation goes here

% Read proximal tibia model mesh
XYZELMTS = py.txt2mtlb.read_meshGMSH(strcat('\Repere3DData\',name,'_TIB',oprtr,'05.msh'));
Pts2D = [cell2mat(cell(XYZELMTS{'X'}))' cell2mat(cell(XYZELMTS{'Y'}))' cell2mat(cell(XYZELMTS{'Z'}))'];
Elmts2D = double([cell2mat(cell(XYZELMTS{'N1'}))' cell2mat(cell(XYZELMTS{'N2'}))' cell2mat(cell(XYZELMTS{'N3'}))']);
if RATM_on
    %Load rATM applied to this Tibia for other algorithms
    Vatm = Results.RATM.R;
    Tatm = Results.RATM.T;
	
	% Update Proximal Tibia vertices location with rATM
    Pts2D = bsxfun(@plus,Pts2D*Vatm , Tatm');
end

% Verify that normal are outward-pointing and fix if not
Elmts2D = fixNormals( Pts2D, Elmts2D );
ProxTib = triangulation(Elmts2D,Pts2D);

% Compute the inertia tensor and the principal inertia axis
[ InertiaMatrix, Center ] = InertiaProperties( ProxTib.Points, ProxTib.ConnectivityList );
[V_all,~] = eig(InertiaMatrix);
Center0 = Center;

Z0 = V_all(:,1);

%% Find the Altitutde of the max Cross Section Area (CSA) along the 1st principal inertia axis

% First step
Alt0 = linspace( min(ProxTib.Points*Z0)+0.1 ,max(ProxTib.Points*Z0)-0.1, 50);
Area=[];
for d = Alt0
    [ ~ , Area(end+1), ~ ] = TriPlanIntersect(ProxTib.Points, ProxTib.ConnectivityList, Z0 , d );
end

[~,ImaxArea] = max(Area);
Loc1_0 = Alt0(ImaxArea);

steps = range(Alt0)/length(Alt0);

% The altitude of the max CSA is refined with smaller steps
Alt = linspace( Loc1_0-1.1*steps , Loc1_0+1.1*steps, 50);
Area=[];
for d = Alt
    [ ~ , Area(end+1), ~ ] = TriPlanIntersect(ProxTib.Points, ProxTib.ConnectivityList, Z0 , d );
end

[~,ImaxArea] = max(Area);
Loc1 = Alt(ImaxArea);

%% Isolate the tibial plateau
ElmtsTP = find(ProxTib.incenter*Z0>Loc1);
TPTib = TriReduceMesh( ProxTib, ElmtsTP ); % Tibial Plateau
TPTib = TriFillPlanarHoles(TPTib);

% Compute the Principal inertia axis of the isolated plateau
[ TPTib_InertiaMatrix, TPTib_Center ] = InertiaProperties( TPTib.Points, TPTib.ConnectivityList );
[V_TPTib,~] = eig(TPTib_InertiaMatrix);


% Define the Anatomical Coordinate System
Results.Miranda.Yend = V_TPTib(:,1);
Results.Miranda.Xend = V_TPTib(:,2);
Results.Miranda.Zend = V_TPTib(:,3);
Results.Miranda.CenterKnee = TPTib_Center';

end


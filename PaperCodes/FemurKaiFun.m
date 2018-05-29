function [ Results ] = FemurKaiFun( name , oprtr , RATM_on, Results  )
%FemurKaiFun Implementation of the Kai et Al. 2014 algorithm to build an
%ACS on the femur

addpath(strcat(pwd,'\SubFonctions'));
addpath(strcat(pwd,'\SubFonctions\SurFit'));

XYZELMTS = py.txt2mtlb.read_meshGMSH(strcat('\Repere3DData\',name,'_FEM',oprtr,'05.msh'));
Pts2D = [cell2mat(cell(XYZELMTS{'X'}))' cell2mat(cell(XYZELMTS{'Y'}))' cell2mat(cell(XYZELMTS{'Z'}))'];
Elmts2D = double([cell2mat(cell(XYZELMTS{'N1'}))' cell2mat(cell(XYZELMTS{'N2'}))' cell2mat(cell(XYZELMTS{'N3'}))']);
if RATM_on
    %Load rATM applied to this femur for other algorithms
    Vatm = Results.RATM.R;
    Tatm = Results.RATM.T;
	
	% Update Distal Femur vertices location with rATM
    Pts2D = bsxfun(@plus,Pts2D*Vatm , Tatm');
end

% Verify that normal are outward-pointing and fix if not
Elmts2D = fixNormals( Pts2D, Elmts2D );
DistFem = triangulation(Elmts2D,Pts2D);

%Read distal Tibia
XYZELMTS = py.txt2mtlb.read_meshGMSH(strcat('\Repere3DData\',name,'_HAN',oprtr,'05.msh'));
Pts2D = [cell2mat(cell(XYZELMTS{'X'}))' cell2mat(cell(XYZELMTS{'Y'}))' cell2mat(cell(XYZELMTS{'Z'}))'];
Elmts2D = double([cell2mat(cell(XYZELMTS{'N1'}))' cell2mat(cell(XYZELMTS{'N2'}))' cell2mat(cell(XYZELMTS{'N3'}))']);
if RATM_on
    % Update Proximal Femur vertices location with rATM
    Pts2D = bsxfun(@plus,Pts2D*Vatm , Tatm');
end

% Verify that normal are outward-pointing and fix if not
Elmts2D = fixNormals( Pts2D, Elmts2D );
ProxFem = triangulation(Elmts2D,Pts2D);

% Unite both distal and proximal tibia mesh
Femur = triangulationUnite(DistFem,ProxFem);

[ InertiaMatrix, Center ] = InertiaProperties( Femur.Points, Femur.ConnectivityList );
[V_all,~] = eig(InertiaMatrix);
Center0 = Center;


% Initial estimate of the Inf-Sup axis Z0 - Check that the distal tibia
% is 'below': the proximal tibia, invert Z0 direction otherwise;
Z0 = V_all(:,1);
Z0 = sign((mean(ProxFem.Points)-mean(DistFem.Points))*Z0)*Z0;


%% GET the femoral head center

% Find the most proximal point
[~ , I_Top_FH] = max( ProxFem.Points*Z0 );
MostProxPoint = ProxFem.Points(I_Top_FH,:);

% Get the oultine of all the proximal
Nbr_of_curves  = 1;
Ok_FH_Pts = [];
d = MostProxPoint*Z0 - 0.25;
while Nbr_of_curves == 1
    [ Curves , ~, ~ ] = TriPlanIntersect(ProxFem.Points, ProxFem.ConnectivityList, Z0 , d );
    Nbr_of_curves = length(Curves);
    if Nbr_of_curves ==1
        Ok_FH_Pts = [Ok_FH_Pts;Curves.Pts];
    end
    d = d - 1;
end

while Nbr_of_curves > 1
    Centroid = [];
    Dist2MostProxPoint = [];
    for i = 1:Nbr_of_curves
        Centroid(i,:) = mean(Curves(i).Pts);
        Dist2MostProxPoint(i) = norm(MostProxPoint-Centroid(i,:));
    end
    
    [~,IcurveMed] = min(Dist2MostProxPoint);
    Ok_FH_Pts = [Ok_FH_Pts;Curves(IcurveMed).Pts];
    
    [ Curves , ~, ~ ] = TriPlanIntersect(ProxFem.Points, ProxFem.ConnectivityList, Z0 , d );
    Nbr_of_curves = length(Curves);
    d = d - 1;
end


[CenterFH,Radius] = sphereFit(Ok_FH_Pts);

Results.CenterFH_Kai = CenterFH ;
Results.RadiusFH_Kai = Radius ;

%% GET the Posterior condyles spheres

% Test in the first direction
X0 = V_all(:,3);

[~ , I_Post_FC] = max( DistFem.Points*X0 );
MostPostPoint = DistFem.Points(I_Post_FC,:);

Nbr_of_curves  = 2;
Ok_FC_Pts1 = [];
Ok_FC_Pts2 = [];
d = MostPostPoint*X0 - 0.25;
StillStart = 1;

while Nbr_of_curves == 2;
    
    [ Curves , ~, ~ ] = TriPlanIntersect(DistFem.Points, DistFem.ConnectivityList, X0 , d );
    Nbr_of_curves = length(Curves);
    Nbr_of_curves0 = length(Curves);
    
    %
    Centroid = [];
    Dist2MostPostPoint = [];
    
    for i = 1:Nbr_of_curves
        Centroid(i,:) = mean(Curves(i).Pts);
        Dist2MostPostPoint(i) = norm(MostPostPoint-Centroid(i,:));
    end
    
    
    if Nbr_of_curves == 1 && StillStart == 1
        StillStart = 1;
        Nbr_of_curves = 2;
    elseif Nbr_of_curves > 1 && StillStart == 1
        StillStart = 0;
    end
    
    if StillStart == 1
        Ok_FC_Pts1 = [Ok_FC_Pts1;Curves.Pts];
    elseif Nbr_of_curves0 == 2 && StillStart == 0
        [~,IcurvePost1] = min(Dist2MostPostPoint);
        Ok_FC_Pts1 = [Ok_FC_Pts1;Curves(IcurvePost1).Pts];
        Ok_FC_Pts2 = [Ok_FC_Pts2;Curves(3-IcurvePost1).Pts];
    end
    
    d = d - 1;
end

if isempty(Ok_FC_Pts1) || isempty(Ok_FC_Pts2)
    [CenterFC01,Radius01] = deal(zeros(1,3),10e3);
    [CenterFC02,Radius02] = deal(zeros(1,3),10e3);
else
    [CenterFC01,Radius01] = sphereFit(Ok_FC_Pts1);
    [CenterFC02,Radius02] = sphereFit(Ok_FC_Pts2);
end



% Test in the 2nd direction
X0 = -V_all(:,3);

[~ , I_Post_FC] = max( DistFem.Points*X0 );
MostPostPoint = DistFem.Points(I_Post_FC,:);

Nbr_of_curves  = 2;
Ok_FC_Pts1 = [];
Ok_FC_Pts2 = [];
d = MostPostPoint*X0 - 0.25;
StillStart = 1;

while Nbr_of_curves == 2;
    
    [ Curves , ~, ~ ] = TriPlanIntersect(DistFem.Points, DistFem.ConnectivityList, X0 , d );
    Nbr_of_curves = length(Curves);
    Nbr_of_curves0 = length(Curves);
    
    %
    Centroid = [];
    Dist2MostPostPoint = [];
    for i = 1:Nbr_of_curves
        Centroid(i,:) = mean(Curves(i).Pts);
        Dist2MostPostPoint(i) = norm(MostPostPoint-Centroid(i,:));
    end
        
    
    if Nbr_of_curves == 1 && StillStart == 1
        StillStart = 1;
        Nbr_of_curves = 2;
    elseif Nbr_of_curves > 1 && StillStart == 1
        StillStart = 0;
    end
    
    if StillStart == 1
        Ok_FC_Pts1 = [Ok_FC_Pts1;Curves.Pts];
    elseif Nbr_of_curves0 == 2 && StillStart == 0
        [~,IcurvePost1] = min(Dist2MostPostPoint);
        Ok_FC_Pts1 = [Ok_FC_Pts1;Curves(IcurvePost1).Pts];
        Ok_FC_Pts2 = [Ok_FC_Pts2;Curves(3-IcurvePost1).Pts];
    end
    
    d = d - 1;
end

if isempty(Ok_FC_Pts1) || isempty(Ok_FC_Pts2)
    [CenterFC11,Radius11] = deal(zeros(1,3),10e3);
    [CenterFC12,Radius12] = deal(zeros(1,3),10e3);
else
    [CenterFC11,Radius11] = sphereFit(Ok_FC_Pts1);
    [CenterFC12,Radius12] = sphereFit(Ok_FC_Pts2);
end


if abs((CenterFC11-CenterFC12)*V_all(:,2)) > abs((CenterFC01-CenterFC02)*V_all(:,2)) && abs((Radius11-Radius12)/Radius11) < 1.20
    CenterFC1 = CenterFC11; Radius1 = Radius11;
    CenterFC2 = CenterFC12; Radius2 = Radius12;
    
elseif abs((CenterFC11-CenterFC12)*V_all(:,2)) < abs((CenterFC01-CenterFC02)*V_all(:,2)) && abs((Radius01-Radius02)/Radius01) < 1.20
    CenterFC1 = CenterFC01; Radius1 = Radius01;
    CenterFC2 = CenterFC02; Radius2 = Radius02;
    
end


Yml = CenterFC2-CenterFC1; Yml = Yml'/norm(Yml);
Xap = cross(Yml,( CenterFC2 - CenterFH)'); Xap = Xap/norm(Xap);
Zdp = cross(Xap,Yml);

Results.Xend_Kai = Xap;
Results.Yend_Kai = Yml;
Results.Zend_Kai = Zdp;
Results.CenterKneeKai = 0.5*CenterFC1+0.5*CenterFC2;


end



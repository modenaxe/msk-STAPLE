function [CSs, Curves] = findFemoralHead_Kai2014(ProxFem, CSs)
% Find the most proximal point
[~ , I_Top_FH] = max( ProxFem.Points*CSs.Z0 );
MostProxPoint = ProxFem.Points(I_Top_FH,:);

% Get the oultine of all the proximal
Nbr_of_curves  = 1;
Ok_FH_Pts = [];
d = MostProxPoint*CSs.Z0 - 0.25;
while Nbr_of_curves == 1
    [ Curves , ~, ~ ] = TriPlanIntersect(ProxFem, CSs.Z0 , d );
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
    
    [ Curves , ~, ~ ] = TriPlanIntersect(ProxFem, CSs.Z0 , d );
    Nbr_of_curves = length(Curves);
    d = d - 1;
end


[CenterFH, Radius] = sphereFit(Ok_FH_Pts);

CSs.CenterFH_Kai = CenterFH ;
CSs.RadiusFH_Kai = Radius ;

end
function [CSs, Curves] = findFemoralHead_Kai2014(ProxFem, CSs)

% TODO needs sections plots
% TODO understand axis
% TODO: something wrong with the second while loop
corr_dir = -1;
disp('Computing Femoral Head Centre (Kai et al. 2014)...')

% Find the most proximal point
[~ , I_Top_FH] = max( ProxFem.Points*CSs.Z0 );
MostProxPoint = ProxFem.Points(I_Top_FH,:);

%================
figure
trisurf(ProxFem.ConnectivityList, ProxFem.Points(:,1), ProxFem.Points(:,2), ProxFem.Points(:,3),'Facecolor','m','Edgecolor','none');
light; lighting phong; % light
hold on, axis equal
plot3(MostProxPoint(:,1), MostProxPoint(:,2), MostProxPoint(:,3),'g*', 'LineWidth', 3.0);
%================

% Get the oultine of all the proximal
Nbr_of_curves  = 1;
Ok_FH_Pts = [];
d = MostProxPoint*CSs.Z0 - 0.25;
while Nbr_of_curves == 1
    [ Curves , ~, ~ ] = TriPlanIntersect(ProxFem, corr_dir*CSs.Z0 , d );
    Nbr_of_curves = length(Curves);
    if Nbr_of_curves ==1
        Ok_FH_Pts = [Ok_FH_Pts;Curves.Pts];
    end
    d = d - 1;
    
        % plot curves
    c_set = ['r', 'b'];
    if ~isempty(Curves)
        for c = 1:Nbr_of_curves
            plot3(Curves(c).Pts(:,1), Curves(c).Pts(:,2), Curves(c).Pts(:,3),'r'); hold on; axis equal
        end
    end
    
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
    
    [ Curves , ~, ~ ] = TriPlanIntersect(ProxFem, corr_dir*CSs.Z0 , d );
    Nbr_of_curves = length(Curves);
    d = d - 1;
    
        % plot curves
    c_set = 'm';%, 'g'];
    if ~isempty(Curves)
        for c = 1:Nbr_of_curves
            plot3(Curves(c).Pts(:,1), Curves(c).Pts(:,2), Curves(c).Pts(:,3),'b'); hold on; axis equal
        end
    end
end


[CenterFH, Radius] = sphereFit(Ok_FH_Pts);

disp('-----------------')
disp('Final  Estimation')
disp('-----------------')
disp(['Centre: ', num2str(CenterFH)]);
disp(['Radius: ', num2str(Radius)]);
disp('-----------------')

CSs.CenterFH_Kai = CenterFH ;
CSs.RadiusFH_Kai = Radius ;

end
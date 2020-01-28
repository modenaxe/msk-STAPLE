% used by KaiFemur
function [Ok_FC_Pts1, Ok_FC_Pts2] = sliceFemoralCondyles(DistFem, X0)

% X0 points backwards in GIBOK

% most posterior point
[~ , I_Post_FC] = max( DistFem.Points*-X0 );
MostPostPoint = DistFem.Points(I_Post_FC,:);

Nbr_of_curves  = 2;
Ok_FC_Pts1 = [];
Ok_FC_Pts2 = [];
d = MostPostPoint*-X0 - 0.25;
StillStart = 1;
count = 1;

%================
figure
trisurf(DistFem.ConnectivityList, DistFem.Points(:,1), DistFem.Points(:,2), DistFem.Points(:,3),'Facecolor','m','Edgecolor','none');
light; lighting phong; % light
hold on, axis equal
plot3(MostPostPoint(:,1), MostPostPoint(:,2), MostPostPoint(:,3),'g*', 'LineWidth', 3.0);
%================
keep_slicing = 1;
while Nbr_of_curves == 2
    % counting slices
    disp(['section #',num2str(count)])
    count = count+1;
    
    [ Curves , ~, ~ ] = TriPlanIntersect(DistFem, X0 , d );
    Nbr_of_curves = length(Curves);
    Nbr_of_curves0 = length(Curves);
    
    % plot curves
    c_set = ['b', 'r'];
    if ~isempty(Curves)
        for c = 1:Nbr_of_curves
            plot3(Curves(c).Pts(:,1), Curves(c).Pts(:,2), Curves(c).Pts(:,3),c_set(c)); hold on; axis equal
        end
    end

    %
    Centroid = [];
    Dist2MostPostPoint = [];
    
    for cn = 1:Nbr_of_curves
        Centroid(cn,:) = mean(Curves(cn).Pts);
        Dist2MostPostPoint(cn) = norm(MostPostPoint-Centroid(cn,:));
    end
    
    % slice starts with just one curve, until it slices two condyles
    % when there are two curves, the next time there is one is the end of
    % loop
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
    
    % slicing plane moved by 1 mm
    d = d - 1;
end

end
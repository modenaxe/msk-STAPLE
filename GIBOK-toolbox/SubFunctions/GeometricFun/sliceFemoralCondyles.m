% used by KaiFemur
% slice starts with just one curve, until it slices two condyles
% when there are two curves, the next time there is one is the end of
% loop
function [Ok_FC_Pts1, Ok_FC_Pts2] = sliceFemoralCondyles(DistFem, X0)

% X0 points backwards in GIBOK

% most posterior point
[~ , I_Post_FC] = max( DistFem.Points*-X0 );
MostPostPoint = DistFem.Points(I_Post_FC,:);

Ok_FC_Pts1 = [];
Ok_FC_Pts2 = [];
d = MostPostPoint*-X0 - 0.25;
count = 1;

%================
figure
trisurf(DistFem.ConnectivityList, DistFem.Points(:,1), DistFem.Points(:,2), DistFem.Points(:,3),'Facecolor','m','Edgecolor','none');
light; lighting phong; % light
hold on, axis equal
plot3(MostPostPoint(:,1), MostPostPoint(:,2), MostPostPoint(:,3),'g*', 'LineWidth', 3.0);
%================

keep_slicing = 1;
while keep_slicing

    [ Curves , ~, ~ ] = TriPlanIntersect(DistFem, X0 , d );
    Nbr_of_curves = length(Curves);
    
    % counting slices
    disp(['section #',num2str(count),': ', num2str(Nbr_of_curves),' curves.'])
    count = count+1;
    
    % plot curves
    c_set = ['r', 'b'];
    if ~isempty(Curves)
        for c = 1:Nbr_of_curves
            plot3(Curves(c).Pts(:,1), Curves(c).Pts(:,2), Curves(c).Pts(:,3)); hold on; axis equal
        end
    end

    % stop if just one curve is found after there has been a second profile
    if Nbr_of_curves == 1 && ~isempty(Ok_FC_Pts2)
        break
    else
        % next slicing plane moved by 1 mm
        d = d - 1;
    end
    
    % otherwise store slices
    if Nbr_of_curves == 1
        Ok_FC_Pts1 = [Ok_FC_Pts1; Curves.Pts];
    elseif Nbr_of_curves == 2
        % needs to identify which is the section near starting point
        % using distance from centroid for that
        Centroid = [];
        Dist2MostPostPoint = [];
        for cn = 1:Nbr_of_curves
            Centroid(cn,:) = mean(Curves(cn).Pts);
            Dist2MostPostPoint(cn) = norm(MostPostPoint-Centroid(cn,:));
        end
        % closest curve to Dist2MostPostPoint is the one that started as
        % single curve
        [~,IcurvePost1] = min(Dist2MostPostPoint);
        % store data accordingly
        Ok_FC_Pts1 = [Ok_FC_Pts1; Curves(IcurvePost1).Pts];
        Ok_FC_Pts2 = [Ok_FC_Pts2; Curves(3-IcurvePost1).Pts];
    end
end

end
% used by KaiFemur
% slice starts with just one curve, until it slices two condyles
% when there are two curves, the next time there is one is the end of
% loop
function [FC_Med_Pts, FC_Lat_Pts] = sliceFemoralCondyles(DistFem, X0)

% X0 points backwards in GIBOK

% most posterior point
[~ , I_Post_FC] = max( DistFem.Points*-X0 );
MostPostPoint = DistFem.Points(I_Post_FC,:);

FC_Med_Pts = [];
FC_Lat_Pts = [];
d = MostPostPoint*-X0 - 0.25;
count = 1;

%================
quickPlotTriang(DistFem, 'm', 1);
plot3(MostPostPoint(:,1), MostPostPoint(:,2), MostPostPoint(:,3),'g*', 'LineWidth', 3.0);
%================

keep_slicing = 1;
while keep_slicing

    [ Curves , Area, ~ ] = TriPlanIntersect(DistFem, X0 , d );
    Nbr_of_curves = length(Curves);
    
    % counting slices
    disp(['section #',num2str(count),': ', num2str(Nbr_of_curves),' curves.'])
    count = count+1;
    if Nbr_of_curves > 4
        disp('The condyle slicing is likely to be happening in the incorrect direction of the anterior-posterior axis.')
        disp('Inverting axis.')
        [FC_Med_Pts, FC_Lat_Pts] = sliceFemoralCondyles(DistFem, -X0);
        return
    end
    
    % stop if just one curve is found after there has been a second profile
    if Nbr_of_curves == 1 && ~isempty(FC_Lat_Pts)
        break
    else
        % next slicing plane moved by 1 mm
        d = d - 1;
    end
    
    % plot curves after break condition!
    c_set = ['r', 'b','k','k'];
    if ~isempty(Curves)
        for c = 1:Nbr_of_curves
            plot3(Curves(c).Pts(:,1), Curves(c).Pts(:,2), Curves(c).Pts(:,3), c_set(c)); hold on; axis equal
        end
    end
    
    % otherwise store slices
    if Nbr_of_curves == 1
        FC_Med_Pts = [FC_Med_Pts; Curves.Pts];
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
        FC_Med_Pts = [FC_Med_Pts; Curves(IcurvePost1).Pts];
        FC_Lat_Pts = [FC_Lat_Pts; Curves(3-IcurvePost1).Pts];
    end
end

end
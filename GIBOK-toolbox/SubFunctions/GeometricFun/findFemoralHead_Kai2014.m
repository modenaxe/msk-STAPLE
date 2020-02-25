function [CS, MostProxPoint] = findFemoralHead_Kai2014(ProxFem, CS)

% TODO: remove CS and output just fitting results could be an issue for GIBOK

sect_pts_limit = 15;

% plane normal must be negative (GIBOK)
corr_dir = -1;
disp('Computing Femoral Head Centre (Kai et al. 2014)...')

% Find the most proximal point
[~ , I_Top_FH] = max( ProxFem.Points*CS.Z0 );
MostProxPoint = ProxFem.Points(I_Top_FH,:);

up = CS.Z0;
anterior_dir = normalizeV(cross(MostProxPoint, up));
medial_dir = normalizeV(cross(anterior_dir, CS.Z0));
front = cross(MostProxPoint, up);

% debug plot
quickPlotTriang(ProxFem, 'm')
plot3(MostProxPoint(:,1), MostProxPoint(:,2), MostProxPoint(:,3),'g*', 'LineWidth', 3.0);

% Slice the femoral head starting from the top
Ok_FH_Pts = [];
Ok_FH_Pts_med = [];
d = MostProxPoint*CS.Z0 - 0.25;
keep_slicing = 1;
count = 1;
while keep_slicing
    
    % slice the proximal femur
    [ Curves , ~, ~ ] = TriPlanIntersect(ProxFem, corr_dir*CS.Z0 , d );
    Nbr_of_curves = length(Curves);
    
    % counting slices
    disp(['section #',num2str(count),': ', num2str(Nbr_of_curves),' curves.'])
    count = count+1;
    
    % plot curves
    c_set = ['r', 'b', 'm', 'b'];
    if ~isempty(Curves)
        for c = 1:Nbr_of_curves
            plot3(Curves(c).Pts(:,1), Curves(c).Pts(:,2), Curves(c).Pts(:,3),c_set(c)); hold on; axis equal
        end
    end
    
    % stop if there is one curve after Curves>2 have been processed
    if Nbr_of_curves == 1 && ~isempty(Ok_FH_Pts_med)
        break
    else
        d = d - 1;
    end
    
    % with just one curve save the slice: it's the femoral head
    if Nbr_of_curves == 1
        Ok_FH_Pts = [Ok_FH_Pts; Curves.Pts];
    
    % with more than one slice
    elseif Nbr_of_curves > 1
        % loop through the slices and store their areas
        for c = 1:Nbr_of_curves
            [areas(c), nr_points(c)] = deal(Curves(c).Area, numel(Curves(c).Pts));
            % first check the size of the areas. If too small it might be
            % spurious
        end
        % keep just the section with largest area.
        % the assumption is that the femoral head at this stage is larger
        % than the tip of the greater trocanter
        if Nbr_of_curves==2 && size(Curves(2).Pts,1)<sect_pts_limit
            disp('Slice recognized as artefact. Skipping it.')
            continue
        else
            [~, ind_max_area] = max(areas);
            Ok_FH_Pts_med = [Ok_FH_Pts_med; Curves(ind_max_area).Pts];
            clear areas
        end
        %-------------------------------
        % THIS ATTEMPT DID NOT WORK WELL
        %-------------------------------
        % if I assume centre of CT/MRI is always more medial than HJC
        % then medial points can be identified as closer to mid
        % it is however a weak solution - depends on medical images.
        %             ind_med_point = abs(Curves(i).Pts(:,1))<abs(MostProxPoint(1));
        %-------------------------------

        %-------------------------------
        % THIS ATTEMPT DID NOT WORK WELL
        %-------------------------------
        % More robust (?) to check if the cross product of
        % dot ( cross( (x_P-x_MostProx), Z0 ) , front ) > 0
        %             v_MostProx2Points = bsxfun(@minus,  Curves(i).Pts, MostProxPoint);
        % this condition is valid for right leg, left should be <0
        %             ind_med_point = (medial_dir'*bsxfun(@cross, v_MostProx2Points', up))>0;
        %             Ok_FH_Pts_med = [Ok_FH_Pts_med; Curves(i).Pts(ind_med_point,:)];
        %-------------------------------
    end
end

% assemble the points from one and two curves
fitPoints = [Ok_FH_Pts; Ok_FH_Pts_med];

% check by plotting
plot3(fitPoints(:,1), fitPoints(:,2), fitPoints(:,3),'g.');hold on


% fit sphere
% [CenterFH, Radius] = sphereFit(Ok_FH_Pts);
[CenterFH, Radius] = sphereFit(fitPoints);

plotSphere(CenterFH, Radius, 'b', 0.3)
% print
disp('-----------------')
disp('Final  Estimation')
disp('-----------------')
disp(['Centre: ', num2str(CenterFH)]);
disp(['Radius: ', num2str(Radius)]);
disp('-----------------')

CS.CenterFH_Kai = CenterFH ;
CS.RadiusFH_Kai = Radius ;

end

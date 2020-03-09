function [CS, MostProxPoint] = fitSphere2FemHead_Kai2014(ProxFem, CS)

% TODO: remove CS and output just fitting results could be an issue for GIBOK

sect_pts_limit = 15;

% plane normal must be negative (GIBOK)
corr_dir = -1;
disp('Computing Femoral Head Centre (Kai et al. 2014)...')

% Find the most proximal point
[~ , I_Top_FH] = max( ProxFem.Points*CS.Z0 );
MostProxPoint = ProxFem.Points(I_Top_FH,:);

% completing the inertia-based reference system
% the most proximal point on the fem head is medial wrt to the inertial
% axes. 
medial_to_z = MostProxPoint-CS.CenterVol';
CS.Y0 = normalizeV(cross(cross(CS.Z0, medial_to_z'),CS.Z0));
CS.X0 = cross(CS.Y0, CS.Z0);
CS.Origin  = CS.CenterVol;

% % unused - consider removing
% %==================================================
% anterior_dir = normalizeV(cross(MostProxPoint, up));
% medial_dir = normalizeV(cross(anterior_dir, CS.Z0));
% front = cross(MostProxPoint, up);
% %==================================================

% Slice the femoral head starting from the top
Ok_FH_Pts = [];
Ok_FH_Pts_med = [];
d = MostProxPoint*CS.Z0 - 0.25;
keep_slicing = 1;
count = 1;
max_area_so_far = 0;
while keep_slicing
    
    % slice the proximal femur
    [ Curves , ~, ~ ] = TriPlanIntersect(ProxFem, corr_dir*CS.Z0 , d );
    Nbr_of_curves = length(Curves);
    
    % counting slices
    disp(['section #',num2str(count),': ', num2str(Nbr_of_curves),' curves.'])
    count = count+1;
    
%     % plot curves
%     c_set = ['r', 'b', 'm', 'b'];
%     if ~isempty(Curves)
%         for c = 1:Nbr_of_curves
%             plot3(Curves(c).Pts(:,1), Curves(c).Pts(:,2), Curves(c).Pts(:,3),c_set(c)); hold on; axis equal
%         end
%     end
    
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
            [max_area, ind_max_area] = max(areas);
            Ok_FH_Pts_med = [Ok_FH_Pts_med; Curves(ind_max_area).Pts];
            clear areas
            if max_area>=max_area_so_far
                max_area_so_far=max_area;
            else
                disp('Reached femoral neck. End of slicing...')
                keep_slicing = 0;
                continue
            end
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

% NB: exclusind this check did NOT alter the results in most cases and
% offered more point for fitting
%-----------------
% keep only the points medial to MostProxPoint according to the reference
% system X0-Y0-Z0
ind_keep = (bsxfun(@minus, fitPoints, MostProxPoint)*CS.Y0) >0;
fitPoints = fitPoints(ind_keep,:);
%-----------------

% fit sphere
[CenterFH, Radius] = sphereFit(fitPoints);

% print
disp('-----------------')
disp('Final  Estimation')
disp('-----------------')
disp(['Centre: ', num2str(CenterFH)]);
disp(['Radius: ', num2str(Radius)]);
disp('-----------------')

CS.CenterFH_Kai = CenterFH ;
CS.RadiusFH_Kai = Radius ;

% debug plots
quickPlotTriang(ProxFem, [], 1); hold on;
plot3(MostProxPoint(1), MostProxPoint(2), MostProxPoint(3),'ro','LineWidth',4);
plot3(fitPoints(:,1), fitPoints(:,2), fitPoints(:,3),'g.');hold on
plotSphere(CenterFH, Radius, 'b', 0.4);
% temp ref system
plotDot(CS.CenterVol', 'k', 6);
quickPlotRefSystem(CS)

end

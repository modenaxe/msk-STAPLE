function [CSs, MostProxPoint] = findFemoralHead_Kai2014(ProxFem, CSs)

% TODO: remove CS and output just fitting results could be an issue for GIBOK

% plane normal must be negative (GIBOK)
corr_dir = -1;
disp('Computing Femoral Head Centre (Kai et al. 2014)...')

% Find the most proximal point
[~ , I_Top_FH] = max( ProxFem.Points*CSs.Z0 );

MostProxPoint = ProxFem.Points(I_Top_FH,:);

up = CSs.Z0;
anterior_dir = normalizeV(cross(MostProxPoint, up));
medial_dir = normalizeV(cross(anterior_dir, CSs.Z0));
front = cross(MostProxPoint, up);

% debug plot
quickPlotTriang(ProxFem, 'm', 1)
plot3(MostProxPoint(:,1), MostProxPoint(:,2), MostProxPoint(:,3),'g*', 'LineWidth', 3.0);

% Slice the femoral head starting from the top
Ok_FH_Pts = [];
Ok_FH_Pts_med = [];
d = MostProxPoint*CSs.Z0 - 0.25;
keep_slicing = 1;
count = 1;
while keep_slicing
    
    % slice the proximal femur
    [ Curves , ~, ~ ] = TriPlanIntersect(ProxFem, corr_dir*CSs.Z0 , d );
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
    
    if Nbr_of_curves == 1
        Ok_FH_Pts = [Ok_FH_Pts; Curves.Pts];
    elseif Nbr_of_curves > 1
        for i = 1:Nbr_of_curves
            
            % if I assume centre of CT/MRI is always more medial than HJC
            % then medial points can be identified as closer to mid
            % it is however a weak solution - depends on medical images.
            ind_med_point = abs(Curves(i).Pts(:,1))<abs(MostProxPoint(1));
            Ok_FH_Pts_med = [Ok_FH_Pts_med; Curves(i).Pts(ind_med_point,:)];
            
            % More robust (?) to check if the cross product of 
            % dot ( cross( (x_P-x_MostProx), Z0 ) , front ) > 0
%             v_MostProx2Points = bsxfun(@minus,  Curves(i).Pts, MostProxPoint);
            % this condition is valid for right leg, left should be <0
%             ind_med_point = (medial_dir'*bsxfun(@cross, v_MostProx2Points', up))>0;
%             Ok_FH_Pts_med = [Ok_FH_Pts_med; Curves(i).Pts(ind_med_point,:)];
        end
    end
end

% assemble the points from one and two curves
fitPoints = [Ok_FH_Pts; Ok_FH_Pts_med];

% check by plotting
plot3(fitPoints(:,1), fitPoints(:,2), fitPoints(:,3),'g.');hold on

% fit sphere
[CenterFH, Radius] = sphereFit(Ok_FH_Pts);

% print
disp('-----------------')
disp('Final  Estimation')
disp('-----------------')
disp(['Centre: ', num2str(CenterFH)]);
disp(['Radius: ', num2str(Radius)]);
disp('-----------------')

CSs.CenterFH_Kai = CenterFH ;
CSs.RadiusFH_Kai = Radius ;

end

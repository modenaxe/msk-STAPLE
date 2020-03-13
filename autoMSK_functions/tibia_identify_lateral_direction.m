    function [U_tmp, MostDistalMedialPt, just_tibia] = tibia_identify_lateral_direction(DistTib, Z0)
% slice at centroid of distal tibia
[ ~, CenterVolTibDist] = TriInertiaPpties( DistTib );
d = CenterVolTibDist'*Z0;
[ DistCurves , ~, ~ ] = TriPlanIntersect(DistTib, Z0 , -d );

% check the number of curves on that slice
N_DistCurves = length(DistCurves);
just_tibia = 1;
if N_DistCurves == 2
    disp('Tibia and fibula have been detected.')
    just_tibia = 0;
elseif N_DistCurves>2
    warning(['There are ', num2str(N_DistCurves), ' section areas.']);
    error('This should not be the case (only tibia and possibly fibula should be there.')
end

% Find the most distal point, it will be medial
% even if not used when tibia and fibula are available it is used in
% plotting
[~ , I_dist_fib] = max( DistTib.Points* -Z0 );
MostDistalMedialPt = DistTib.Points(I_dist_fib,:);

% compute a vector pointing laterally (Z_ISB)
if just_tibia
    % vector pointing laterally
    U_tmp = CenterVolTibDist'- MostDistalMedialPt;
else
    %tibia and fibula
    % check which area is larger(Tibia)
    if DistCurves(1).Area>DistCurves(2).Area
        % vector from tibia section to fibular section
        U_tmp = mean(DistCurves(2).Pts) - mean(DistCurves(1).Pts);
    else
        U_tmp = -1 * (mean(DistCurves(2).Pts) - mean(DistCurves(1).Pts));
    end
end
    end
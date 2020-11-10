%%  Identify the ant-post axis (GIBOK Z axis) based on 'circularity'
% Test for circularity, because on one face the surface is spherical and on the arular surface it's
% more like a Hyperbolic Paraboloid, the countour od the cross section have
% different circularity.
function V_all = CS_patella_adjustACSBasedOnCircularity(Patella, V_all)

nAP = V_all(:,3);% initial guess of Antero-Posterior axis

% First 0.5 mm in Start and End are not accounted for, for stability.
Alt = linspace( min(Patella.Points*nAP)+0.5 ,max(Patella.Points*nAP)-0.5, 100);
Area=[];
Circularity=[];
for d = -Alt
    [ Curves , Area(end+1), ~ ] = TriPlanIntersect( Patella, nAP , d );
    PtsTmp=[];
    for i = 1 : length(Curves)
        PtsTmp (end+1:end+length(Curves(i).Pts),:) = Curves(i).Pts;
        if isempty(PtsTmp)
            warning('Slicing of patella in A-P direction did not produce any section');
        end
    end
    % compute the circularity (criteria ? Coefficient of Variation)
    dist2center = sqrt(sum(bsxfun(@minus,PtsTmp,mean(PtsTmp)).^2,2));
    Circularity(end+1) = std(dist2center)/mean(dist2center);
end

% Get the circularity at both first last quarter of the patella
Circularity1stOffSettedQuart = Circularity(Alt<quantile(Alt,0.3) & Alt>quantile(Alt,0.05));
Circularity3rdOffSettedQuart = Circularity(Alt>quantile(Alt,0.7) & Alt<quantile(Alt,0.95));

% Check that the circularity is higher in the anterior part otherwise
% invert AP axis direction :
if mean(Circularity1stOffSettedQuart)<mean(Circularity3rdOffSettedQuart)
    disp('Based on circularity analysis invert AP axis');
    V_all(:,3) = -normalizeV(V_all(:,3));
    V_all(:,2) =  normalizeV(cross(V_all(:,3),V_all(:,1)));
    V_all(:,1) =  normalizeV(cross(V_all(:,2),V_all(:,3)));
end

end
function Landmarks = LandmarkGeom(TriObj, CS, bone_name)

% get desired landmarks
LandmarkStruct = getLandmarkStructForBone(bone_name);

% change reference system
TriObj_in_CS = TriChangeCS(TriObj, CS.V, CS.Origin');

% debug plots
quickPlotTriang(TriObj_in_CS, 'm', 1); hold on
CSs = CS;
CS.Origin = [0 0 0]
quickPlotRefSystem(CSs);


% get points
TriPoints = TriObj_in_CS.Points;

% TODO replace with CentreVol 
COM = mean(TriPoints);

NL = numel(LandmarkStruct);
for nL = 1:NL
    cur_land = LandmarkStruct{nL};
    % store names
    cur_name = cur_land{1};
    if strcmp(cur_land(end), 'proximal')
        Landmarks.(cur_name) = getLandmark(TriPoints(TriPoints(:,2)>COM(2),:), cur_land{2}, cur_land{3})*CS.V';
    elseif strcmp(cur_land(end), 'distal')
        Landmarks.(cur_name) = getLandmark(TriPoints(TriPoints(:,2)<COM(2),:), cur_land{2}, cur_land{3})*CS.V';
    else
        % get landmark
        Landmarks.(cur_name) = getLandmark(TriPoints, cur_land{2}, cur_land{3})*CS.V';
    end
    % plot marker
    plotDot(Landmarks.(cur_name),'r',10);
end

end

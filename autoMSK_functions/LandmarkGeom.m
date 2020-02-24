function Landmarks = LandmarkGeom(TriObj, CS, bone_name)

% get desired landmarks
LandmarkStruct = getLandmarkStructForBone(bone_name);

% change reference system
TriObj_in_CS = TriChangeCS(TriObj, CS.V, CS.Origin');

% debug plots
CSs = CS;
CSs.Origin = [0 0 0];
CSs.X = [1 0 0]';CSs.Y=[0 1 0]'; CSs.Z = [0 0 1]';
% close all
quickPlotTriang(TriObj_in_CS, 'm', 1); hold on
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
        local_BL = getLandmark(TriPoints(TriPoints(:,2)>COM(2),:), cur_land{2}, cur_land{3});
    elseif strcmp(cur_land(end), 'distal')
        local_BL = getLandmark(TriPoints(TriPoints(:,2)<COM(2),:), cur_land{2}, cur_land{3});
    else
        % get landmark
        local_BL = getLandmark(TriPoints, cur_land{2}, cur_land{3});
    end
    % plot marker (I have to transform it back
    plotDot(local_BL,'r',10);
    Landmarks.(cur_name) = CS.Origin+local_BL*CS.V';
end

end

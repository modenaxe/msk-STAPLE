function Landmarks = LandmarkGeom(TriObj, CS, bone_name, results_plot)

if nargin<4; results_plot = 1; end

% get desired landmarks
LandmarkStruct = getLandmarkStructForBone(bone_name);

% change reference system
TriObj_in_CS = TriChangeCS(TriObj, CS.V, CS.Origin);

if results_plot == 1
    % debug plots
    LocalCS = struct();
    LocalCS.Origin = [0 0 0]';
    LocalCS.V = eye(3);
    % close all
    PlotTriangLight(TriObj_in_CS, LocalCS, 1); hold on
    quickPlotRefSystem(LocalCS);
end

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
    plotDot(local_BL,'r',3);
    Landmarks.(cur_name) = CS.Origin+local_BL*CS.V';
end

end

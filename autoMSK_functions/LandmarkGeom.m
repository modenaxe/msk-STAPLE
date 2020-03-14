function Landmarks = LandmarkGeom(TriObj, CS, bone_name, results_plot)

if nargin<4; results_plot = 0; end

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
COM = [0 0 0]';
ub = max(TriPoints(:,2))*0.3;
lb = max(TriPoints(:,2))*(-0.3);

NL = numel(LandmarkStruct);
for nL = 1:NL
    cur_land = LandmarkStruct{nL};
    % store names
    cur_name = cur_land{1};
    if strcmp(cur_land(end), 'proximal')
        local_BL = getLandmark(TriPoints(TriPoints(:,2)>ub,:), cur_land{2}, cur_land{3});
    elseif strcmp(cur_land(end), 'distal')
        local_BL = getLandmark(TriPoints(TriPoints(:,2)<lb,:), cur_land{2}, cur_land{3});
%         debug_plot = 1;
%         if debug_plot == 1
%             figure
%             checkpoints = TriPoints(TriPoints(:,2)<COM(2),:);
%             plot3(checkpoints(:,1), checkpoints(:,2), checkpoints(:,3),'.'); axis equal
%             plotDot(local_BL)
%         end
    else
        % get landmark
        local_BL = getLandmark(TriPoints, cur_land{2}, cur_land{3});
    end
    % plot marker (I have to transform it back
    if results_plot == 1
        plotDot(local_BL,'r',4);
    end
    % [LM] the check was not working I fixed it
    if size(CS.Origin,1)>size(CS.Origin,2) && size(CS.Origin,1)==3
        CS.Origin = CS.Origin';
    end
    % save
    Landmarks.(cur_name) = CS.Origin+local_BL*CS.V';
end

end

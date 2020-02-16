function autoLandmarkTibia(TibiaTriang, CS, is_fibula_in_triang)

% move to standard ref syst
TibiaISB = TriChangeCS(TibiaTriang, CS.V, CS.Origin');

% % get relevant points in all directions of ISB axes
% [a, b] = max(TibiaISB.Points);
% [c, d] = min(TibiaISB.Points);

[tibia_Px, tibia_Py, tibia_Pz] = deal(TibiaISB.Points(:,1),... 
                                      TibiaISB.Points(:,2),...
                                      TibiaISB.Points(:,3));
rangeZ = [min(tibia_Py) max(tibia_Py)];
tot_length = rangeZ(2)-rangeZ(1);

% right side

% proximal tibia
[~, ind0] = max(tibia_Py);% tip of tib plateau
[~, ind1] = max(tibia_Px);% Tibial tuberosity 
[~, ind2] = max(tibia_Pz);% Tibial Condyle  or fibular head
[~, ind3] = min(tibia_Pz);% Tibial Condyle

% in distal tibia
[~, ind4] = max(tibia_Pz);% lateral malleolus Condyle
[~, ind5] = min(tibia_Pz);% medial malleolus (fib or tibial)

TTB = Tibia.Points(ind,:);
quickPlotTriang(Tibia,'m',1)

% Tibial Malleolus



plot3(TTB(1), TTB(2), TTB(3), 'go', 'LineWidth',5)

if is_fibula_in_triang==1
    % Lateral Malleolus
end
end

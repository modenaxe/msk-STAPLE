function figPos = get_figpos_artic_surf(varargin)
mp = get(0, 'MonitorPositions'); %gets the monitor position(s)

if size(mp,1) > 1 % if there is more than 1 monitor
    indMonitor = find(strncmpi(varargin(1:2:end), 'Monitor', 3)); % Monitor argument
    if ~isempty(indMonitor)
        % if 'Monitor' argument is passed
        % positions of the selected monitor
        mp = mp(cell2mat(varargin(indMonitor(end)+1)),:);
    else
        % else the largest screen is selected to plot
        mp = mp(prod(mp,2) == max(prod(mp,2)), :);
    end
end

left = mp(1) + mp(3)/5;    % leftFig = leftMonitor + widthMonitor/5
bottom = mp(2) + mp(4)/5;  % bottomFig = bottomMonitor + heightMonitor/2
width = 2*mp(3)/3;         % widthFig = widthMonitor
height = 2*mp(4)/3;        % heightFig = heightMonitor
figPos = [left, bottom, width, height];
end
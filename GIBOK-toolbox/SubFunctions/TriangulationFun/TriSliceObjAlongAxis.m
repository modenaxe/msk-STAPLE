% Author: Luca Modenese
% Feb 2020

function Areas = TriSliceObjAlongAxis(TriObj, Axis, step, debug_plot)

% THIS IS INCORRECT: SLICES SHOULD BE 1mm APART
min_coord = min(TriObj.Points*Axis)+0.5;
max_coord = max(TriObj.Points*Axis)-0.5;
Alt = min_coord:step:max_coord;

Areas=[];

if debug_plot
    quickPlotTriang(TriObj,'m');
end

it = 1;
for d = -Alt
    [ Curves , Areas(it), ~ ] = TriPlanIntersect(TriObj, Axis, d);
    it = it + 1;
    if debug_plot
        N_Curves = length(Curves);
        for nn = 1:N_Curves
            plot3(Curves(nn).Pts(:,1), Curves(nn).Pts(:,2), Curves(nn).Pts(:,3),'k-', 'LineWidth',2); hold on
        end
    end
end

end
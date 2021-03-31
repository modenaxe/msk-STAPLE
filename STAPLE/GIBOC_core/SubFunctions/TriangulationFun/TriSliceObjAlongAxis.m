% TRISLICEOBJALONGAXIS Slice a MATLAB triangulation object TriObj along a
% specified axis. Notation and inputs are consistent with the other
% GIBOC-Knee functions used to manipulate triangulations.
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese, 2020
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function [Areas, Alt, maxArea, maxAreaInd, maxAlt] = TriSliceObjAlongAxis(...
                                                        TriObj, Axis, step,...
                                                        cut_offset,...
                                                        debug_plot)

if nargin<4
    cut_offset = 0.5;
end

if nargin<5
    debug_plot=0;
end

min_coord = min(TriObj.Points*Axis)+cut_offset;
max_coord = max(TriObj.Points*Axis)-cut_offset;
Alt = min_coord:step:max_coord;

Areas=[];

if debug_plot
    quickPlotTriang(TriObj,'m', 1, 1);
    title('Slicing Triangulation')
end

it = 1;
for d = -Alt
    [ Curves , Areas(it), ~ ] = TriPlanIntersect(TriObj, Axis, d);
    it = it + 1;
    if debug_plot
        N_Curves = length(Curves);
        for nn = 1:N_Curves
            plot3(Curves(nn).Pts(:,1), Curves(nn).Pts(:,2), Curves(nn).Pts(:,3),'k-', 'LineWidth',1); hold on
        end
    end
end

disp(['Sliced #', num2str(it-1), ' times']);
[maxArea, maxAreaInd] = max(Areas);
maxAlt = Alt(maxAreaInd);

end
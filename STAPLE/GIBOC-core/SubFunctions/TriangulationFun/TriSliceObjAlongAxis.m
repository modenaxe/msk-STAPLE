% TRISLICEOBJALONGAXIS Slice a MATLAB triangulation object TR along a
% specified axis. Notation and inputs are consistent with the other
% GIBOC-Knee functions used to manipulate triangulations.
%
% [Areas, Alt, maxArea, maxAreaInd, maxAlt] 
%       = TriSliceObjAlongAxis(TR, Axis, step, cut_offset, debug_plot)
%
% Inputs:
%   TR - A triangulation object.
%   Axis - A [3x1] vector giving the normal of the slice cut plan.
%   step - A scalar, the distance between two consecutive slices.
%   cut_offset - A distance to start and stop from relative to the ends
%                of TR along the cut axis.
%   debug_plots - A boolean, if set to true the intersection will be plotted
%                 Or kx3 list of nodes coordinates.
%
% Outputs:
%   Areas - A [kx1] vector of cross section areas of the cuts along the axis
%   Alt - A [kx1] vector of the altitude along the cut axis of the slices.
%   maxArea - Maximal cross section areas along cut axis
%   maxAreaInd - Index of the maximal area (maxAreaInd<k)
%   maxAlt - Atlitude along the cut axis at the maximal cross section area
%
% See also TRIPLANINTERSECT
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese, 2020
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function [Areas, Alt, maxArea, maxAreaInd, maxAlt] = TriSliceObjAlongAxis(...
                                                        TR, Axis, step,...
                                                        cut_offset,...
                                                        debug_plot)

    if nargin<4
        cut_offset = 0.5;
    end

    if nargin<5
        debug_plot=0;
    end

    min_coord = min(TR.Points*Axis)+cut_offset;
    max_coord = max(TR.Points*Axis)-cut_offset;
    Alt = min_coord:step:max_coord;

    Areas=[];

    if debug_plot
        quickPlotTriang(TR,'m', 1, 1);
        title('Slicing Triangulation')
    end

    it = 1;
    for d = -Alt
        [ Curves , Areas(it), ~ ] = TriPlanIntersect(TR, Axis, d);
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
% TRISLICEOBJALONGAXIS Convert a rotation matrix in the orientation vector
% used in OpenSim (X-Y-Z axes rotation order).
%
%   orientation = computeXYZAngleSeq(aRotMat)
%
% Inputs:
%   aRotMat - a rotation matrix, normally obtained writing as columns the
%       axes of the body reference system, expressed in global reference
%       system.
%
% Outputs:
%   orientation - the sequence of angles used in OpenSim to define the
%       joint orientation. Sequence of rotation is X-Y-Z.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese, 2020
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function [Areas, Alt, maxArea, maxAreaInd, maxAlt] = TriSliceObjAlongAxis(...
                                                        TriObj, Axis, step,...
                                                        cut_offset, debug_plot)

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

[maxArea, maxAreaInd] = max(Areas);
maxAlt = Alt(maxAreaInd);

end
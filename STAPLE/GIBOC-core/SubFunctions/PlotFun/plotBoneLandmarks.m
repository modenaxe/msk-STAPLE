% PLOTBONELANDMARKS Add point plots, and if required, labels to bone
% landmarks identified throught the STAPLE analyses.
%
%   plotBoneLandmarks(BLStruct, label_switch)
%
% Inputs:
%   BLStruct - a MATLAB structure with fields having as fields the name of 
%       the bone landmarks and as values their coordinates (in global
%       reference system).
%
%   label_switch - a binary switch that indicates if the bone landmark
%       names will be added or not (as text) to the plot.
%
% Outputs:
%   none - the points are plotted on the current axes.
%
% See also PLOTDOT.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function plotBoneLandmarks(BLStruct, label_switch)
    BLfields = fields(BLStruct);
    for nL = 1:numel(BLfields)
        cur_name = BLfields{nL};
        plotDot(BLStruct.(cur_name), 'k', 7)
        if label_switch==1
            text(BLStruct.(cur_name)(1),...
                BLStruct.(cur_name)(2),...
                BLStruct.(cur_name)(3),...
                ['    ',cur_name],...
                'VerticalAlignment', 'Baseline',...
                'FontSize',8);
        end
    end
end
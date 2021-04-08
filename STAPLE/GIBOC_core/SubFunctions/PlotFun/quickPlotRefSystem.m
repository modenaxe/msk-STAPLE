% QUICKPLOTREFSYSTEM Plot a coordinate system object.
% Plot a coordinate system origin and vectors on the current axis.
% Use plotArrow and plotDot to have a nice rendering of the
% coordinate system on the current plot.
% 
% quickPlotRefSystem(CS, length_arrow)
%
% Inputs:
%   CS - A coordinate system structure.
%         * CS.Origin ~ the origin of the coordiante system.
%         * CS.X ~ the X direction of the coordiante system.
%         * CS.Y ~ the Y direction of the coordiante system.
%         * CS.Z ~ the Z direction of the coordiante system.
%
%   length_arrow - Length of the arrow representing the coordinate system
%                  vectors.
% 
% Outputs:
%   None - Plot the coordinate system origin and vecotrs on the current axis.
%
% See also PLOTDOT, PLOTARROW.
%
%-------------------------------------------------------------------------%
%    Copyright (c) 2021 Modenese L.                                       %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
function quickPlotRefSystem(CS, length_arrow)

    if nargin<2
        length_arrow = 60;
    end

    if isfield(CS, 'V') && ~isfield(CS, 'X')
        CS.X = CS.V(:,1);
        CS.Y = CS.V(:,2);
        CS.Z = CS.V(:,3);
    end

    if isfield(CS, 'X') && isfield(CS,'Origin')
        plotArrow( CS.X, 1, CS.Origin, length_arrow, 1, 'r')
        plotArrow( CS.Y, 1, CS.Origin, length_arrow, 1, 'g')
        plotArrow( CS.Z, 1, CS.Origin, length_arrow, 1, 'b')
        
    else
        warning('plotting AXES X0-Y0-Z0')
        plotArrow( CS.X0, 1, CS.Origin, length_arrow, 1, 'r')
        plotArrow( CS.Y0, 1, CS.Origin, length_arrow, 1, 'g')
        plotArrow( CS.Z0, 1, CS.Origin, length_arrow, 1, 'b')
        
    end

    plotDot(CS.Origin, 'k', 4*length_arrow/60)

end
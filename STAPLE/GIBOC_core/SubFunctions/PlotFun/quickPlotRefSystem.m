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
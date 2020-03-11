function quickPlotRefSystem(CS)

if isfield(CS, 'V') && ~isfield(CS, 'X')
    CS.X = CS.V(:,1);
    CS.Y = CS.V(:,2);
    CS.Z = CS.V(:,3);
end

if isfield(CS, 'X') && isfield(CS,'Origin')
    plotArrow( CS.X, 1, CS.Origin, 60, 1, 'r')
    plotArrow( CS.Y, 1, CS.Origin, 60, 1, 'g')
    plotArrow( CS.Z, 1, CS.Origin, 60, 1, 'b')
    
else
    warning('plotting AXES X0-Y0-Z0')
    plotArrow( CS.X0, 1, CS.Origin, 60, 1, 'r')
    plotArrow( CS.Y0, 1, CS.Origin, 60, 1, 'g')
    plotArrow( CS.Z0, 1, CS.Origin, 60, 1, 'b')
    
end

plotDot(CS.Origin, 'k', 4)

end
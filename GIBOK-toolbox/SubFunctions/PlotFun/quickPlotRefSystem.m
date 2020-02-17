function quickPlotRefSystem(CS)

try
    plotArrow( CS.X, 1, CS.Origin, 60, 1, 'r')
    plotArrow( CS.Y, 1, CS.Origin, 60, 1, 'g')
    plotArrow( CS.Z, 1, CS.Origin, 60, 1, 'b')
catch 
    warning('plotting AXES X0-Y0-Z0')
    plotArrow( CS.X0, 1, CS.Origin, 60, 1, 'r')
    plotArrow( CS.Y0, 1, CS.Origin, 60, 1, 'g')
    plotArrow( CS.Z0, 1, CS.Origin, 60, 1, 'b')
end
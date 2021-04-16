% SCALEMASSPROPS Scale mass and inertia of the bodies of an OpenSim model
% assuming that the geometry stays constant and only the mass changes
% proportionally to a coefficient assigned in input.
% 
%   osimModel = scaleMassProps(osimModel, coeff)
%
% Inputs:
%   osimModel - the OpenSim model for which the mass properties of the
%       segments will be scaled.
%
%   coeff - ratio of mass new_mass/curr_model_mass. This is used to scale
%       the inertial properties of the gait2392 model to the mass of a
%       specific individual.
%
% Outputs:
%   osimModel - the OpenSim model with the scaled inertial properties.
%
% See also GAIT2392MASSPROPS, MAPGAIT2392MASSPROPTOMODEL.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function osimModel = scaleMassProps(osimModel, coeff)
% import libraries
import org.opensim.modeling.*

% get bodyset
subjspec_bodyset = osimModel.getBodySet;

for n_b = 0:subjspec_bodyset.getSize()-1
    
    curr_body = subjspec_bodyset.get(n_b);
    
    % updating the mass
    curr_body.setMass(coeff* curr_body.getMass);
    
    % updating the inertia matrix for the change in mass
    m = curr_body.get_inertia();
    
    % components of inertia
    xx = m.get(0)*coeff;
    yy = m.get(1)*coeff;
    zz = m.get(2)*coeff;
    xy = m.get(3)*coeff;
    xz = m.get(4)*coeff;
    yz = m.get(5)*coeff;
    upd_inertia = Inertia(xx , yy , zz , xy , xz , yz);
    
    % updating Inertia
    curr_body.setInertia(upd_inertia);
    
    clear m
end

end
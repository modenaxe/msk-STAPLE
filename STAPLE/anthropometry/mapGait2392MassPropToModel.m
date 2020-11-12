% MAPGAIT2392MASSPROPTOMODEL Map the mass properties of the gait2392 model
% to the equivalent segments of the model specified as input.
% 
%   osimModel = mapGait2392MassPropToModel(osimModel)
%
% Inputs:
%   osimModel - the OpenSim model for which the mass properties of the
%       segments will be updated using the gait2392 values.
%
% Outputs:
%   osimModel - the OpenSim model with the updated inertial properties.
%
% See also GAIT2392MASSPROPS, SCALEMASSPROPS.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function osimModel = mapGait2392MassPropToModel(osimModel)

% import libraries
import org.opensim.modeling.*

% TODO: check equivalence of segment names

% loop through the bodies of the model
N_bodies = osimModel.getBodySet.getSize();
for n_b = 0:N_bodies-1
    curr_body = osimModel.getBodySet.get(n_b);
    curr_body_name = char(curr_body.getName());
    % retried mass properties of gait2392
    massProp = gait2392MassProps(curr_body_name);
    % retrieve segment to update
    curr_body = osimModel.getBodySet.get(curr_body_name);
    % assign mass
    curr_body.setMass(massProp.mass);
    % build a matrix of inertia with the gait2392 values
    xx = massProp.inertia_xx;
    yy = massProp.inertia_yy;
    zz = massProp.inertia_zz;
    xy = 0.0;
    xz = 0.0;
    yz = 0.0;
    upd_inertia = Inertia(xx , yy , zz , xy , xz , yz);
    % set inertia
    curr_body.setInertia(upd_inertia);
    disp([  'Mapped on body: ', char(curr_body_name)])
end

end
    



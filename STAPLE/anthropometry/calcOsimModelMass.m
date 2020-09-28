% CALCOSIMMODELMASS Calculate the total mass of the segment of an OpenSim
% model. Tested for OpenSim 4.1.
%
%   total_mass = calcOsimModelMass(aOsimModel, print_results)
%
% Inputs:
%   aOsimModel - an OpenSim model. Note that the model has been read by
%       MATLAB externally, i.e. this is an OpenSim object, not a file path.
%
%   print_results - print or not the total mass. Valid values: 1 or 0.
%
% Outputs:
%   total_mass - mass in Kg obtained summing the masses of all segments
%       included in the model.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function total_mass = calcOsimModelMass(aOsimModel, print_results)

% OpenSim libraries
import org.opensim.modeling.*

% unless specified as input, do not print mass
if nargin==1; print_results=0; end
    
% extracts the bodyset from the model
bodyset = aOsimModel.getBodySet;

% loops through the bodies collecting the body mass
total_mass = 0;
for n_body = 0:bodyset.getSize()-1
    % current body
    curr_body = bodyset.get(n_body);
    % this check is necessary if the script is used in OpenSim 3.3
    if strcmp(char(curr_body.getName), 'ground')
        continue
    end
    total_mass = total_mass + curr_body.getMass();
end

% display output only if requested
if print_results==1
    disp(['Mass of model ',char(aOsimModel.getName),':   ',num2str(total_mass),' Kg.']);
end

end
%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
%
% Given an OpenSim model, this function calculates its total mass.
%
function total_mass = calcOsimModelMass(aOsimModel, varargin)

% extracts the bodyset from the model
bodyset = aOsimModel.getBodySet;

% loops through the bodies collecting the body mass
total_mass = 0;
for n_body = 0:bodyset.getSize()-1
    % current body
    curr_body = bodyset.get(n_body);
    if strcmp(char(curr_body.getName), 'ground')
        continue
    end
    total_mass = total_mass + curr_body.getMass;
end

% display only if requested
if isempty(varargin)==1
    % display the output
    display('========= CALCULATING MODEL MASS ========')
    display(['Mass for model ',char(aOsimModel.getName),' is:   ',num2str(total_mass),' Kg.']);
else
    if varargin{1}==1
        % display the output
        display('========= CALCULATING MODEL MASS ========')
        display(['Mass for model ',char(aOsimModel.getName),' is:   ',num2str(total_mass),' Kg.']);
    end
end

end
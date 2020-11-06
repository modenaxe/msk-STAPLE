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
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
function quickPlotTriang(triangObj, face_color, new_figure, alpha)

if nargin>2
    if isempty(new_figure)
        figure
    elseif new_figure == 1
        figure
    end
end

if nargin==1 || (nargin>=2 && isempty(face_color))
    face_color = [0.65    0.65    0.6290];
end

if nargin < 4
    alpha = 1;
end

trisurf(triangObj,'Facecolor', face_color,'FaceAlpha',alpha, 'edgecolor','none');
light; lighting phong; % light
hold on, axis equal

end
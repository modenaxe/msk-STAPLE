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
function modelStruct = createJointParamsMatStructFromOsimModel(aOsimModel_name)

import org.opensim.modeling.*

osimModel = Model(aOsimModel_name);

jset = osimModel.getJointSet();
for nj = 0:jset.getSize()-1
    cur_joint_name = char(jset.get(nj).getName());
    % build a model structure from reading the opensim model
    [modelStruct.(cur_joint_name).parent, modelStruct.(cur_joint_name).child] = getHomogeneusMatsForJoint(osimModel, cur_joint_name);
end

end

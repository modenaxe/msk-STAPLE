%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%    Author:   Luca Modenese                                              %
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

function updJointSet = createJointSet(JointParams, bodySet)

% OpenSim libraries
import org.opensim.modeling.*

% number of bodies
N = size(JointParams,2);

% create a bodyset
updJointSet = JointSet;

% create joints from structures
for n_joint = 1:N
    % get current joint
    currJoint = createCustomJointFromStruct(JointParams(n_joint));
    
    % need to connect the joint to the corresponding body
    child_body = bodySet.get(JointParams(n_joint).child);    
    child_body.setJoint(currJoint);
    
    % clone and append to jointSet
    updJointSet.cloneAndAppend(currJoint);
end

% test print
updJointSet.print('_test_jointSet.xml');

end
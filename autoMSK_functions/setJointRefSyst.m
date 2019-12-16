function OSJoint = setJointRefSyst(OSJoint, struct)

% OpenSim libraries
import org.opensim.modeling.*

% set joint name
jointName = struct.name;
OSJoint.setName(jointName);

% set location and orientation for parent
parentName = struct.parent;
location_in_parent = ArrayDouble.createVec3(struct.parent_location);
orientation_in_parent = ArrayDouble.createVec3(struct.parent_orientation);
OSJoint.setParentName(parentName);
OSJoint.setLocationInParent(location_in_parent);
OSJoint.setOrientationInParent(orientation_in_parent);

% set location and orientation for child
location  = ArrayDouble.createVec3(struct.child_location);
orientation = ArrayDouble.createVec3(struct.child_orientation);
OSJoint.setLocation(location);
OSJoint.setOrientation(orientation);

end
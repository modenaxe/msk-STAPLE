
function myCustomJoint = createCustomJointFromStruct(struct)


% OpenSim libraries
import org.opensim.modeling.*

% create custom joint
OSJoint = CustomJoint();

%---------- SET JOINT REF SYST -----------------
OSJoint = setJointRefSyst(OSJoint, struct);
OSJoint.print('joint_check1.xml');

%---------- CREATE COORDINATESET -----------------
OSJoint = setJointCoords(OSJoint, struct);
OSJoint.print('joint_check2.xml');

%------------ UPDATE SPATIALTRANSFORM ------------------------
OSJoint = setCustomJointSpatialTransform(OSJoint, struct);
OSJoint.print('joint_check3.xml');

myCustomJoint = OSJoint;
end
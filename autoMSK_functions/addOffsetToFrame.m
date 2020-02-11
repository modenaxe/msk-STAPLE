function offset = addOffsetToFrame(baseFrame, offsetName, trans, rot)
% 	Define a PhysicalOffsetFrame in terms of its translational and rotational
% 		offset with respect to a base (Physical) frame and add it to the model.
% 		Arguments:
% 			baseFrame: the PhysicalFrame in the model to offset.
% 		   offsetName: the name (string) of the OffsetFrame to be added
% 				trans: Translational offset (Vec3) in base frame coordinates
% 				  rot: Rotational offset in the base frame as body fixed X-Y-Z Euler angles (Vec3)
% 		return:
% 			offset: the PhysicalOffsetFrame added to the model
%

% OpenSim libraries
import org.opensim.modeling.*

offset = PhysicalOffsetFrame();
offset.setName(offsetName)

if nargin>2
    offset.set_translation(trans);
end

if nargin>3
    offset.set_orientation(rot);
end

if (model.hasComponent(baseFrame.getAbsolutePathString()))
    offset.connectSocket_parent(baseFrame)
    baseFrame.addComponent(offset)
else
    disp('baseFrame does not exist as a PhysicalFrame. No offset frame was added.')
end

end
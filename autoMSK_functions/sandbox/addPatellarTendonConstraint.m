
% add patellofemoral constraint
function addPatellarTendonConstraint(osimModel, TibiaRBL, PatellaRBL, side, in_mm)

% check units
if nargin<4;     in_mm = 1;  end
if in_mm == 1;     dim_fact = 0.001;  else;  dim_fact = 1; end

% OpenSim libraries
import org.opensim.modeling.*

ptf = ConstantDistanceConstraint(osimModel.get_BodySet().get(['tibia_', side]),...
                                 Vec3(TibiaRBL.RTTB(1)*dim_fact, TibiaRBL.RTTB(2)*dim_fact, TibiaRBL.RTTB(3)*dim_fact),...
                                 osimModel.get_BodySet().get(['patella_',side]),...
                                 Vec3(PatellaRBL.RLOW(1)*dim_fact, PatellaRBL.RLOW(2)*dim_fact, PatellaRBL.RLOW(3)*dim_fact),...
                                 norm(TibiaRBL.RTTB-PatellaRBL.RLOW)*dim_fact);
addConstraint(osimModel, ptf)  
end
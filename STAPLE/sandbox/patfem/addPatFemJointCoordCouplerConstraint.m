%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%
function addPatFemJointCoordCouplerConstraint(osimModel, side)

% OpenSim libraries
import org.opensim.modeling.*

% this should reduce to 'r' or 'l' most meaningful inputs
side = lower(side(1)); 

% coordinate names (standard from Rajagopal model
knee_angle_name = ['knee_angle_',side];
constr_name     = ['patellofemoral_knee_angle_',side,'_con'];
dep_coord_name  = ['knee_angle_',side,'_beta'];

% get the constraintSet to update
updConstr = osimModel.updConstraintSet();
% create the constraint
new_constr = CoordinateCouplerConstraint();
% set the indep coordinates
ind_coords = ArrayStr();
ind_coords.append(knee_angle_name);
new_constr.setName(constr_name);
% set the dep coordinate
new_constr.setIndependentCoordinateNames(ind_coords);
new_constr.setDependentCoordinateName(dep_coord_name)
% def the linear function
lin_func = LinearFunction();
lin_func.setIntercept(0.0);
lin_func.setSlope(1.0);
% set the func in the constraint
new_constr.setFunction(lin_func);
% new_constr.print('test_constr.xml')
updConstr.cloneAndAppend(new_constr);

end
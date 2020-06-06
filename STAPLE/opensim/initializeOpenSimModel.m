function osimModel = initializeOpenSimModel(aModelNameString)

% add OpenSim libraries
import org.opensim.modeling.*

% create the model
osimModel = Model();

% set gravity
osimModel.setGravity(Vec3(0, -9.8081, 0));

% set model name
osimModel.setName(aModelNameString);

% set credits
osimModel.set_credits('Luca Modenese, Jean-Baptist Renault 2020 - Toolbox to generate MSK models automatically.')

end
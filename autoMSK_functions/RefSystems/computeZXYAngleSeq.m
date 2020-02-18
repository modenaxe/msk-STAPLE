function orientation = computeZXYAngleSeq(aRotMat)
% fixed body sequence of angles from rot mat usable for orientation in
% OpenSim

beta  = atan2(aRotMat(1,3),                   sqrt(aRotMat(1,1)^2.0+aRotMat(1,2)^2.0));
alpha = atan2(-aRotMat(2,3)/cos(beta),        aRotMat(3,3)/cos(beta));
gamma = atan2(-aRotMat(1, 2)/cos(beta),       aRotMat(1,1)/cos(beta));

% build a vector
orientation = [  alpha  beta  gamma];
end
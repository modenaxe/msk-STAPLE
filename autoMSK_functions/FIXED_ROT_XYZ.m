% This function decomposes the rotational matrix given as input according
% to a ZXY rotation for body fixed rotations (as in OpenSim).
%
% The kind of rotation matrix has to be specified: 
% 'Glob2Loc' is when a rotation matrix is given for a body as able to
% transform a vector express in the global ref system (global can be also 
% another body ref syst, as pelvis to femur) to the local reference system.
% IE the vector of the segment ref system (expressed in glob)are rows of 
% this matrix. 'Glob2Loc' is the other way round.
%
% ex. Let pelvis ref system be defined by Xp = [1x3], Yp, Zp
% Rot = [Xp;Yp;Zp] 
% OpenSim coordinate for the pelvis will be given by:
% [ZPelvis, XPelvis, YPelvis] = FIXED_ROT_ZXY(Rot,'Glob2Loc');
%
% ex2. pelvis -> R_p;  femur -> R_f as before
% OpenSim coordinate for the femur wrt the pelvis will be given by:
% [ZFem, XFem, YFem] = FIXED_ROT_ZXY(R_p*R_f','Loc2Glob');
% 
% or (pelvis is "global" here)
%[ZFem, XFem, YFem] = FIXED_ROT_ZXY(R_f*R_p','Loc2Glob');
%
%____________NB ___________
% ASSUMPTION: the considered OpenSim model has ZXY defined joint rotations
% (as gait2392 - 3LM - delp - Arnold's model)
%__________________________

function [alpha, beta, gamma] = FIXED_ROT_XYZ(Rot,Rot_type)

% Check the rotation matrix
switch Rot_type
    case 'Glob2Loc'
        for n = 1:size(Rot,3)
            Rot(:,:,n) = Rot(:,:,n)';
        end
    case 'Loc2Glob'
    otherwise
        error('The second input value is a string specifying the kind of rotation matrix given as input: ''Glob2Loc'' or ''Loc2Glob''')
end

% calculating the angles
for m = 1:size(Rot,3)
    beta(m,1) = atan2(-Rot(3,1,m),sqrt(Rot(1,1,m)^2.0+Rot(2,1,m)^2.0));   
    alpha(m,1) = atan2(Rot(2,1,m)/cos(beta(m)),Rot(1,1,m)/cos(beta(m)));
    gamma(m,1) = atan2(Rot(3,2,m)/cos(beta(m)),Rot(3,3,m)/cos(beta(m)));
end

end
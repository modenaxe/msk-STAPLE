function [ ATM , R , T ] = randomATM
%randomATM : randomly generated affine transform matrix 
% Outputs :
%   ATM : affine transformation matrix (Roto-Translation)
%   R : rotation matrix from
%   T : translation vector
% 

% Generate uniformly distributed rotation matrix from random unit quaternion
% https://en.wikipedia.org/wiki/Rotation_matrix#Uniform_random_rotation_matrices

Qrandom = normrnd(zeros(4,1),ones(4,1)); 
Qrandom = Qrandom / norm(Qrandom);
w,x,y,z = deal(Qrandom(1),Qrandom(2),Qrandom(3),Qrandom(4));

R = [
    1 - 2*(y^2 + z^2) ,   2*(x*y - z*w)    ,    2*(x*z + y*w)    ;...
    2*(x*y + z*w)     ,  1 - 2*(x^2 + z^2) ,    2*(y*z - x*w)    ;...
    2*(x*z - y*w )    ,   2*(y*z + x*w)    ,  1 - 2 *(x^2 + y^2) 
    ];


% Generate a random translation vector
T = 500*normrnd(zeros(3,1),ones(3,1));

% Construct the affine transformation matrix from R and T
ATM = zeros(4); ATM(4,4) = 1; 
ATM(1:3,1:3) = R;
ATM(1:3,4) = T;

end

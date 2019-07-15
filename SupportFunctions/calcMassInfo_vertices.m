% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %
% Script that given a point cloud calculates the inertial properties,
% collecting them in the structure MassInfo.
%
% INPUT: aPointCloud, matrix [n x 3] including the coordinates of n points
%
% OUTPUT: MassInfo, whose structures are:
%           MassInfo.Mat         = I; %inertia tensor
%           MassInfo.COM         = COM; % centre of mass 
%           MassInfo.PrincAxes   = V'; % eigenvectors
%           MassInfo.PrincMom    = D; % values on diagonal inertial
%                                           matrix
% Matrix V' allows transformation from current to inertial reference system
% Matrix V contains as colum the vector/ the axes of the inertial reference
% system in the current system -> useful for plotting!

function MassInfo  = calcMassInfo_vertices(aPointCloud, density)

% COM
COM = mean(aPointCloud);

% move reference frame to COM (still aligned as global ref frame)
x = aPointCloud(:,1)-COM(1);
y = aPointCloud(:,2)-COM(2);
z = aPointCloud(:,3)-COM(3);

% ====== calculating inertia tensor as point cloud =======
Ixx = sum(y.^2.0+z.^2.0);
Iyy = sum(x.^2.0+z.^2.0);
Izz = sum(x.^2.0+y.^2.0);
Ixy = sum(-x.*y);
Ixz = sum(-x.*z);
Iyz = sum(-y.*z);

% inertial tensor
I = [Ixx     Ixy     Ixz;
    Ixy     Iyy     Iyz;
    Ixz     Iyz     Izz];

% Collecting all results together
MassInfo.mass       = [];
MassInfo.density    = density;
MassInfo.COM        = COM;
MassInfo.Imat       = I;

end
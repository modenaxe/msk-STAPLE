% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %
% Script that given a point cloud calculates the inertial properties,
% collecting them in the structure InertiInfo.
%
% INPUT: I inertia matrix
%
% OUTPUT: InertiaInfo, whose structures are:
%         InertiaInfo.PrincAxes   = V'; % eigenvectors
%         InertiaInfo.PrincMom    = D; % values on diagonal inertial
%                                           matrix
% Matrix V' allows transformation from current to inertial reference system
% Matrix V contains as colum the vector/ the axes of the inertial reference
% system in the current system -> useful for plotting!

function InertiaInfo  = calcPrincInertiaAxes(I)


%======= principal axis of inertia ========
% V: eigenvectors
% D: eigenvalues
% Matlab help:  [V,D] = eig(A,B) with A*V = V*D
% in my case:
% [V,D] = eig(I); 
% which means: I*V = V*D, i.e. I = V*D*V'
%=======================================================================
% IN CONCLUSION: V' is the transformation matrix from the current to the
% inertial reference system
%========================================================================
[V,D] = eig(I);

% Matrix V' allows transformation from current to inertial reference system
% Matrix V contains as colum the vector/ the axes of the inertial reference
% system in the current system -> useful for plotting!
InertiaInfo.PrincAxes   = V';

% ====== modifying the axes of inertia to give them a anatomical meaning
% X = V*[1 0 0]
if det(InertiaInfo.PrincAxes)<0
    InertiaInfo.PrincAxes(:,3) = cross(InertiaInfo.PrincAxes(:,1),InertiaInfo.PrincAxes(:,2));
end

InertiaInfo.PrincMom    = D;

end
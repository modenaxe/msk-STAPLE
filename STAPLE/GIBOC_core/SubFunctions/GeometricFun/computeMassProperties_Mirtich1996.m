% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, November 2015                               %
% ----------------------------------------------------------------------- %
% Script that given the vertices v and facets of a triangular mesh
% calculates the inertial properties (Volume, Mass, COM and Inertia matrix
% based on: Mirtich, B., 1996. Fast and accurate computation of polyhedral 
% mass properties. journal of graphics tools 1, 31-50. The algorithm is not
% the generic one presented in that publication, which works for any kind
% of polihedron, but is optimized to work with triangular meshes. The
% implementation was taken from Eberly, D., 2003. Polyhedral mass 
% properties (revisited). AVAILABLE AT: 
% https://www.geometrictools.com/Documentation/PolyhedralMassProperties.pdf
%
% VERIFICATION: this code yealds the same values as NMSBuilder for a femur
% and a sphere. (Exactly the same values, but it's faster!)
%
% INPUT: v, matrix [n x 3] vertices including the coordinates of n points
%        f, matrix of [f x 3], collecting the indices of the vertices of
%        each facet of the mesh
%
% OUTPUT:   MassInfo.mass       = mass;
%           MassInfo.COM        = COM;
%           MassInfo.Imat       = I; inertia matrix calculated at COM

function MassProps = computeMassProperties_Mirtich1996(v, f)

% feedback to the user
% I tried a waitbar, but the script was too slow!
disp('Calculating Inertia properties...');
tic

% initializing integral vectors
coeff = [1/6 1/24 1/24 1/24 1/60 1/60 1/60 1/120 1/120 1/120];
intg = zeros(1,10);

% looping through the N_f faces of the polyhedron
N_f = size(f, 1);
for n_f = 1:N_f
    
    % get vertices of face f
    curr_f_ind = f(n_f, :);
    v_f = v(curr_f_ind,:);
    v0 = v(curr_f_ind(1),:);
    v1 = v(curr_f_ind(2),:);
    v2 = v(curr_f_ind(3),:);
    
    % get edges
    e1 = v1-v0;
    e2 = v2-v0;
    
    % cross product
    d = cross(e1,e2);
    d0 = d(1);
    d1 = d(2);
    d2 = d(3);
    
    % compute integrals
    [f1x, f2x, f3x, g0x, g1x, g2x] = compSubexpression(v_f(:,1));
    [~, f2y, f3y, g0y, g1y, g2y] = compSubexpression(v_f(:,2));
    [~, f2z, f3z, g0z, g1z, g2z] = compSubexpression(v_f(:,3));

    % update integrals    
    intg(1)  = intg(1) + d0*f1x;
    intg(2)  = intg(2) + d0*f2x; intg(3)  = intg(3) + d1*f2y;  intg(4)  = intg(4) + d2*f2z;
    intg(5)  = intg(5) + d0*f3x; intg(6)  = intg(6) + d1*f3y;  intg(7)  = intg(7) + d2*f3z;
    intg(8)  = intg(8) * d0 * ([g0x, g1x, g2x]*v_f(:,2));
    intg(9)  = intg(9) * d1 * ([g0y, g1y, g2y]*v_f(:,3));
    intg(10) = intg(10)* d2 * ([g0z, g1z, g2z]*v_f(:,1));
   
end

% moltiply by coefficients
intg = intg.*coeff;

% mass
mass = intg(1);

% center of mass
COM(1) = intg(2)/mass;
COM(2) = intg(3)/mass;
COM(3) = intg(4)/mass;

% inertial tensor relative to COM
Ixx = intg(6) + intg(7) - mass* (COM(2).^2.0+COM(3).^2.0);
Iyy = intg(5) + intg(7) - mass* (COM(1).^2.0+COM(3).^2.0);
Izz = intg(5) + intg(6) - mass* (COM(1).^2.0+COM(2).^2.0);
Ixy = -(intg(8)  - mass* COM(1)*COM(2));
Iyz = -(intg(9)  - mass* COM(2)*COM(3));
Ixz = -(intg(10) - mass* COM(1)*COM(3));

% inertial tensor
I = [Ixx     Ixy     Ixz;
    Ixy     Iyy     Iyz;
    Ixz     Iyz     Izz];

% inertial vector (for use in OpenSim
Iv = [Ixx Iyy Izz Ixy Ixz Iyz];

disp(['...Done! Elapsed time ', num2str(toc),' ms.'])

% Collecting all results together
MassProps.mass       = mass;
MassProps.COM        = COM;
MassProps.Imat       = I;
MassProps.Ivec       = Iv;

end


function [f1, f2, f3, g0, g1, g2] = compSubexpression(SingleVert)

w0 = SingleVert(1);
w1 = SingleVert(2);
w2 = SingleVert(3);

temp0 = w0+w1;
temp1 = w0*w0;
temp2 = temp1+w1*temp0;

f1 = temp0+w2;
f2 = temp2+w2*f1;
f3 = w0*temp1+w1*temp2+w2*f2;

g0 = f2 + w0*(f1+w0);
g1 = f2 + w1*(f1+w1);
g2 = f2 + w2*(f1+w2);

end
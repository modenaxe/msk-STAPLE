clear all;

mesh_name = 'R_Femur_6m.stl'
% [v, f, n, c, stltitle] = stlread('R_Femur_6m.stl', 1);
% mesh_name = 'Sphere.stl';

[v, f, n, c, stltitle] = stlread(mesh_name, 1);
density = 1;


% feedback to the user
% I tried a waitbar, but the script was too slow!
display(['Calculating Inertia properties for mesh ', mesh_name]);
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
    [f1y, f2y, f3y, g0y, g1y, g2y] = compSubexpression(v_f(:,2));
    [f1z, f2z, f3z, g0z, g1z, g2z] = compSubexpression(v_f(:,3));

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
mass = intg(1)*density;

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

display('Done!')
display(['Elapsed time ', num2str(toc),' ms.'])
% ----------------------------------------------------------------------- %
%    Author:   Luca Modenese, October 2015                                %
%    email:    l.modenese@sheffield.ac.uk                                 %
% ----------------------------------------------------------------------- %

clear;clc; close all

% import stl file
[v_MRI, f, n, c, stltitle] = stlread('Ellipsoid.stl', 1);

% I want to cut along one of the principal axes of inertia
PointCloud = v_MRI;
InertiaInfo  = calcInertiaMatrix(PointCloud);
v = transfMeshPointsRefSyst(v_MRI, InertiaInfo.COM, InertiaInfo.PrincAxes);
patch('Faces',f,'Vertices',v,'FaceColor','blue'); hold on; grid on; axis equal
plot_refsyst(gca, [0 0 0], eye(3), 5); hold on;axis equal;grid on

% defining the cutting plane
ind = 2; % plane direction
cut = 2;


% TO DO IMPLEMENT BOUNDARIES
% lb = min(v(:,ind));
% up = max(v(:,ind));
% cut = lb+rand*(up-lb);

% search facets with points both above and below the selected plane
% min and max vertex values
f_v_coord = [v(f(:,1),ind), v(f(:,2),ind), v(f(:,3),ind)];
f_min = min(f_v_coord, [],2);
f_max = max(f_v_coord, [],2);
f_intersec_ind = (f_min<cut & f_max>cut);
f_intersec = f(f_intersec_ind,:);

% show patches of interest
% patch('Faces',f_intersec,'Vertices',v,'FaceColor','red'); hold on; grid on; axis equal
patch('Faces',f_intersec,'Vertices',v,'FaceColor','green'); hold on; grid on; axis equal
d = [];
for n_f = 1:size(f_intersec,1)
    
    % identify the triangle
    curr_f_inters_coord =  [v(f_intersec(n_f,1),:); v(f_intersec(n_f,2),:); v(f_intersec(n_f,3),:)];
    below_ind = curr_f_inters_coord(:,ind)<cut;
    c1 = find(below_ind);
    c2 = find(~below_ind);
    if size(c1,1)==1
        
    else
        temp = c2;
        c2 = c1;
        c1 = temp;
    end
    
    %======== linear interpolation =========
    a = curr_f_inters_coord(c1,:);
    % first edge
    b = curr_f_inters_coord(c2(1),:);
    t1 = (cut-a(ind))/(b(ind)-a(ind));
    d1 = t1*(b-a)+a;
    % second edge
    c = curr_f_inters_coord(c2(2),:);
    t2 = (cut-a(ind))/(c(ind)-a(ind));
    d2 = t2*(c-a)+a;
    %plot
    d = [d; d1; d2];
    %========================================
    
    clear a b c d1 t1 t2 d2
    
end

% plots line of cut
plot3(d(:,1), d(:,2),d(:,3),'r-', 'Linewidth', 4);hold on

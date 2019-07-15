% =========================================================================
%    Author: Luca Modenese, September 2015
%    email:    l.modenese@sheffield.ac.uk                                 
% =========================================================================

% Using Femur_r I calculated surface area and volume after each application
% of the Poisson remeshing filter (with decreasing octree accuracy).

% AIM: see the modification of surface and area when Poisson is applied

% FINDINGS: as expected the new "smooth" mesh as smaller surface (less
% "prisms" on the surface) but volume is ~the same (less than 1% smaller).

% original
MeshVolume =  427704.937500;
MeshSurface = 61132.808594;

%poisson1
MeshVolume1 =  428508.531250;
MeshSurface1 = 55468.343750;

% poisson 2
MeshVolume2 =  428937.843750;
MeshSurface2 = 55136.902344;

%Poisson 3
MeshVolume3 = 429414.687500;
MeshSurface3 = 54953.246094;

% delta volume
DVolP(1) = 100*(MeshVolume-MeshVolume1)/MeshVolume;
DVolP(2) = 100*(MeshVolume-MeshVolume2)/MeshVolume;
DVolP(3) = 100*(MeshVolume-MeshVolume3)/MeshVolume;

% delta volume
DSurfP(1) = 100*(MeshSurface-MeshSurface1)/MeshSurface;
DSurfP(2) = 100*(MeshSurface-MeshSurface2)/MeshSurface;
DSurfP(3) = 100*(MeshSurface-MeshSurface3)/MeshSurface;

% plot results
subplot(1,2,1)
plot(1:3,DVolP,'-o'); hold on
xlabel('Poisson mesh reconstr #')
ylabel('Volume variation [%]')
grid on

subplot(1,2,2)
plot(1:3,DSurfP,'-x')
ylabel('Surface variation [%]')
xlabel('Poisson mesh reconstr #')
grid on
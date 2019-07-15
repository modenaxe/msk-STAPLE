%% Example script to explain how to plot your triangulation

close all
clearvars

%% Load Example file
load('Tibia0.mat')

%% Plot Figure(1)
figure()
% Plot the whole tibia, here ProxTib is a Matlab triangulation object
trisurf(ProxTib,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',0.7,'edgecolor','none');
hold on
axis equal

% Plot the identified articular surfaces
trisurf(CS.Morph.EpiTibArtLat,'Facecolor','r','FaceAlpha',1,'edgecolor','none');
trisurf(CS.Morph.EpiTibArtMed,'Facecolor','b','FaceAlpha',1,'edgecolor','none');


% handle lighting of objects
light('Position',CS.Origin' + 500*CS.Y + 500*CS.X,'Style','local')
light('Position',CS.Origin' + 500*CS.Y - 500*CS.X,'Style','local')
light('Position',CS.Origin' - 500*CS.Y + 500*CS.X - 500*CS.Z,'Style','local')
light('Position',CS.Origin' - 500*CS.Y - 500*CS.X + 500*CS.Z,'Style','local')
lighting gouraud

% Remove grid
grid off

%% Plot Figure(2) plot the tibia only without transparency : 'FaceAlpha',1
figure()
trisurf(ProxTib,'Facecolor',[0.65    0.65    0.6290],'FaceAlpha',1,'edgecolor','none');
hold on
axis equal

% handle lighting of objects
light('Position',CS.Origin' + 500*CS.Y + 500*CS.X,'Style','local')
light('Position',CS.Origin' + 500*CS.Y - 500*CS.X,'Style','local')
light('Position',CS.Origin' - 500*CS.Y + 500*CS.X - 500*CS.Z,'Style','local')
light('Position',CS.Origin' - 500*CS.Y - 500*CS.X + 500*CS.Z,'Style','local')
lighting gouraud

% Remove grid and axis
grid off
axis off
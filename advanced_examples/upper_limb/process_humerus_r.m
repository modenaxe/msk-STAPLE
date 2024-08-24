%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%    Author:   Luca Modenese,  2020                                       %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% Script representing a proof of concept of the extensibility of STAPLE to
% the upper limb based on similarity of the humerus with the femur (long
% bone with spherical articular surface on one extremity and condilar
% structure on the other extremity.
% ----------------------------------------------------------------------- %

clear; clc; close all
addpath(genpath('../../STAPLE'));

%----------%
% SETTINGS %
%----------%
% folder where the various datasets (and their geometries) are located.
bones_folder = 'bone_geom';

% names of the bones to process with STAPLE
bones_list = {'humerus_r'};
%--------------------------------------

% folder of the bone geometries in MATLAB format ('tri'/'stl')
tri_folder = fullfile(bones_folder, 'tri');

% create geometry set structure
geom_set = createTriGeomSet(bones_list, tri_folder);

% body side from TriGeomSet
side = 'r';

% process humerus using an algorithm derived by GIBOC_femur
[HumerusCS, HumerusJCS, ~, ArtSurfFem] = GIBOC_humerus(geom_set.humerus_r, side);

% a plot will be shown

% remove paths
rmpath(genpath('STAPLE'));
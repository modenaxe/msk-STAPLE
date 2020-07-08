% MESHREADGMSH reads a .msh file written in ASCII format by GMSH. 
% V are the vertices
% F are the faces
% Function was originally in GIBOC-Knee.
%-------------------------------------------------------------------------%
%  Author:   JB Renault
%  Copyright 2020 JB Renault
%-------------------------------------------------------------------------%
function [v, f] = readGMSH(fileName)

%======================
% GMSH .msh ascii file format
%======================
% ASCII STL files have the following structure.  Technically each facet
% could be any 2D shape, but in practice only triangular facets tend to be
% used.  The present code ONLY works for meshes composed of triangular
% facets.
%
% $MeshFormat
%   mesh format code
% $EndMeshFormat
% $Nodes
%   Number of nodes
%   Node_index x y z
%       ---
%   Node_index x y z
% $EndNodes
% $Elements
%  Number of elements
% 	Element_ID element_type(4 int) Node1_index Node2_index Node3_index
%                           ---
%   Element_ID element_type(4 int) Node1_index Node2_index Node3_index
% $EndElements
%==========================================================================

fstring = fileread(fileName); % read the file as one string
% Separate the file at '$' separator
fblocks = regexp(fstring,'\$[a-zA-Z]+','split'); % $.... as separator

v_raw = textscan(fblocks{4},'%f %f %f %f','delimiter',' ','MultipleDelimsAsOne', 1);
v_raw = horzcat(v_raw{:});

f_raw = textscan(fblocks{6},'%f %f %f %f %f %f %f %f','delimiter',' ','MultipleDelimsAsOne', 1);
f_raw = horzcat(f_raw{:});

% Extract part of the data that we are interested in
v = v_raw(2:end,2:end);
f = f_raw(2:end,6:end);


end
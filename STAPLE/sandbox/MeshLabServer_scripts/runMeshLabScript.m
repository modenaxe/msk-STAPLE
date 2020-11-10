%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L.                                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  %
% ----------------------------------------------------------------------- %
% function that applies a Meshlab script to a an input mesh and writes the
% resulting geometry in output mesh.
% first version 2015
function [status,cmdout] = runMeshLabScript(input_mesh, output_mesh, script)

% inform used
display('           ');
display(['Applying script: ', script]);

% apply filters
tic
string = ['meshlabserver ','-i "',input_mesh , '" -o "', output_mesh, '" -s ', script];

% calling meshlab server
[status,cmdout] = dos(string);

% time estimation
display(['Done in ',num2str(toc)]);

end
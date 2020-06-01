% =========================================================================
%    Author: Luca Modenese, September 2015
%    email:    l.modenese@sheffield.ac.uk                                 
% =========================================================================
% function that applies a Meshlab script to a an input mesh and writes the
% resulting geometry in output mesh.
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
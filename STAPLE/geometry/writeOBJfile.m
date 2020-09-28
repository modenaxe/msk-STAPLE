% WRITEOBJFILE Write a Waterfront .OBJ file from a MATLAB triangulation
% object.
%
%   WRITEOBJFILE(aMatTriObj, aOBJfile)
%
% Inputs:
%   aMatTriObj - a MATLAB triangulation object
%
%   aOBJfile - a file with .OBJ extension, including path. Indicates where
%       the content of the triangulation object file will be printed,
%       usually for visualization purposes.
%
% Outputs:
%   none.
%
%
% See also CREATETRIGEOMSET, REDUCETRIOBJGEOMETRY, LOAD_MESH.
%
%-------------------------------------------------------------------------%
% Author: Luca Modenese 
% email: l.modenese@imperial.ac.uk
% Website: https://github.com/modenaxe/msk-STAPLE
% Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function writeOBJfile(aMatTriObj, aOBJfile)

% Please refer to description of file format:
% http://www.martinreddy.net/gfx/3d/OBJ.spec

% open file
fid = fopen(aOBJfile,'w');

% formats for vertices, normals and faces
format_v = 'v %.5f %.5f %12.8f\n';
format_f = 'f %u %u %u\n';

% NB: vn option COMPLETELY UNTESTED. Left here in case there is need of
% future modifications, as I have seen this in some OBJ files produced by
% other software.
% format_vn = 'vn %.5f %.5f %12.8f\n';

% print
fprintf(fid, format_v, aMatTriObj.Points');

% fprintf(fid, format_vn, aMatTriObj.faceNormal');
fprintf(fid, format_f, aMatTriObj.ConnectivityList');

% close file
fclose(fid);

end

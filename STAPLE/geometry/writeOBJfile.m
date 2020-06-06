function writeOBJfile(aMatTriObj, aOBJfile)

% NB: vn option COMPLETELY UNTESTED. Left here in case there is need of
% future modifications.
% Please refer to description of file format:
% http://www.martinreddy.net/gfx/3d/OBJ.spec

% open file
fid = fopen(aOBJfile,'w');

% formats for vertices, normals and faces
format_v = 'v %.5f %.5f %12.8f\n';
% format_vn = 'vn %.5f %.5f %12.8f\n';
format_f = 'f %u %u %u\n';

% print
fprintf(fid, format_v, aMatTriObj.Points');
% fprintf(fid, format_vn, aMatTriObj.faceNormal');
fprintf(fid, format_f, aMatTriObj.ConnectivityList');

% close file
fclose(fid);

end

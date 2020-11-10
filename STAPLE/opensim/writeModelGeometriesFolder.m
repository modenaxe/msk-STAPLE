% WRITEMODELGEOMETRIESFOLDER Write bone geometry for an automated model in
% the specified geometry folder using a user-defined file format.
%
%   writeModelGeometriesFolder(aTriGeomBoneSet, aGeomFolder, aFileFormat, coeff_reduc)
%
% Inputs:
%   aTriGeomBoneSet - a set of MATLAB triangulation objects generated using the
%       createTriGeomSet function.
%
%   aGeomFolder - the folder where to save the geometries of the automatic
%       OpenSim model.
%
%   aFileFormat - the format to use when writing the bone geometry files.
%       Currently 'stl' files and Waterfront 'obj' files are supported.
%       Note that both formats are ASCII, as required by the OpenSim
%       visualiser.
%
%   coeffFaceReduc - number between 0 and 1 indicating the ratio of faces
%       that the final geometry will have. Default value 0.3, meaning that
%       the geometry files will have 30% of the faces of the original bone
%       geometries. This is required for faster visualization in OpenSim.
%
% Outputs:
%   none - the bone geometries are saved in the specified folder using the
%       specified file format.
%
% See also CREATETRIGEOMSET, LOAD_MESH.
%
%-------------------------------------------------------------------------%
%  Author:   Luca Modenese
%  Copyright 2020 Luca Modenese
%-------------------------------------------------------------------------%

function writeModelGeometriesFolder(aTriGeomBoneSet, aGeomFolder, aFileFormat, coeffFaceReduc)

% all formats are ASCII, as required by the OpenSim visualized
if nargin<3; aFileFormat='obj'; end
if nargin<2; aGeomFolder='.'; end
% reduce geometry for visualization to 30% of faces by default
if nargin<4; coeffFaceReduc = 0.3; end

% create geometry file if not existing
if ~isfolder(aGeomFolder); mkdir(aGeomFolder); end

% ensure lower case fileformat
aFileFormat = lower(aFileFormat);

% how many bones to print?
bone_names = fields(aTriGeomBoneSet);
N_bones = numel(bone_names);

disp('-------------------------------------')
disp('Writing geometries for visualization ')
disp('-------------------------------------')

for nb = 1:N_bones
    cur_bone_name = bone_names{nb};
    cur_tri = aTriGeomBoneSet.(cur_bone_name);
    
    % reduce number of faces in geometry
    cur_tri = reduceTriObjGeometry(cur_tri, coeffFaceReduc);
    
    switch aFileFormat
        case 'obj'
            writeOBJfile(cur_tri, fullfile(aGeomFolder, [cur_bone_name,'.obj']));
        case 'stl'
            % recent versions of Matlab (>2018b) can deal with stl files
            if verLessThan('matlab', '9.5')
                error('writeModelGeometriesFolder.m Please write model geometries as .OBJ files (preferred) or update MATLAB to a version >2018b to write .STL files.');
            else
                stl_format = 'text'; % OpenSim does not read binary format at the moment
                stlwrite(cur_tri, fullfile(aGeomFolder, [cur_bone_name,'.stl']),stl_format);
            end
        otherwise
            error('writeModelGeometriesFolder.m Please specify a file format to write the model geometries between ''stl'' and ''obj''.');
    end
end
% inform the user
disp(['Stored ', aFileFormat ,' files in folder ', aGeomFolder]);
end
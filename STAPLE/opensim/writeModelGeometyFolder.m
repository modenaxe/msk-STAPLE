function writeModelGeometyFolder(aTriGeomBoneSet, aGeomFolder, aFileFormat)

% all formats are ASCII, as required by the OpenSim visualized
if nargin<3; aFileFormat='obj'; end
if nargin<2; aGeomFolder='.'; end

% create geometry file if not existing
if ~isfolder(aGeomFolder); mkdir(aGeomFolder); end

% ensure lower case fileformat
aFileFormat = lower(aFileFormat);

% how many bones to print?
bone_names = fields(aTriGeomBoneSet);
N_bones = numel(bone_names);

for nb = 1:N_bones
    cur_bone_name = bone_names{nb};
    cur_tri = aTriGeomBoneSet.(cur_bone_name);
    % reduce geometry for visualization to 30% of faces
    coeff_reduc = 0.3;
    cur_tri = reduceTriObjGeometry(cur_tri, coeff_reduc);
    switch aFileFormat
        case 'obj'
            writeOBJfile(cur_tri, fullfile(aGeomFolder, [cur_bone_name,'.obj']));
        case 'stl'
            % requires Matlab>2018b
            stlwrite(cur_tri, fullfile(aGeomFolder, [cur_bone_name,'.stl']));
        otherwise
    end
end
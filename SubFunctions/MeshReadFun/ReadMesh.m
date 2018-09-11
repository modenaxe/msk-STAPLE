function [ varargout ] = ReadMesh( varargin )
%READMESH Read meshes and convert them to Triangulation Object
%Each input file will be converted to one triangulation object
%  - varargin : the address(es) of the file(s) to read
%  - varargout : the triangulation(s) generated for each read file 

addpath(strcat(pwd,'\MeshReadFun\stlTools'));
addpath(strcat(pwd,'\MeshReadFun\'));

if nargin ~= nargout
    error('The number of input files read should match the number of output')
end

% Read the mesh of each file
for i = 1 : nargin
    fileName = varargin{i};

    if strcmp(fileName(end-3:end),'.msh') || strcmp(fileName(end-3:end),'.MSH')
        XYZELMTS = py.txt2mtlb.read_meshGMSH(fileName);
        Nodes = [cell2mat(cell(XYZELMTS{'X'}))' cell2mat(cell(XYZELMTS{'Y'}))' cell2mat(cell(XYZELMTS{'Z'}))'];
        Elmts = double([cell2mat(cell(XYZELMTS{'N1'}))' cell2mat(cell(XYZELMTS{'N2'}))' cell2mat(cell(XYZELMTS{'N3'}))']);
    
    elseif strcmp(fileName(end-3:end),'.stl') || strcmp(fileName(end-3:end),'.STL')
        % STL reading is provided in stlTools package 
        % https://fr.mathworks.com/matlabcentral/fileexchange/51200-stltools
       [Nodes, Elmts] = stlRead(fileName);
        
    else 
       error('Only GMSH .msh and .stl files can be read, please ensure your file ends with either') 
       
    end
    
    % Verify that mesh normals are outward-pointing and fix them if not
    Elmts = fixNormals( Nodes, Elmts );
    
    varargout{i} = triangulation(Elmts,Nodes);
    
end

end


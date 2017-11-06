# GIBOC-Knee-Coordinate-System  

![Baniere](https://github.com/renaultJB/GIBOC-Knee-Coordinate-System/blob/master/Other/Images/baniere_Fem_Pat_Tib.jpg "Result examples")

The main goal of this Matlab MATHWORKS® based project is to provide Matlab and Python™ scripts and associated functions to :
1. Read piecewise triangular representation of bones ([.STL Files](https://en.wikipedia.org/wiki/STL_(file_format)))
2. Automatically identify and model important features of the bones to create an anatomical coordinate system
3. Generate an output file containing the coordinate system origin position and the basis vectors orientation in the world coordinate system

## Remeshing of the 3D bone models
For now the bone numerical representation require to be remeshed to 0.5 mm isotropic elements. It can be achieved thanks to [GMSH](http://gmsh.info/), or [3-matic®](http://www.materialise.com/en/software/3-matic) from Materialise®. However, other softwares could perform this operation but we've not tested them:
* HyperMesh Altair
* [MeshLab](http://www.meshlab.net/)  

This first step allows to get a "nicer" mesh of the bone models (For more information see : **[How to generate nice mesh from STL](https://github.com/renaultJB/GIBOC-Knee-Coordinate-System/blob/master/PaperCodes/ExampleData/readme.md)**).  

![Nicer Mesh](https://github.com/renaultJB/GIBOC-Knee-Coordinate-System/blob/master/Other/Images/niceMesh.jpg "Nicer mesh with GMSH")

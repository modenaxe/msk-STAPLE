# GIBOC-Knee-Coordinate-System  

![Baniere](https://github.com/renaultJB/GIBOC-Knee-Coordinate-System/blob/master/Other/Images/baniere_Fem_Pat_Tib.jpg "Result examples")

The main goal of this Matlab MATHWORKS® based project is to provide Matlab and Python™ scripts and associated functions to :
1. Read piecewise triangular representation of bones ([.STL Files](https://en.wikipedia.org/wiki/STL_(file_format)))
2. Automatically identify and model important features of the bones to create an anatomical coordinate system
3. Generate an output file containing the coordinate system origin position and the basis vectors orientation in the world coordinate system

For now the bone numerical representation require to be remeshed to 0.5 mm isotropic elements.

It can be achieved thanks to [GMSH](http://gmsh.info/), associated papers :  

---  
* *C. Geuzaine and J.-F. Remacle. Gmsh: a three-dimensional finite element mesh generator with built-in pre- and post-processing facilities. International Journal for Numerical Methods in Engineering 79(11), pp. 1309-1331, 2009.*  

**Cross-patch and STL meshing (Compounds):**  
* *J.-F. Remacle, C. Geuzaine, G. Compère and E. Marchandise. High-quality surface remeshing using harmonic maps. International Journal for Numerical Methods in Engineering 83(4), pp. 403-425, 2010.*
* *E. Marchandise, C. Carton de Wiart, W. G. Vos, C. Geuzaine and J.-F. Remacle. High quality surface remeshing using harmonic maps. Part II: surfaces with high genus and of large aspect ratio. International Journal for Numerical Methods in Engineering 86(11), pp. 1303-1321, 2011.*
* *E. Marchandise, J.-F. Remacle and C. Geuzaine. Optimal parametrizations for surface remeshing. Engineering with Computers, December 2012, pp. 1-20.* 
---  
Or in [3-matic®](http://www.materialise.com/en/software/3-matic) from Materialise®
Maybe other software can perform this operation but I've not tested them myself:
* HyperMesh Altair
* [MeshLab](http://www.meshlab.net/)  

This first step allows to get a "nicer" mesh of the bone models.  

![Nicer Mesh](https://github.com/renaultJB/GIBOC-Knee-Coordinate-System/blob/master/Other/Images/niceMesh.jpg "Nicer mesh with GMSH")

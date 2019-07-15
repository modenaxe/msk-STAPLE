# How to generate nice ***.msh*** files from ***.stl*** ones

Our methods rely on [GMSH](http://gmsh.info/), **which must be installed in your working folder or added to your os path**, associated papers :  

---  
* *C. Geuzaine and J.-F. Remacle. Gmsh: a three-dimensional finite element mesh generator with built-in pre- and post-processing facilities. International Journal for Numerical Methods in Engineering 79(11), pp. 1309-1331, 2009.*  

**Cross-patch and STL meshing (Compounds):**  
* *J.-F. Remacle, C. Geuzaine, G. Compère and E. Marchandise. High-quality surface remeshing using harmonic maps. International Journal for Numerical Methods in Engineering 83(4), pp. 403-425, 2010.*
* *E. Marchandise, C. Carton de Wiart, W. G. Vos, C. Geuzaine and J.-F. Remacle. High quality surface remeshing using harmonic maps. Part II: surfaces with high genus and of large aspect ratio. International Journal for Numerical Methods in Engineering 86(11), pp. 1303-1321, 2011.*
* *E. Marchandise, J.-F. Remacle and C. Geuzaine. Optimal parametrizations for surface remeshing. Engineering with Computers, December 2012, pp. 1-20.* 
---  

Because, it has the capacity to remesh stl, we developped a **Python** script to remesh all the *.stl* in the current folders.  

### Remeshing with our small python script
To generate the remeshed bone model you need to put all your *.stl* files in the same folder as *[remesh_STL_GMSH.py](https://github.com/renaultJB/GIBOC-Knee-Coordinate-System/blob/master/PaperCodes/ExampleData/remesh_STL_GMSH.py)* (and ***GMSH*** if not added to your os path).  
Then all you have to do (provided you have Python 2.7 installed) is to launch *[remesh_STL_GMSH.py](https://github.com/renaultJB/GIBOC-Knee-Coordinate-System/blob/master/PaperCodes/ExampleData/remesh_STL_GMSH.py)*. You can either remesh all the *.stl* present in the folder or select the one you want to remesh with a small *GUI*.

### Download example files  

An example dataset can be accessed at :  

https://www.dropbox.com/sh/kbapcubgw4cqu63/AACE6_UtbjhlLAKQSN468n-ca?dl=0

or directly downloaded with :  

https://www.dropbox.com/sh/kbapcubgw4cqu63/AACE6_UtbjhlLAKQSN468n-ca?dl=1


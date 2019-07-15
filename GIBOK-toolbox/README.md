# GIBOC-Knee-Coordinate-System  

The full text article associated is available at :
[10.1016/j.jbiomech.2018.08.028](https://doi.org/10.1016/j.jbiomech.2018.08.028)

### **Articular-surface-based automatic anatomical coordinate systems for the knee bones.**

Jean-Baptiste RENAULT<sup>a,b,*</sup>
Gaëtan AÜLLO-RASSER<sup>a,b,d</sup>
Mathias DONNEZ<sup>a,b,c</sup>
Sébastien PARRATTE<sup>a,b</sup>
Patrick CHABRAND<sup>a,b</sup>

<sub>
a. Aix-Marseille University, CNRS, ISM UMR 7287, 13009 Marseille, France;
b. APHM, Institute for Locomotion, Department of orthopaedics and Traumatology, Sainte-Marguerite Hospital, 13009, Marseille, France
c. Newclip Technics, 44115 Haute-Goulaine, France
d. RLC Systèmes, Marseille, France
</sub>

### The code usage has been simplified and you should be able to use it, link to example data are provided in _example.m_ script

- Femur works see example.m to try it
- Tibia works see example.m to try it
- Patella works see example.m to try it
- For now coordinate systems from all variants are systematically computed, at some point it will be changed so that the user can select the method of his choice from those in the paper

Example data can be found [here](https://www.dropbox.com/sh/ciy1fu2k63nqnd4/AACWkJvSHsiA_-9slJBiEEiua?dl=0) or directly downloaded [there](
https://www.dropbox.com/sh/ciy1fu2k63nqnd4/AACWkJvSHsiA_-9slJBiEEiua?dl=1)



**Automatic anatomical coordinate system constructions for the knee bones (Femur, Patella and Tibia)**  
  
  
  
![Baniere](https://github.com/renaultJB/GIBOC-Knee-Coordinate-System/blob/master/Other/Images/baniere_Fem_Pat_Tib.jpg "Result examples")

The main goal of this Matlab MATHWORKS® based project is to provide Matlab and Python™ scripts and associated functions to :
1. Read piecewise triangular representation of bones ([.STL Files](https://en.wikipedia.org/wiki/STL_(file_format)))
2. Automatically identify and model important features of the bones to create an anatomical coordinate system
3. Generate an output file containing the coordinate system origin position and the basis vectors orientation in the world coordinate system

## Remeshing of the 3D bone models
For now the bone numerical representation require to be remeshed to 0.5 mm isotropic elements. It can be achieved thanks to [GMSH](http://gmsh.info/), or [3-matic®](http://www.materialise.com/en/software/3-matic) from Materialise®. However, other softwares could perform this operation but we've not tested them, for example:
* HyperMesh Altair
* [MeshLab](http://www.meshlab.net/)  

This first step allows to get a "nicer" mesh of the bone models (For more information see : **[How to generate nice mesh from STL](https://github.com/renaultJB/GIBOC-Knee-Coordinate-System/wiki/How-to-generate-nice-mesh-files)**).  

![Nicer Mesh](https://github.com/renaultJB/GIBOC-Knee-Coordinate-System/blob/master/Other/Images/niceMesh.jpg "Nicer mesh with GMSH")

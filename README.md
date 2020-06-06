# STAPLE: Shared Tools for Automatic Personalised Lower Extremity models

## Overview
This repository contains a computational tool called STAPLE that we created for 
enabling researchers in the biomechanical field to build models of the lower extremity 
with minimum effort, ideally just clicking `RUN` on a script.

STAPLE requires three-dimensional bone geometries as an input, which are normally segmented from medical images.
It can create models of entire legs or few joints, depending on the available data. 

Currently the tool creates skeletal models but will soon be extended with complete musculoskeletal capabilities.

## Summary of available methods on STAPLE

STAPLE collects some algorithms from the literature and includes other algorithms that we developed on purpose.
The following table includes the methods currently available in STAPLE.

| Bone                 | Rigid Body Name | Joint Coordinate System | Algorithms       |
| ---                  | ---             | ---                     | ---              |
| Pelvis               | pelvis          | ground-pelvis           | STAPLE-Pelvis    |
|                      |                 |                         | Kai-Pelvis       |
| Femur                | femur           | hip child               | Kai-Femur        |
|                      |                 |                         | GIBOC-Femur      |
|					   |                 | knee parent             | Kai-Femur        |
|					   |                 |                         | GIBOC-Spheres    |
|					   |                 |                         | GIBOC-Ellipsoids |
|					   |                 |                         | GIBOC-Cylinder   |
| Tibia+Fibula         | tibia           | knee child              | Kai-Tibia        |
|                      |                 |                         | GIBOC-Ellipse    |
|                      |                 |                         | GIBOC-Plateau    |
|                      |                 | ankle parent            | uses child CS    |
| Patella              | patella         | TBA                     | TBA |
| Talus                | talus           | ankle child             | STAPLE-Talus     |
|                      |                 | subtalar parent         | STAPLE-Talus     |
| Foot bones           | calcn           | subtalar child          | uses parent CS   |
|                      |                 | foot (auxiliary)        | STAPLE-Calcaneus |
| Foot Phalanges       | toes            | TBA                     | TBA |

## Requirements
* MATLAB v2018b or more recent
* OpenSim v4.0 or higher, downloadable from this [website](https://simtk.org/projects/opensim)

## Preliminary settings
* You should ensure that the OpenSim Application Programming Interface (API) for MATLAB are installed and working.
* Add the `STAPLE` folder to your MATLAB path.

# How to use STAPLE for building your own lower extremity models

## Bone geometries for testing and examples
Test geometries are available in the "test_geometries" directory:
* LHDL (CT)
* TLEM2 (MRI)
* TLEM2 (CT)
* JIA (MRI)
* ICL (MRI)
* VAKHUM (CT)
* ULB_VM (CT)
* JIA_ANKLE (MRI)

# Further Development
* Segment mass properties and degrees of freedom of the joint models can easily be customised. 
* The sagittal profile of femoral condyles is available and could be used to personalized knee joint models like Yamaguchi's knee in combination with the automated slope estimation presented by Amirtharaj et al. (2018).

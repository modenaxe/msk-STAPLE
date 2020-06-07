# STAPLE: Shared Tools for Automatic Personalised Lower Extremity models

## Overview
This repository contains a computational tool called STAPLE that we created for 
enabling researchers in the biomechanical field to build models of the lower extremity 
with minimum effort, ideally just clicking `RUN` on a script.

STAPLE requires three-dimensional bone geometries as an input, which are normally segmented from medical images.
It can create models of entire legs or few joints, depending on the available data. 

Currently the tool creates skeletal models but will soon be extended with complete musculoskeletal capabilities.

## Summary of available methods on STAPLE

STAPLE collects some algorithms from the literature and others that we developed on purpose.
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

# Models you can generate using STAPLE
Currently with STAPLE you can generate two kind of models:
1. full lower limb (monolateral) models: they include pelvis, femur, tibia and fibula, talus, calcaneus and foot bones (excluded phalanges)
2. partial models: they include any meaningful combination of the previous bones. For example models of hip, knee and ankle joints can be created as individual models.

# How to use STAPLE
The workflow consists in:
1. segmenting bone geometries from images
2. ensuring that you group them as required (for example using the `flatten mesh layers` filter in MeshLab)
3. 

## Examples of use

Examples of possible modelling sccenarios are provided in the main STAPLE folder. 
You can run the example the examples and adapt them to your own study or data.
More examples will be added in time.


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

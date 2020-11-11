# STAPLE: Shared Tools for Automatic Personalised Lower Extremity models

## Overview
This repository contains a computational tool called STAPLE that we created for 
enabling researchers in the biomechanical field to build models of the lower extremity 
with minimum effort, ideally just clicking `RUN` on a script.

STAPLE requires three-dimensional bone geometries as an input, which are normally segmented from medical images.
It can create models of entire legs or few joints, depending on the available data or research intent. 

Currently the tool creates kinematic and kinetic skeletal models but will soon be extended with complete musculoskeletal capabilities.

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
|                      |                 | ankle parent            | uses child JCS   |
| Patella              | patella         | TBA                     | TBA |
| Talus                | talus           | ankle child             | STAPLE-Talus     |
|                      |                 | subtalar parent         | STAPLE-Talus     |
| Foot bones           | calcn           | subtalar child          | uses parent JCS  |
|                      |                 | foot (auxiliary)        | STAPLE-Foot      |
| Foot Phalanges       | toes            | TBA                     | TBA |

## Requirements
* MATLAB v2018b or more recent
* OpenSim v4.0 or higher, downloadable from this [website](https://simtk.org/projects/opensim)

## Preliminary settings
* OpenSim (v4.0 or higher) Application Programming Interface (API) for MATLAB must be installed and working. Please refer to the [OpenSim documentation](https://simtk-confluence.stanford.edu/display/OpenSim/Scripting+with+Matlab) for instructions about installation.
* Add the `STAPLE` folder, normally locate in `msk-STAPLE\STAPLE` to your MATLAB path.

# Models you can generate using STAPLE
* **Monolateral complete models**: they include pelvis, femur, tibia and fibula, talus, calcaneus and foot bones (excluded phalanges)
* **Partial models**: they are a subset of a complete model and include any meaningful combination of the previous bones. 
For example models of hip, knee and ankle joints can be created as individual models.

![partial_models](./images/partial_osim_models.png)

# How to use STAPLE

## Quick guide 
The typical STAPLE workflow consists in:
1. **segmenting bone geometries** from medical images, normally computed tomography (CT) or magnetic resonance imaging (MRI) scans. 
This step is not performed using in STAPLE but using third-party segmentation software, of which you can find a list at [this link](https://github.com/modenaxe/awesome-biomechanics#segmentation-of-medical-images-art).
The bone geometries are normally exported as surface models in [STL format](https://en.wikipedia.org/wiki/STL_(file_format)).
2. **improving the quality of the segmentated bone geometries**, normally running filters on the surface models to improve their quality and topology. Also in this case, there are several options to process the geometries and a list of software is available at at [this link](https://github.com/modenaxe/awesome-biomechanics#manipulation-processing-and-comparison-of-surface-meshes).
Individual bones are also grouped at this stage, for example the surface meshes of tibia and fibula can be joined using the `flatten mesh layers` filter in [MeshLab](https://www.meshlab.net/).
3. **renaming bone geometries (optional)**: the surface meshes are renamed following the typical names of standard OpenSim models. This is an optional step, if not performed then you will have to modify some of the low level function settings.
4. **convert geometries to MATLAB triangulations (optional)**: this step is suggested to reduce the size of files and increase speed of input reading. STAPLE can also read `stl` file in input.
5. **store bone geometries**and saved in a folder with an appropriate name. The last step is especially important for batch processing, please see folder setup in the provided examples.
6. **Check the provided examples** demonstrating the use or functionality closer to what you want to do. You can probably use the example as starting point for setting up your own workflow.

## Detailed explanation

![STAPLE_workflow](./images/STAPLE_overview.png)

## Provided examples
Examples of possible modelling scenarios are provided in the main STAPLE folder. You can run the examples and adapt them to your own study or data. Additional examples will be added in time.
* creating full lower limb models (monolateral)
* creating partial models
* extracting articular surfaces
 
## Bone geometries for testing and examples
Bone geometries of public domain are available in the "test_geometries" directory for testing and development purposes:
* LHDL-CT
* TLEM2: there are 3 version of this dataset:
    * TLEM2-MRI
	* TLEM2-CT
	* TLEM2: lower limb bones released with the TLEM2 musculoskeletal model of [Carbone et al. (2015)](https://doi.org/10.1016/j.jbiomech.2014.12.034).
* JIA-MRI
* JIA-ANKLE-MRI
* ICL-MRI
* VAKHUM-CT


# Further Development
* Segment mass properties and degrees of freedom of the joint models can easily be customised. 
* The sagittal profile of femoral condyles is available and could be used to personalized knee joint models like Yamaguchi's knee in combination with the automated slope estimation presented by Amirtharaj et al. (2018).

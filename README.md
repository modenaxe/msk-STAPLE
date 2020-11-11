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

## Detailed explanations

### Overview of STAPLE internal workflow
![STAPLE_workflow](./images/STAPLE_overview.png)

### Detailed steps to setup a STAPLE workflow
This is a checklist to fullfill for setting up a functioning workflow using STAPLE:
- [ ] define dataset
- [ ] define cell array with names of bones to process. The same names will be used for the rigid bodies
- [ ] define body side if not evident from bone names.
- [ ] decide the workflow to use for joint definitions
- [ ] use `createTriGeomSet.m` for crearing a set of triangulated objects 
- [ ] use `writeModelGeometriesFolder.m` to the visualization geometries for your model. You can specify the format (`obj` preferred) and the level of subsampling of the original surface models.
- [ ] use `initializeOpenSimModel.m` to start building the OpenSim model.
- [ ] use `addBodiesFromTriGeomBoneSet` to create bodies corresponding to the fields of the `TriGeomSet` structure created using `createTriGeomSet.m`. These bodies will be added to the OpenSim model, but will not be connected by joints. If you write the model at this stage all bodies will be connected to `Ground`. **NOTE:** the bodies will have mass properties calculated from the bone geometries using a bone density of 1.42 g/cm^3 as in [Dumas et al. (2015)](https://doi.org/10.1109/TBME.2005.855711). 
- [ ] use `processTriGeomBoneSet.m` to process the bone geometries using the available algorithms and extract body coordinate systems, joint coordinate systems and bone landmarks. This step does not rely on the OpenSim API and consists of a morphological analysis of the bone shapes.
- [ ] use `createLowerLimbJoints.m` to connect the OpenSim rigid bodies using joints defined by the reference systems identified by `processTriGeomBoneSet.m`. The joint reference systems can be used in different ways to create a lower limb model. We provide two options: `Modenese2018` based on a previous publication of [Modenese et al. (2018)](https://doi.org/10.1016/j.jbiomech.2018.03.039) and a default approach. The main difference is that `Modenese2018` does not use axis from the tibia bones, while the default approach does.
- [ ] (optional) use `assignMassPropsToSegments.m` to update the mass properties of the segment based on the actual anthropometry of the subject that you are modelling. **NOTE:** this feature is still basic and in development.
- [ ] (optional) use `addBoneLandmarksAsMarkers.m` to include in the OpenSim model also the bony landmarks identified automatically during the morphological analyses.
- [ ] finalise the OpenSim model using the standard `osimModel.finalizeConnections()` method.

### Reference System Conventions [WIP]
The final reference systems are always consistent with ISB but the internal ones not necessarily because they rely on the external functions taken from GIBOC-core.

### Other tips
As a general guidelines, in plots the colors are generally used as follows:
* red: medial
* blue: lateral
* green: not compartimentalised anatomical structures - basically the rest.

To batch process, you can use most of the provided scripts if you organised your folders and files as follows:
```bash
study_folder --|
			   |- dataset_1_folder --|
									 |- tri --|
											  |- pelvis_no_sacrum.mat
											  |- femur_r.mat
											  |- etc.
									 |- stl --|
											  |- pelvis_no_sacrum.stl
											  |- femur_r.stl
											  |- etc.
			   |- dataset_2_folder --|
									 |- tri --|
											  |- pelvis_no_sacrum.mat
											  |- femur_r.mat
											  |- etc.
										
									 |- stl --|
											  |- pelvis_no_sacrum.stl
											  |- femur_r.stl
											  |- etc.
```
where:
* `study_folder` is the main folder of the current study
* `dataset_1_folder` is where the bone geometries for the first dataset/partecipant data are stored
* `dataset_2_folder` is where the bone geometries for the second dataset/partecipant data are stored, and so on.

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

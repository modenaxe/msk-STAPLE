# STAPLE: Shared Tools for Automatic Personalised Lower Extremity modelling <!-- omit in toc -->

# Table of contents <!-- omit in toc -->
- [What is STAPLE?](#what-is-staple)
- [What can I do with STAPLE?](#what-can-i-do-with-staple)
- [Requirements and set up](#requirements-and-set-up)
- [How to use the STAPLE toolbox](#how-to-use-the-staple-toolbox)
  - [Workflow to generate subject-specific lower limb models](#workflow-to-generate-subject-specific-lower-limb-models)
  - [Preliminary steps and data preparation](#preliminary-steps-and-data-preparation)
  - [Detailed steps to setup a STAPLE workflow](#detailed-steps-to-setup-a-staple-workflow)
  - [Available algorithms for bone morphological analysis](#available-algorithms-for-bone-morphological-analysis)
  - [Provided examples](#provided-examples)
  - [Datasets available for testing](#datasets-available-for-testing)
  - [Further notes on STAPLE](#further-notes-on-staple)
- [Does STAPLE work only with OpenSim?](#does-staple-work-only-with-opensim)
- [How to contribute](#how-to-contributing)
- [Current limitations](#current-limitations)
- [Acknowledgements](#acknowledgements)

## What is STAPLE?
STAPLE, acronym for _Shared Tools for Automatic Personalised Lower Extremity modelling_, is a MATLAB toolbox that aims to enable researchers in the biomechanical field to create models of the lower extremity from subject-specific bone geometries with minimum effort in negligible processing time, ideally just running a script where few settings are specified.

STAPLE requires three-dimensional bone geometries as an input. These geometries are normally surface models segmented from medical images like magnetic resonance imaging (MRI) or computed tomography (CT) scans. STAPLE performs morphological analyses on the bone geometries and defines reference systems used to create models of entire legs or few joints, depending on the available data or the research intent. Currently the toolbox creates kinematic and kinetic skeletal models but will soon be extended with complete musculoskeletal capabilities. 

The STAPLE toolbox and some of its applications are described in [the following preprint](https://doi.org/10.1101/2020.06.23.162727):
```bibtex
@article{Modenese2020auto,
  title={Automatic Generation of Personalized Skeletal Models of the Lower Limb from Three-Dimensional Bone Geometries},
  author={Modenese, Luca and Renault, Jean-Baptiste},
  journal={bioRxiv},
  year={2020},
  doi={https://doi.org/10.1101/2020.06.23.162727}
}
```
The models, simulations and results of the publication can be fully reproduced using the scripts and datasets available in [this GitHub repository](https://github.com/modenaxe/auto-lowerlimb-models-paper).


## What can I do with STAPLE?

* **Creating complete skeletal models of the lower limb from segmented bone geometries**: they include pelvis, femur, tibia and fibula, talus, calcaneus and foot bones (excluded phalanges for now).

![complete_model](./images/complete_osim_model.png)

* **Creating partial skeletal models of the lower limb**: they are a subset of a complete lower limb model and include any meaningful combination of bones listed for the complete model. 
For example models of hip, knee and ankle joints can be created as individual models.

![partial_models](./images/partial_osim_models.png)

* **Extract the articular surfaces of the lower limb joints**: some of the algorithms included in STAPLE can identify the articular surfaces of the lower limb joints and export them for you.

![articular_surfaces](./images/artic_surfaces.png)

* **Basic identification of bony landmarks**: certain bony landmarks can be easily identified following the morphological analysis of the bone surfaces. These landmarks are intended as first guess for registration with gait analysis data.

## Requirements and set up

In order to use the STAPLE toolbox you will need:
1. MATLAB R2018b or more recent installed in your machine.
2. [OpenSim 4.1](https://simtk.org/projects/opensim) installed in your machine.
3. the OpenSim 4.1 API for MATLAB correctly setup and working. Required to run the provided scripts. Please refer to the [OpenSim documentation](https://simtk-confluence.stanford.edu/display/OpenSim/Scripting+with+Matlab) for instructions about installation.
* download the latest version of STAPLE from [the SimTK project page](https://simtk.org/projects/msk-staple).
* (optional) if you want to contribute to the development of the toolbox, you can clone the GitHub repository using [Git](https://git-scm.com/):
```bash
git clone https://github.com/modenaxe/msk-STAPLE
```
4. add the `STAPLE` folder, normally locate in `msk-STAPLE\STAPLE` to your MATLAB path. This is optional as long as you are using the provided examples.


## How to use the STAPLE toolbox

### Workflow to generate subject-specific lower limb models

The figure below presents a possible workflow for the generation of subject-specific (or patient-specific) lower limb models. The operations handled by the STAPLE toolbox are grouped within the red box. 

![STAPLE_workflow](./images/STAPLE_overview.png)


### Preliminary steps and data preparation

The typical STAPLE workflow consists in:

1. **segmenting bone geometries** from medical images, normally computed tomography (CT) or magnetic resonance imaging (MRI) scans. 
This step is not performed using in STAPLE but using third-party segmentation software, of which you can find a list at [this link](https://github.com/modenaxe/awesome-biomechanics#segmentation-of-medical-images-art).
The bone geometries are normally exported as surface models in [STL format](https://en.wikipedia.org/wiki/STL_(file_format)).

2. **improving the quality of the segmentated bone geometries**, normally running filters on the surface models to improve their quality and topology. Also in this case, there are several options to process the geometries and a list of software is available at at [this link](https://github.com/modenaxe/awesome-biomechanics#manipulation-processing-and-comparison-of-surface-meshes).
Individual bones are also grouped at this stage, for example the surface meshes of tibia and fibula can be joined using the `flatten mesh layers` filter in [MeshLab](https://www.meshlab.net/).

3. **renaming bone geometries (optional)**: the surface meshes are renamed following the typical names of standard OpenSim models. This is an optional step, if not performed then you will have to modify some of the low level function settings.

4. **convert geometries to MATLAB triangulations (optional)**: this step is suggested to reduce the size of files and increase speed of input reading if you are processing a dataset more than once. STAPLE can also read `stl` file in input.

5. **store bone geometries** and saved them in folders with an appropriate name. The last step is especially important for batch processing. The provided scripts are organised as follows:
```bash
study_folder
        |- dataset_1_folder
                        |- tri
                            |- pelvis_no_sacrum.mat
                            |- femur_r.mat
                            |- etc.
							
                        |- stl
                            |- pelvis_no_sacrum.stl
                            |- femur_r.stl
                            |- etc.
							
        |- dataset_2_folder
                        |- tri
                            |- pelvis_no_sacrum.mat
                            |- femur_r.mat
                            |- etc.
							
                        |- stl
                            |- pelvis_no_sacrum.stl
                            |- femur_r.stl
                            |- etc.
```
where:
* `study_folder` is the main folder of the current study
* `dataset_1_folder` is where the bone geometries for the first partecipant data are stored
* `dataset_2_folder` is where the bone geometries for the second partecipant data are stored, and so on. 

6. **implement your own workflow** based on the checklist below. If there is a provided example demonstrating a use similar to your intended one, probably you can use it as starting point.


### Detailed steps to setup a STAPLE workflow

This is a checklist for setting up a functioning workflow using STAPLE:
- [ ] define the dataset to process after 
- [ ] define a cell array with names of bones to process. The same names will be used for the rigid bodies
- [ ] define body side if not evident from bone names.
- [ ] decide the joint definitions (`workflow` variable in the examples).
- [ ] use `createTriGeomSet.m` for creating a set of MATLAB triangulation objects (`TriGeomSet` structure).
- [ ] use `writeModelGeometriesFolder.m` to write the visualization geometry files for your model. You can specify the format (`obj` preferred, as more compact) and the level of subsampling of the original surface models (30% by default).
- [ ] use `initializeOpenSimModel.m` to start building the OpenSim model.
- [ ] use `addBodiesFromTriGeomBoneSet` to create bodies corresponding to the fields of the `TriGeomSet` structure. These bodies will be added to the OpenSim model, but are not yet connected by joints. If you print the model at this stage all bodies will be connected to `Ground` with free joints. **NOTE:** the assigned segment mass properties are those calculated from the bone geometries using a bone density of 1.42 g/cm^3 as in [Dumas et al. (2015)](https://doi.org/10.1109/TBME.2005.855711). 
- [ ] use `processTriGeomBoneSet.m` to process the bone geometries using the available algorithms and extract body coordinate systems (`CS`), joint coordinate systems (`JCS`) and bone landmarks (`BL`). This step does not rely on the OpenSim API and consists of a morphological analysis of the bone shapes performed using the algorithms available in STAPLE and listed in the Table below.
- [ ] use `createLowerLimbJoints.m` to connect the OpenSim rigid bodies with joints defined using the `JCS` reference systems identified by `processTriGeomBoneSet.m`. The `JCS`s can be used in different ways to define the lower limb joints. We provide two options: `Modenese2018` based on a previous publication of [Modenese et al. (2018)](https://doi.org/10.1016/j.jbiomech.2018.03.039) and a default approach. The main difference is that `Modenese2018` does not rely on anatomical axes calculated from the tibia bone, while the default approach does.
- [ ] (optional) use `assignMassPropsToSegments.m` to update the mass properties of the segment using the the actual anthropometry of the subject that you are modelling. Segment masses and inertias of the lower limb are scaled from those of the standard `gait2392` OpenSim model, which are identical to those of the more recent Rajagopal full body model. **NOTE:** this feature is still very basic in its implementation and will be modified.
- [ ] (optional) use `addBoneLandmarksAsMarkers.m` to add to the OpenSim models the bony landmarks identified automatically during the morphological analyses.
- [ ] finalise the OpenSim model using the `osimModel.finalizeConnections()`  API method.
- [ ] (optional) print the OpenSim model using the `osimModel.print(model_path\model_name.osim)` API method.
- [ ] use the obtained model for your biomechanical analyses.

### Available algorithms for bone morphological analysis

STAPLE collects some algorithms described in the literature and others that we developed _ad hoc_. The following table lists the algorithms currently available in this repository.


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

The details of the algorithms are described in the following publications:
* GIBOC-algorithms: [Renault et al. (2018)](https://doi.org/10.1016/j.jbiomech.2018.08.028)
* Kai algorithms: [Kai et al. (2014)](https://doi.org/10.1016/j.jbiomech.2013.12.013)
* STAPLE algorithms: [Modenese and Renault (2020)](https://doi.org/10.1101/2020.06.23.162727) 

Please note that STAPLE includes a minimal version of `GIBOC`, renamed `GIBOC-core`. You can download or inspect the original GIBOC-knee toolbox published by [Renault et al. (2018)](https://doi.org/10.1016/j.jbiomech.2018.08.028) at [this link](https://github.com/renaultJB/GIBOC-Knee-Coordinate-System).

### Provided examples

Examples of possible modelling scenarios are provided in the main STAPLE folder. You can run the examples and adapt them to your own study or data. Additional examples will be added in time.

| Script name | Script action | Demonstrated feature |
| --- | --- | --- |
| Example_create_kinetic_models.m | creates automatically OpenSim model using the bone geometries in the `dataset_geometries` folder. These are kinetic models. | Same datasets from the paper of [Modenese et al. (2020)](https://doi.org/10.1101/2020.06.23.162727). |
| Example_full_leg_left.m | creates OpenSim model of the right lower limb from datasets | Full workflow; batch processing. |
| Example_full_leg_right.m | creates OpenSim model of the right lower limb from datasets | Full workflow; batch processing. |
| Example_hip_model.m | creates a hip joint model | Partial model (hip). |
| Example_knee_model.m | creates a knee joint model | Partial model (knee). |
| Example_ankle_model.m | creates an ankle joint model | Partial model (ankle). Based on JIA-MRI data. |
| Example_extract_tibiofem_artic_surf.m | extracts tibiofemoral articular surfaces | Articular surface extraction. | 
| Example_extract_ankle_artic_surf.m | extracts talocrural and subtalar articular surfaces | Articular surface extraction. | 


### Datasets available for testing

Datasets of bone geometries available in the "datasets_folder" directory for testing and development purposes are listed in the following table. Details describing the data and, when specified, its license, are included in each dataset folders.


| Dataset       | Gender | Age | Height |  Mass | Mesh Quality | Reference publication   | Notes |
| ---           | ---    | --- | ---    |---    |---           |---                      |---
| LHDL-CT       |   F    |  78 |  1.71  | 64    |  Very Good   | [Viceconti et al. (2008)](https://doi.org/10.2170/physiolsci.RP009908) |  |
| TLEM2         |   M    |  85 |  N/A   | 45    |  Fair        | [Carbone et al. (2015)](https://doi.org/10.1016/j.jbiomech.2014.12.034)  | Released with the TLEM2 musculoskeletal model. |
| TLEM2-MRI     |   M    |  85 |  N/A   | 45    |  Fair        | [Carbone et al. (2015)](https://doi.org/10.1016/j.jbiomech.2014.12.034)  | Geometries from the TLEM2 specimen's MRI scans. Bilateral |
| TLEM2-CT      |   M    |  85 |  N/A   | 45    |  Good        | [Carbone et al. (2015)](https://doi.org/10.1016/j.jbiomech.2014.12.034)  | Geometries from the TLEM2 specimen's CT scans. Bilateral. |
| ICL-MRI		|   M    |  38 | 1.80   | 87    |  Fair        | [Modenese et al. (2020)](https://doi.org/10.1101/2020.06.23.162727)  |  |
| JIA-MRI   	|   M    |  14 | 1.74   | 76.5  |  Low         | [Montefiori et al. 2019a](https://link.springer.com/article/10.1007/s10439-019-02287-0) |  |
| JIA-ANKLE-MRI |   M    | N/A |  N/A   | N/A   |  Low         | [Montefiori et al. 2019b](https://doi.org/10.1016/j.jbiomech.2018.12.041) | Data from supplementary materials |
| VAKHUM-CT		|   M    | N/A | N/A    | N/A   |  Fair        | [Van Sint Jan (2006)](https://doi.org/10.1080/14639220412331529591) | Bones from two CT scans. STAPLE cannot create a full lower limb. | 


### Further notes on STAPLE

These notes are provided to offer a minimal guidance to anyone that will investigate the STAPLE code in details:

* Reference system conventions: the output reference systems of all STAPLE scripts have axes consistent with [conventions of the International Society of Biomechanics](https://doi.org/10.1016/0021-9290(95)00017-C), but internally this is not always the case. In many algorithms, technical reference systems mutuated from GIBOC-core are used. These reference systems are defined according to the following convention: 
    * `X` directed in anterior-posterior direction, pointing posteriorly, 
    * `Y` directed in medio-lateral direction, pointing laterally for the right leg, 
    * `Z` directed in proximal-distal direction, pointing cranially.

* When an error or some unexplained interruption of the scripts happens during a morphological analysis, it is always possible to enable `debug_plots` and reconstruct step-by-step what the algorithm of interest is doing. As a general guidelines (**not always respected**), the colors of points, surfaces etc. were generally decided following the following convention:
   * `red`: medial
   * `blue`: lateral
   * `green`: not compartimentalised anatomical structures (basically the rest).

## Does STAPLE work only with OpenSim?

The algorithms collected in the STAPLE toolbox were proposed in publications that did not have modelling focus, and can be applied in broader contexts, such as reference system definition for orthopaedics applications or modelling in other platforms. Similarly, the outputs of a STAPLE workflow, e.g. from `processTriGeomBoneSet.m`, include all the necessary information to create a kinematic or kinetic model in any biomechanical modelling workflow. All our modelling examples, however, rely on OpenSim.

## How-to-contribute
We welcome any contribution from the biomechanical and open source community, in any form. You can report a bug, submit code implementing a new feature or fixing an issue or share your ideas about new functionalities that you would like to see included in STAPLE. See below few tips for contributing:
* To **report a bug**, or anomalous behaviour of the toolbox, please open an issue [on this page](https://github.com/modenaxe/msk-STAPLE/issues). Ideally, if you could make the issue reproducile with some data that you can share with us.
* To **contributing to the project with new code** please use a standard [GitHub workflow](https://guides.github.com/activities/forking/):
   1. fork this repository
   2. create your own branch, where you make your modifications and improvements
   3. once you are happy with the new feature that you have implemented you can create a pull request
   4. we will review your code and potentially include it in the main repository. 
* To propose **feature requests**, please open an issue [on this page](https://github.com/modenaxe/msk-STAPLE/issues), label it as `feature request` using the `Labels` panel on the right and describe your desired new feature. We will review the proposal regularly but work on them depending on the planned development. 

## Current limitations 
* The STAPLE toolbox is still in strong development, so some **key documentation might be missing**. Please refer to the examples included the main STAPLE repository for now.
* **STAPLE cannot create models from bones reconstructed from images that have more than one reference system** (see provided VAKHUM_CT dataset as an example). This is due to the fact that each STAPLE morphological analysis is local to the bone where it is performed and therefore the only information about the relative position of the bones comes from the medical scans resting pose. It is possible to implement workarounds to this issue, e.g. using an _a priori_ model of the joints for which the resting pose is not avaible.
* The lower limb models currently include a patella rigidly attached to the tibia. An articulated **patellofemoral joint is under development**.

## Acknowledgements
Luca Modenese was supported by an Imperial College Research Fellowship granted by Imperial College London and by an Academy of Medical Sciences Springboard Grant [SBF004\1056] supported by the Academy of Medical Sciences, the British Heart Foundation, Diabetes UK, the Global Challenges Research Fund, the Government Department for Business, Energy and Industrial Strategy and the Wellcome Trust.

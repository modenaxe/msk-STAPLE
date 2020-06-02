# auto-msk-model
repository to develop automated methods for generating musculoskeletal models from segmented anatomical structures

# Plan
The MSK models are built using the following approaches:

# Summary of implemented methods

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


# Requirements
Requires:
* MATLAB 2017a or more recent
* OpenSim v4.0 or higher

# Test geometries
Test geometries are available for developers (DO NOT REDISTRIBUTE!) at [this link](https://www.dropbox.com/sh/wk4izo66qxbxp3h/AABAcyxpHkfWy1v5AjJ7QOIYa?dl=0).
You can simply copy them in the "test_geometries" directory and adapt the scripts.

# Further Development
* Segment mass properties and degrees of freedom of the joint models can easily be customised. 
* The sagittal profile of femoral condyles is available and could be used to personalized knee joint models like Yamaguchi's knee in combination with the automated slope estimation presented by Amirtharaj et al. (2018).

# Merging a personalized model created with STAPLE and a generic OpenSim model.

## STAPLE merging tools

The STAPLE toolbox provides basic tools for merging partial personalized models with generic OpenSim musculoskeletal models. 

## Steps to Merge a generic musculoskeletal model and a subject-specific foot model

As an example we will merge the ankle model created in one of the STAPLE main examples (`example_auto2020_ankle_R.osim`) with the popular `gait2392.osim` generic model shared with the OpenSim distribution. Please note that the generic model has been scaled to roughly match the foot length of the personalize foot model.

These are the main steps for merging the two models:

1. Have the topology of the models very clear. You can use the OpenSim graphical interface, `Window > Topology View` to visualize the bodies and joints of the models that you want to merge. Identify which body you want to connect in the base model and in the personalized model.

2. Once you have identified where in the kinetic chain you want to merge the model, ensure that there are no bodies with the same name (in this example both models have a `tibia_r` body). You can use `renameBodyAndAdjustOpenSimModel.m` for renaming a body in a model and adjust all its internal dependencies. In this example we renamed the `tibia_r` model from the MRI-based model to `tibia_MRI_r`.

3. Extract (or calculate) all the necessary parameters for defining the joint that you want to use to link the two models (see documentation of `createCustomJointFromStruct.m`). In this specific case, we assume that the partial (MRI-based) and entire (generic) tibia bodies have a local reference system good enough for an initial alignment of the joint connecting the models.

4. use `reduceOpenSimModel.m` to modify the topology of the models to join so that all references to bodies not compatible with the new multi-body topology will be removed (including joints, markers, muscle segments etc.). In this example, the MRI-based foot model will be disjointed from `ground` and everything below the body `tibia_r` will be removed from the generic scaled gait2392 model.

5. merge the models using `mergeOpenSimModels.m`, which relies on `mergeOpenSimSets.m` to clone model component of the partial model to the generic base model. 

6. Now we can create the joint to link the two models because all its parts are available in a unique model. Here I have created a CustomJoint that leaves two degrees of freedom `merge_adj_transY` and `merge_adj_rotZ` in the model for adjusting manually the relative position of the MRI-based partial tibia with respect to the complete generic tibia.

7. Finalize model connections and print the output model.

8. There will be some optional manual adjustments. Here I have adjusted the default `ankle_r_angle` (4 degrees) and locked the CustomJoint to values that visually overlap the bone geometries. My adjusted model is available as `final_STAPLEfoot+gait2392.osim`.

# Final considerations
This is an example for demonstrating the functionalities of the STAPLE toolbox. It is recommended to define the joint parameters using a registration technique, e.g. Iterative Closest Point, or another method appropriate for the available data and current research question. The aim is, as usual, reducing the operator interventions to the minimum.
Points for further development or thought are:
* replacing the CustomJoint with a weld joint
* modifying the mass of the partial tibia to minimize its dynamic effects (can be zero if the models are merged using a WeldJoint).
* making the mass parameters of right (personalized) and left (generic) distal lower extremity equal.


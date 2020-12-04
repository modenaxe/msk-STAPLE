## Creating custom joint definition: a knee joint with 3 degrees of freedom

### How STAPLE creates OpenSim joints

STAPLE creates joints using structures with the following fields:

```
% fields assigned in jointParamFile
JointParamsStruct.jointName
JointParamsStruct.parentName
JointParamsStruct.childName
JointParamsStruct.coordsNames
JointParamsStruct.coordsTypes
JointParamsStruct.coordRanges
JointParamsStruct.rotationAxes
%----------------------------------
% fields assigned in joint_defs files 
% and morphological analysis (JCS structure)
JointParamsStruct.parent_location
JointParamsStruct.parent_orientation
JointParamsStruct.child_location
JointParamsStruct.child_orientation
```

The first block of fields above is defined using the instructions 
in the `jointParamFile` file assigned as input in `createOpenSimModelJoints.m`.
The `jointParamFile` is an input of the `createOpenSimModelJoints.m` function.
```
% create joints
createOpenSimModelJoints(osimModel, JCS, joint_defs, jointParamFile)
```

The second block of fields are computed from bone morphological analysis and 
completed, if necessary, by `joint_defs` scripts, such as `jointDefinitions_auto2020.m`, 
which is also an input of the `createOpenSimModelJoints.m` function.

Here we are working with the first block of fields, defining the degrees of freedom (`DoFs`) of a joint, 
and we want to create a lower limb model with a 3 DoF knee joint.


### STEP1: Creating a custom `getJointParams` file

To create a 3 DoF knee model we just need to create a new  `jointParamFile`.
We can just copy the `getJointParams.m` contents on a new file and call it
`getJointParams3DoFKnee.m`, for example. 

We can then modify the definition of the knee joint as follows:

```
case ['knee_', side]
JointParamsStruct.jointName          = ['knee_', side];
JointParamsStruct.parentName         = ['femur_', side];
JointParamsStruct.childName          = ['tibia_', side];
JointParamsStruct.coordsNames        = {['knee_angle_', side], ['knee_varus_', side], ['knee_rotation_', side]};
JointParamsStruct.coordsTypes        = {'rotational', 'rotational', 'rotational'};
JointParamsStruct.coordRanges        = {[-120 10], [-20 20], [-30 30]};
JointParamsStruct.rotationAxes       = 'zxy';  
```

This is it! 

### STEP2: Using a custom `getJointParams` file

Now we need to tell `createOpenSimModelJoints.m` to use the new joint definitions.
That is as easy as specifying a new input in the main script:

```
createOpenSimModelJoints(osimModel, JCS, joint_defs, `getJointParams3DoFKnee.m`);
```

Now, internally, `createOpenSimModelJoints.m` will use the new file to read 
the fields defining the model joints.

The lower limb model will be generated and include a 3 DoF knee joint!


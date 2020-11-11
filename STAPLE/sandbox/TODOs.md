# STAPLE TASKS BEFORE RELEASE

## Functions to integrate to have bones with ISB reference systems. 
This must be done after fixing CS for all segments.
- [ ] transformTriGeomSet needs testing
- [ ] writeTransformedBoneGeom needs integration in pipeline

## Priority: make a consistent interface for functions
- [x] process left side
- [ ] uniform variable names, they are still changing across scripts.
- [ ] landmarkTriGeomBone: requires a check AFTER the dimensionality of Origin is decided.
- [ ] Dimensionality of Origin: same as OpenSim

## mass properties
- [ ] mapGait2392MassPropToModel check equivalence of segment names
- [ ] scaleMassProps double check that the use of the mass coeff is correct. Validate with opensim
- [ ] verify that bone_inertia = boneMassProps.Ivec * density * dim_fact^2.0

## geometry
- [x] test writing stl geometries
- [x] integrate a writeSTL at some point -> integrated MATLAB stlfunction
- [x] getBoneLandmarkList needs left side bones
- [x] better to have createBOdyFromTriGeomObj and then add the body in addBodiesFromTriGeomBoneSet -> I have decided for another approach. Implemented.
- [x] ADDBODYFROMTRIGEOMOBJ remove ArrayDouble.createVec3 -> originally to remove dependency from OpenSim API. Change of plans
- [x] check in addBoneLandmarksAsMarkers if the cur_body_name corresponds to a body
- [X] test reading from stl geometries -> TLEM2


# Optional
- [ ] getJointParams, createCustomJointFromStruct: .parent, .child change them to .childName, .parentName
- [ ] maybe it would be better to have a single function dealing with all the visualizations.
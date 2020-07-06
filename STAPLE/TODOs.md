# Identified tasks

- [ ] 0) uniform variable names, they are still changing across scripts.
- [ ] 1) getBoneLandmarkList needs left side bones
- [ ] 2) transformTriGeomSet needs testing
- [ ] 3) writeTransformedBoneGeom needs integration in pipeline
- [ ] 4) integrate a writeSTL at some point
- [ ] 5) landmarkTriGeomBone: requires a check AFTER the dimensionality of Origin is decided.
- [ ] 6) getJointParams, createCustomJointFromStruct: .parent, .child change them to .childName, .parentName
- [ ] 7) better to have createBOdyFromTriGeomObj and then add the body in addBodiesFromTriGeomBoneSet
- [ ] 8) maybe it would be better to have a single function dealing with all the visualization.
- [ ] 9) check in addBoneLandmarksAsMarkers if the cur_body_name corresponds to a body
- [ ] 10) mapGait2392MassPropToModel check equivalence of segment names
- [ ] 11) scaleMassProps double check that the use of the mass coeff is correct. Validate with opensim
- [ ] 12) ADDBODYFROMTRIGEOMOBJ remove ArrayDouble.createVec3
- [ ] 13) verify that bone_inertia = boneMassProps.Ivec * density * dim_fact^2.0
# Dimensionality of Origin: same as OpenSim

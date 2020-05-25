## Analysis of the results

---
Matlab and R dependencies :  
+ [Quaternion functions](https://fr.mathworks.com/matlabcentral/fileexchange/35475-quaternions) by  [Przemyslaw Baranski](https://fr.mathworks.com/matlabcentral/profile/authors/3251691-przemyslaw-baranski)
+ [Minimal bounding spheres functions](https://fr.mathworks.com/matlabcentral/fileexchange/48725-exact-minimum-bounding-spheres-circles) by [Anton Semechko](https://fr.mathworks.com/matlabcentral/profile/authors/1500618-anton-semechko)  
+ The [*Dunn's Test of Multiple Comparisons Using Rank Sums*](https://cran.r-project.org/web/packages/dunn.test/index.html)  R package by [Alexis Dinno](mailto:alexis.dinno@pdx.edu)
---

The between operator deviations of the anatomical coordinate systems (ACS) were evaluated with:  
+ The *Global Variability Angle* (**GVA**) that assesses the variability in orientation of the constructed ACSs for each subject, bone and algorithm.  
+ The *Bounding Sphere Radius* (**BSR**) that evaluates the dispersion in space of the 3 origin points of the 3 ACSs constructed for each subject, bone and algorithm.

### To analyse your result:
1. Import the *results.mat* file in this folder, this file is the ouptut of *ACS_LL.m*
2. Execute the *qRes.m* Matlab script to get GVAs, this should generate the following text files:  
    + *TF.txt* → GVAs for the femur
    + *TP.txt* → GVAs for the patella
    + *TT.txt* → GVAs for the tibia
3. Execute the *RBSph.m* Matlab script to get BSRs, this should generate the following text files:  
    + *mBSF.txt* → BSRs for the femur
    + *mBSP.txt* → BSRs for the patella
    + *mBST.txt* → BSRs for the tibia
4. Use the *AnalyzeResults.r* R script to get the Dunn's Test results for both GVA and BSR

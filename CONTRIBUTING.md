# Contribution Guidelines

## Reporting bugs and issues
If during your use of STAPLE you encounter a bug, such as an erroneous processing of the input bone geometries, or an unexpected crash while running your workflow, please report it to us [at this page](https://github.com/modenaxe/msk-STAPLE/issues) following this procedure:
1. **ensure that you have run through the troubleshooting checklist
2. **search the existing issues** to verify is someone else has reported the same problem. Feel free of commenting the existing issue if that is the case, so we will know that multiple users have had the same problem.
3. **make the issue reproducible, ideally with data that you can share with us**. This will help enormously for fixing the bug quickly.

### Coding conventions
- **Variable names**: Not all current code follows the conventions below for historical reasons (STAPLE relies on the external `GIBOC-knee` package) but these will be followed for future developments:
   - `lowerCamelCase` for general variables and function
   - `Algo_bone.m` for algorithm functions, e.g. `Kai2014_femur.m` or `STAPLE_femur.m`
   - `CS_bone_descrip.m` for function defining reference systems   
   - Maximize the use  of semantic and descriptive variables names (e.g. `femurTri` to indicate a MATLAB triangulation object of the femur. Avoid abbreviations except in cases of industry wide usage. 
- **Folders**: the scripts are located in folders with name chosen to make easier inspection and finding of a certain feature. In your pull requests please place your scripts where they belong. Please do not create new folders unless truly necessary, and use `sandbox` when you are unsure.


## Testing
Currently there is a testing folder with basic scripts for STAPLE. Feel free of adding any test for new functionalities that you develop. 

## Bone geometries datasets
The bone geometries datasets included in the package are limited to the minimum requires for examples and testing, to limit the size of the toolbox in download. If you want to contribute in this respect, please open an issue [at this page](https://github.com/modenaxe/msk-STAPLE/issues) and we will review and discuss the need to add further datasets.

## Contributing to the project with new code
- Please use a standard [GitHub workflow]:
   1. [fork this repository](https://guides.github.com/activities/forking/)
   2. create your own branch, where you make your modifications and improvements
   3. once you are happy with the new feature that you have implemented, or the bug you have fixed, you can create a pull request
   4. we will review your code and, if necessary, comment it. Once accepted your code will be merge to the `master` branch of the main repository. 
   Further guidelines:
      - Please keep the pull request simple and small, without unintended changes of code.
	  - If your PR resolves an issue, include **closes #ISSUE_NUMBER** in your commit message (or a [synonym](https://help.github.com/articles/closing-issues-via-commit-messages)).
	  - Describe how your code has been tested.
	  
## Proposing feature requests
Please open an issue [at this page](https://github.com/modenaxe/msk-STAPLE/issues), label it as `feature request` using the `Labels` panel on the right and describe your desired new feature. We will review the proposal regularly but work on them depending on the planned development. If you are asking for the improvement of an existing feature of STAPLE, label it `enhancement` instead.

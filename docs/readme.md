# How to use sphinx autodoc with custom docstring converter
---------------

## Requirements
- Python >= 3.7

Install the folowing packages using `conda install` or `pip install` :

- sphinx >= 3.5
- sphinxcontrib-matlabdomain >= 0.11
- sphinx-rtd-theme >= 0.5.1

## Convert Matlab docstrings to numpy style docstrings

By default the docstrings associated to each function where placed outside function definition.
For the sphinx matlab extension this docstring needs to be placed within the function.

The conversion can be achived with *docs/test_docstrings_utils.py*.
This python script is made to be altered to generate the conversion of funcitons in specific folder.

A txt file, *docs/already_converted_files.txt*, is updated at each use to keep track of functions for which the conversion is already done.

```Python
import os
os.chdir('..')
from docs.docstrings_utils import MatlabFunctionFileIdentificator, MatlabFunctionsDocStrings


for subfldr in ['GeometricFun', 'FittingFun'] :
    pth = os.path.join(os.getcwd(), 'STAPLE', 'GIBOC_core', 'SubFunctions', subfldr) 

    # Identify Matlab functions files
    mffid = MatlabFunctionFileIdentificator(pth)
    mffid.identifyFunctionFiles()

    # Load list of already converted functions
    with open('docs/already_converted_files.txt','r') as f:
        already_done_funcs = f.read()
    
    # Convert functions docstrings and write in file when conversion is done
    with open('docs/already_converted_files.txt','a') as f:
        for pthToFile in mffid.functionFiles :
            print(pthToFile, end=" ")
            if pthToFile in already_done_funcs :
                print('--> ALREADY DONE BEFORE')
                continue
            mfun = MatlabFunctionsDocStrings(pthToFile)
            matches = mfun.getFunctionDefinitionLinesMatches()
            mfun.addDocstringsToFile()

            f.write(pthToFile)
            f.write('\n')
            print('--> DONE')
```

Once python script is altered to your need, do in the console:
```shell
cd path/to/repo/root/docs
python test_docstrings_utils.py
``` 

## Set the part of code to include in documentation

Modify *index.rst* file in the root folder.

For example you can add 

```rst
GIBOC core plot functions
------------------------------

.. automodule:: STAPLE.GIBOC_core.SubFunctions.PlotFun
   :members:

```

to auto docstring the plot unctions in *STAPLE/GIBOC_core/SubFunctions*

## Make a documentation

In the console,

```shell
cd path/to/repo/root/
make html
```


## TO DO

- [ ] Remove previously converted numpy docstrings if the conversion is redone on the same file
- [ ] Generate a JSON of types for the variables, because conversion of type seems to hard to automatise
- [ ] Correct the problem of 'whitespace' + 'tab' before output description that render them as sort of blockquotes
- [ ] Decide if matlab docstring whould be kept once, numpy style is generated
- [ ] Seperate each subparts of the code in a distinct *.rst* file to a get a hierachical doc webpage.
- [ ] Deal with case when return is empty (eg. plot functions)

# %%
import os
os.chdir('..')
from docs.docstrings_utils import MatlabFunctionFileIdentificator, MatlabFunctionsDocStrings

# TODO : adjust for function without return (eg. plot functions)
for subfldr in ['GeometricFun', 'FittingFun'] :
    pth = os.path.join(os.getcwd(), 'STAPLE', 'GIBOC_core', 'SubFunctions', subfldr) 

    # Identify Matlab functions files
    mffid = MatlabFunctionFileIdentificator(pth)
    mffid.identifyFunctionFiles()

    # Load list of already converted functions
    with open('docs/already_converted_files.txt','r') as f:
        already_done_funcs = f.read()
    
    # Convert functions and write in file when conversion is done
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
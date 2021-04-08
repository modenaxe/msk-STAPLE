# %%
import os
os.chdir('..')
from docs.docstrings_utils import MatlabFunctionFileIdentificator, MatlabFunctionsDocStrings

# TODO : adjust for function without return (eg. plot functions)

for subfldr in ['GeometricFun', 'FittingFun'] :
    pth = os.path.join(os.getcwd(), 'STAPLE', 'GIBOC_core', 'SubFunctions', subfldr) 
    #  pth = os.path.join(os.getcwd(), 'STAPLE', 'algorithms', 'private') 

    mffid = MatlabFunctionFileIdentificator(pth)
    mffid.identifyFunctionFiles()
    # print(pthToFile)
    with open('docs/already_converted_files.txt','r') as f:
        already_done_funcs = f.read()

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

# %%

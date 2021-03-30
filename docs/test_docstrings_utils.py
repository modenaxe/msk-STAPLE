# %%
import os
os.chdir('..')
from docs.docstrings_utils import MatlabFunctionFileIdentificator, MatlabFunctionsDocStrings



# pth = os.path.join(os.getcwd(), 'STAPLE', 'GIBOC_core', 'SubFunctions', 'GeometricFun') 
pth = os.path.join(os.getcwd(), 'STAPLE', 'algorithms', 'private') 

mffid = MatlabFunctionFileIdentificator(pth)
mffid.identifyFunctionFiles()
pthToFile = mffid.functionFiles[15]
print(pthToFile)

mfun = MatlabFunctionsDocStrings(pthToFile)
matches = mfun.getFunctionDefinitionLinesMatches()
mfun.addDocstringsToFile()
print(matches)
# %%

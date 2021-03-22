import os
from docs.docstrings_utils import MatlabFunctionFileIdentificator, MatlabFunctionsDocStrings

pth = os.path.join(os.getcwd(), 'STAPLE', 'GIBOC_core', 'SubFunctions', 'GeometricFun') 

mffid = MatlabFunctionFileIdentificator(pth)
mffid.identifyFunctionFiles()
pthToFile = mffid.functionFiles[8]
print(pthToFile)

mfun = MatlabFunctionsDocStrings(pthToFile)
matches = mfun.getFunctionDefinitionLinesMatches()
print(matches)
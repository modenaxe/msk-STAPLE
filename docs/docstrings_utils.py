import os
import re
from collections import defaultdict

# https://regex101.com/

class FileIdentificator():
    def __init__(self, path, extension, recursive=False):
        self.path = path
        self.extension = extension
        self.recursive = recursive
        self.filesToCheck = self.identifyFilesTocheck()

    def identifyFilesTocheck(self):
        """Identify the files to be checked for presence of docstrings
        """
        filesToCheck = []
        
        if self.recursive :
            # r=root, d=directories, f = files
            for r, d, f in os.walk(path):
                for file in f:
                    if file.endswith(self.extension):
                        filesToCheck.append(os.path.join(r, file))
        
        else :
            filesToCheck = [os.path.join(self.path, f) for f in os.listdir(self.path) if f.endswith(self.extension)]

        return filesToCheck

class MatlabFunctionFileIdentificator(FileIdentificator):
    def __init__(self, path, extension='.m', recursive=False):
        super().__init__(path, extension, recursive)
        self.functionREGEX = '^function'
        self.functionFiles = []

    def setFunctionREGEX(self, functionREGEX):
        """Set the regex to capture function definition in matlab files

        Args:
            functionREGEX (strinf): The regular expression to capture function definition
        """
        self.functionREGEX = functionREGEX


    def identifyFunctionFiles(self):
        """Identify the files that are definoing matlab functions
        """

        for f_path in self.filesToCheck:
            with open(f_path, mode='r') as f:
                txt = f.read()
                matches = re.findall(self.functionREGEX, txt, re.MULTILINE)

                print(f_path, matches)
                self.functionFiles.append(f_path)


class Docstrings():
    def __init__(self, txt):
        self.txt = txt



class MatlabFunctionsDocStrings():
    def __init__(self, pathToFile, style='numpy'):
        self.pathToFile = pathToFile
        self.style = style
        self.functionREGEX = '(^function (?:\[([^\)]+)\]|([a-zA-Z0-9]+)) *= *[a-zA-Z0-9]+\(([^\)]+)\))'
        self.inputs, self.outputs = self.getInputsAndOutputs()
        self.infosDict = self.createInfosDict()
        self.knownTypes = self.defineKnownTypeDict()
    
    def createInfosDict(self):

        infosDict = dict()
        infosDict['summary_line'] = '__NOTDONEYET__summaryline'
        infosDict['extd_descr'] = '__NOTDONEYET__extended_description'
        infosDict['inputs'] = {k: ['__TYPE__', '__DESCRIPTION__'] for k in self.inputs}
        infosDict['outputs'] = {k: ['__TYPE__', '__DESCRIPTION__'] for k in self.outputs}

        return infosDict


    def makeDocstrings(self, formatDict):
        """construct the template of the docstrings.

        Use of the minimal architecture of the docstrings
        """

        docstrings = ('\t% {summary_line}\n'
                      '\t%\n'
                      '\t% {extd_descr}\n'
                      '\t%\n'
                      '\t% Parameters\n'
                      '\t% ----------\n'
                      '{formated_inputs}'
                      '\t%\n'
                      '\t% Returns\n'
                      '\t% -------\n'
                      '{formated_outputs}'
                      '\t%\n')
        docstrings = docstrings.format(**formatDict)

        return docstrings

    def updateInputsOutputs(self, updateDict=None):
        """
        """
        knownTypes = self.defineKnownTypeDict()
        for param, (type_, descr_) in self.infosDict['inputs'].items():
            for knownParamKW, knownType in knownTypes.items():
                if param.startswith(knownParamKW):
                    self.infosDict['inputs'][param][0] = knownType
        
        for param, (type_, descr_) in self.infosDict['outputs'].items():
            for knownParamKW, knownType in knownTypes.items():
                if param.startswith(knownParamKW):
                    self.infosDict['outputs'][param][0] = knownType

        knownDescriptions = self.defineKnownDescrDict()
        for param, (type_, descr_) in self.infosDict['inputs'].items():
            for knownDescrKW, knownDescr in knownDescriptions.items():
                if param.startswith(knownDescrKW):
                    self.infosDict['inputs'][param][1] = knownDescr
        
        for param, (type_, descr_) in self.infosDict['outputs'].items():
            for knownDescrKW, knownDescr in knownDescriptions.items():
                if param.startswith(knownDescrKW):
                    self.infosDict['outputs'][param][1] = knownDescr

        if updateDict :
            self.infosDict.update(updateDict)



    def createFormatedInputsOutputs(self):
        """format the inputs and outputs to write them in docstrings
        """
        self.infosDict['formated_inputs'] = ''
        for param, (type_, descr_) in self.infosDict['inputs'].items():
            self.infosDict['formated_inputs'] += f'\t% {param} : {type_}\n'
            descr_ = descr_.replace('\n', '\n\t% \t')
            self.infosDict['formated_inputs'] += f'\t% \t{descr_}\n'

        self.infosDict['formated_outputs'] = ''
        for param, (type_, descr_) in self.infosDict['outputs'].items():
            self.infosDict['formated_outputs'] += f'\t% {param} : {type_}\n'
            descr_ = descr_.replace('\n', '\n\t% \t')
            self.infosDict['formated_outputs'] += f'\t% \t{descr_}\n'


    def addDocstringsToFile(self, updateDict=None):
        """Add docstrings to current function file
        """
        self.updateInputsOutputs(updateDict)
        self.createFormatedInputsOutputs()

        modified_txt = ''

        beforeFuncDef, afterFuncDef = self.orgnlFuncFileText.split(self.functionDefinitionLines)

        modified_txt += beforeFuncDef + '\n'
        modified_txt += self.functionDefinitionLines + '\n'
        modified_txt += self.makeDocstrings(self.infosDict) + '\n'
        modified_txt += afterFuncDef[:-1].replace('\n', '\n\t')
        modified_txt += afterFuncDef[-1]

        # with open(self.pathToFile, mode='w') as f:
        with open('docstrings_test.m', mode='w') as f:
            f.write(modified_txt)


        # mfun.makeDocstrings(mfun.infosDict)


    def getFunctionDefinitionLinesMatches(self):
        """Find lines that define the function
        """
        with open(self.pathToFile, mode='r') as f:
            txt = f.read()
            self.orgnlFuncFileText = txt
            matches = re.findall(self.functionREGEX, txt, re.MULTILINE)

            if matches == []:
                raise ValueError(f'REGEX didn"t not find any function for {self.pathToFile}')

        # Set the definitions lines
        self.functionDefinitionLines = matches[0][0]

        return matches

    def getInputsAndOutputs(self):
        """Identify the line or lines that defines the function
        """

        matches = self.getFunctionDefinitionLinesMatches()

        # Divide first occurence of definition function
        multi_outputs, single_output, inputs = matches[0][1:]

        outputs = self.cleanMatches(multi_outputs + single_output)
        inputs = self.cleanMatches(inputs)

        return inputs, outputs

    def cleanMatches(self, matches):
        """Clean the list obtained with findall regex

        Remove white spaces and other unnecessary characters and break the list in elements
        Args:
            matches (str): string of a list of inputs or outpurs
        
        Returns:
            cleanedMatches (list): list of cleaned inputs or outputs
        """

        cleanedMatches = (matches
                          .replace('...', '')
                          .replace('\n', '')
                          .replace('\t','')
                          .replace(' ', '')
                          .split(',')
                          )

        return cleanedMatches

    def defineKnownTypeDict(self):
        """define a dictionnary of known type for certain keywords

        Returns:
            dict: dict of type for certain widely used keywords
        """

        knownTypes = {
            'Epi': 'triangulation',
            'Tr': 'triangulation',
            'CS': 'Matlab structure',
            'debug_plots': 'boolean',
            'Pts': '[nx3] float matrix',
            'CoeffMorpho': 'float',
            'Z0': '[3x1] float vector',
            'U_': '[3x1] float vector',
            'Minertia': '[3x3] float matrix',
            'n': '[3x1] float vector',
            'Op': '[1x3] float vector',
            }
        
        return knownTypes

    def defineKnownDescrDict(self):
        """define a dictionnary of known type for certain keywords
        Returns:
            dict: dict of type for certain widely used keywords
        """

        knownDescr = {
            'debug_plots': 'enable plots used in debugging. Value: 1 or 0 (default).',
            'result_plots': 'enable plots of final fittings and reference systems.\nValue: 1 (default) or 0.',
            'Minertia': 'An inertia matrix __DESCRIPTION__',
            'n': 'An unit normal vector',
            'Op': 'A point located on the plan',
            }
        
        return knownDescr




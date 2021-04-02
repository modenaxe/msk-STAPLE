import os
import re
from collections import defaultdict
import copy

# https://regex101.com/

class FileIdentificator():
    def __init__(self, path, extension, recursive=False):
        self.path = path
        self.fileName = os.path.basename(path)
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
                self.functionFiles.append(f_path)


class Docstrings():
    def __init__(self, txt):
        self.txt = txt



class MatlabFunctionsDocStrings():
    def __init__(self, pathToFile, style='numpy'):
        self.pathToFile = pathToFile
        self.style = style
        self.functionREGEX = '(^function (?:\[([^\)]+)\]|([a-zA-Z0-9_]+)) *=.*\n{0,1}.*[a-zA-Z0-9_]+\(([^\)]+)\))'
        self.inputs, self.outputs = self.getInputsAndOutputs()
        self.infosDict = self.createInfosDict()
        self.initKnownDescrDict()
        self.initKnownTypeDict()
        self.see_also = None

    
    def createInfosDict(self):

        infosDict = dict()
        infosDict['summary_line'] = '__NOTDONEYET__summaryline'
        infosDict['extd_descr'] = '__NOTDONEYET__extended_description'
        infosDict['inputs'] = {k: ['__TYPE__', '__DESCRIPTION__'] for k in self.inputs}
        infosDict['outputs'] = {k: ['__TYPE__', '__DESCRIPTION__'] for k in self.outputs}

        return infosDict

    def useExistingDocstring(self, beforeFuncDef=None):
        '''
        Read the existing matlab style docstring
        '''
        if beforeFuncDef is None :
            self.getFunctionDefinitionLinesMatches()
            beforeFuncDef, afterFuncDef = self.orgnlFuncFileText.split(self.functionDefinitionLines)

        # Check if there are comments before fun def
        if (not beforeFuncDef) or ('%' not in beforeFuncDef):
            return dict()

        # # Check if its copyright only before function def
        if beforeFuncDef.startswith('%-------') :
            return dict()


        regex_inputs_header = '^% {0,1}[Ii]nputs{0,1} {0,2}: *\t*$'
        regex_outputs_header = '^% {0,1}[Oo]utputs{0,1} {0,2}: *\t*$'
        regex_func_def = '(^% *(?:\[([^\)]+)\]|([a-zA-Z0-9_]+)) *=.*\n{0,1}.*[a-zA-Z0-9_]+\(([^\)]+)\))'

        # inputs_regex = '(^% (?:i|I)nputs *: *\n(% *([a-zA-Z0-9_]+) - ([a-zA-Z0-9_ \n\.%\(\):\*]+)%\n%))'
        inoutputs_regex = '^% *([a-zA-Z0-9_]+) - ([a-zA-Z0-9_ \.\(\):\*\"]+)'
        copyright_regex = '^(%[-]{6,}(?:.|\n)+[Cc]opyright(?:.|\n)+[-]{6,}%)'
        see_also_regex = '^% See also (((\w*)(?:, *|.))+)'

        general_descr_end_idx = re.search(regex_func_def, beforeFuncDef, re.MULTILINE).span()[0]
        inputs_start_idx = re.search(regex_inputs_header, beforeFuncDef, re.MULTILINE).span()[1]
        inputs_end_idx = re.search(regex_outputs_header, beforeFuncDef, re.MULTILINE).span()[0] - 2
        outputs_start_idx = re.search(regex_outputs_header, beforeFuncDef, re.MULTILINE).span()[1]
        if re.search(see_also_regex, beforeFuncDef, re.MULTILINE) :
            outputs_end_idx = re.search(see_also_regex, beforeFuncDef, re.MULTILINE).span()[0] - 2

        elif re.search(copyright_regex, beforeFuncDef, re.MULTILINE) :
            outputs_end_idx = re.search(copyright_regex, beforeFuncDef, re.MULTILINE).span()[0] - 2
        else :
            outputs_end_idx = len(beforeFuncDef)

        inputs_txt = beforeFuncDef[inputs_start_idx: inputs_end_idx]     
        outputs_txt = beforeFuncDef[outputs_start_idx:outputs_end_idx]

        # Update Description
        infosDict = dict()
        for splt in ['%\n', '% \n', '%\t\n' '%   \n'] :
            tmp = beforeFuncDef[: general_descr_end_idx].split(splt)
            if len(tmp) > 1:
                infosDict['extd_descr']= '\n'.join(tmp[1:]).replace('\n%', '\n\t%')[2:-2]
                break

        infosDict['summary_line'] = tmp[0].replace('\n%', '\n\t%')[2:-2]
        self.infosDict.update(infosDict)

        # Identify inputs and descriptions
        infosDict['inputs'] = dict()
        inputs = infosDict['inputs']
        matches = re.findall(inoutputs_regex, inputs_txt, re.MULTILINE)
        for input_, descr_ in matches[::-1]:
            tmp_txt = inputs_txt.split(descr_)
            descr_txt = descr_ + re.sub(' +', ' ',tmp_txt[-1]).replace('%','')
            while descr_txt.endswith('\n') :
                descr_txt = descr_txt[:-2]
            inputs[input_] = descr_txt
            inputs_txt = '\n'.join(tmp_txt[0].split('\n')[:-1])

        self.knownDescrInputs.update(inputs)

        
        # Identify inputs and descriptions
        infosDict['outputs'] = dict()
        outputs = infosDict['outputs']
        matches = re.findall(inoutputs_regex, outputs_txt, re.MULTILINE)
        for output_, descr_ in matches[::-1]:
            tmp_txt = outputs_txt.split(descr_)
            descr_txt = descr_ + re.sub(' +', ' ',tmp_txt[-1]).replace('%','')
            while descr_txt.endswith('\n') :
                descr_txt = descr_txt[:-2]
            outputs[output_] = descr_txt
            outputs_txt = '\n'.join(tmp_txt[0].split('\n')[:-1])
        
        self.knownDescrOutputs.update(outputs)

        # See also Dict
        infosDict['see_also'] = dict()
        see_also = infosDict['see_also']
        see_also_match = re.findall(see_also_regex, beforeFuncDef, re.MULTILINE) 
        if see_also_match :
            see_also = [sa.replace('.','').replace(' ','') 
                        for sa in see_also_match[0][0].split(',')]
        self.see_also = see_also


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
                      '\t%\n'
                      '\t%')
        docstrings = docstrings.format(**formatDict)

        return docstrings

    def updateInputsOutputs(self, updateDict=None):
        """
        """
        knownTypes = self.knownTypes
        for param, (type_, descr_) in self.infosDict['inputs'].items():
            for knownParamKW, knownType in knownTypes.items():
                if param.startswith(knownParamKW):
                    self.infosDict['inputs'][param][0] = knownType
        
        for param, (type_, descr_) in self.infosDict['outputs'].items():
            for knownParamKW, knownType in knownTypes.items():
                if param.startswith(knownParamKW):
                    self.infosDict['outputs'][param][0] = knownType

        knownDescriptions = self.knownDescrInputs
        for param, (type_, descr_) in self.infosDict['inputs'].items():
            for knownDescrKW, knownDescr in knownDescriptions.items():
                if param.startswith(knownDescrKW):
                    self.infosDict['inputs'][param][1] = knownDescr
        
        knownDescriptions = self.knownDescrOutputs
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

        modified_txt = ''

        beforeFuncDef, afterFuncDef = self.orgnlFuncFileText.split(self.functionDefinitionLines)

        self.useExistingDocstring(beforeFuncDef)
        self.updateInputsOutputs(updateDict)
        self.createFormatedInputsOutputs()

        modified_txt += beforeFuncDef + '\n'
        modified_txt += self.functionDefinitionLines + '\n'
        modified_txt += self.makeDocstrings(self.infosDict) + '\n'

        if self.see_also :
            modified_txt = modified_txt[:-2]
            modified_txt += '% SEE ALSO ' + ', '.join(self.see_also)

        # Check if files is already indented
        if afterFuncDef.count('\n') > 2*afterFuncDef.count('\n  '):
            modified_txt += afterFuncDef[:-1].replace('\n', '\n\t')
        else :
            modified_txt += afterFuncDef[:-1]           
        modified_txt += afterFuncDef[-1]

        # with open(self.pathToFile, mode='w') as f:
        with open(self.pathToFile, mode='w') as f:
            f.write(modified_txt)
    

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

    
    def initKnownTypeDict(self):
        """define a dictionnary of known type for certain keywords

        Returns:
            dict: dict of type for certain widely used keywords
        """

        self.knownTypes = {
                            'Epi': 'triangulation',
                            'Tr': 'triangulation',
                            'TR': 'triangulation',
                            'CS': 'Matlab structure',
                            'debug_plots': 'boolean',
                            'debug_prints': 'boolean',
                            'Pts': '[nx3] float matrix',
                            'CoeffMorpho': 'float',
                            'Z0': '[3x1] float vector',
                            'U_': '[3x1] float vector',
                            'Minertia': '[3x3] float matrix',
                            'n': '[3x1] float vector',
                            'Op': '[1x3] float vector',
                            'V': '[3x3] float matrix',
                            }
        

    def initKnownDescrDict(self):
        """define a dictionnary of known type for certain keywords
        Returns:
            dict: dict of type for certain widely used keywords
        """

        self.knownDescrInputs = {
            'debug_plots': 'enable plots used in debugging. Value: 1 or 0 (default).',
            'debug_prints': 'enable prints for debugging. Value: 1 or 0 (default)',
            'result_plots': 'enable plots of final fittings and reference systems.\nValue: 1 (default) or 0.',
            'Minertia': 'An inertia matrix __DESCRIPTION__',
            'n': 'An unit normal vector',
            'Op': 'A point located on the plan',
            'V_all': 'The 3 eigen vectors of the pseudo inertia-matrix of the current bone'
            }

        self.knownDescrOutputs = copy.deepcopy(self.knownDescrInputs)





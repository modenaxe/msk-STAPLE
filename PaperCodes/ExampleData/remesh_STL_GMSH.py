# -*- coding: utf-8 -*-
"""
Improved on Tue Oct 31 12:30:07 2017

@author: Jean-Baptiste RENAULT
"""
import os
import Tkinter as tk
import tkFileDialog as tkfd
import subprocess
import time
import fnmatch

master = tk.Tk()

# =============================================================================
# Function to find if application are in os path from https://stackoverflow.com/questions/377017/test-if-executable-exists-in-python
# =============================================================================
def which(program):
    import os
    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file

    return None

# =============================================================================
# Function to remesh all the .stl files in the current working folder
# =============================================================================
def callback_Auto():
    print "Automatic method selected"
    master.destroy() 
    
    
    size=0.5
    tk.Tk().withdraw()
    outputDir = tkfd.askdirectory(title="Please select a folder in which the output will be saved")
    print('Directory in which the remeshed files will be placed: ')
    print(outputDir)
    
#    Check if GMSH in Path and try to find it if not
    gmsh = which('gmsh.exe')
    if gmsh:
        print('GMSH was found in your path')
    else :
        matches = []
        for root, dirnames, filenames in os.walk(os.getcwd()):
            for filename in fnmatch.filter(filenames, 'gmsh.exe'):
                matches.append(os.path.join(root, filename))
                
        if matches :
            print('gmsh.exe was found in your current working directory subfolders')
            gmsh = matches[0]
        else :
            print('You need to download gmsh and put in this folder')
   
#   Find the stl files in current working directory 
    cwd = os.getcwd()
    fout = open('meshSTL_results.txt','a')
    linesOut=[]
    FileList = os.listdir(cwd)
    STLList = [ f for f in FileList if f.endswith('.stl') ]
    successScore = 0.0
    
#   Remsh all files with gmsh 
    for fileID in STLList :
        # extract the name of the file
        ID = fileID[:-4]
        
        f = open('remeshSTL.geo','w')
        f.write("Geometry.HideCompounds = 0;\nMesh.RemeshAlgorithm=1;\nMesh.CharacteristicLengthMin={0};"
                "\nMesh.CharacteristicLengthMax={0};\nMerge \"{1}.stl\";\nCompound Surface(200)={{1}};"
                "\nSurface Loop(300)={{200}};\nVolume(301)={{300}};\nPhysical Surface (501)={{200}};"
                "\nPhysical Volume(502)={{301}};\nMesh 2;\nSave \"{1}_remeshed.msh\";"
                "\nSave \"{1}_remeshed.stl\";\nExit;\n".format(size,ID.upper())
               )
        f.close()
        
        start = time.time()
        subprocess.call([gmsh, 'remeshSTL.geo'], shell=True)
        end = time.time()
        if ID.upper() + '_remeshed.stl' and ID.upper() + '_remeshed.msh' in os.listdir(cwd) :        
            print("Mesh generated in " + str(round(end - start)) +"s for")
            print(ID.upper())
            linesOut.append("OK -> "+ID.upper()+"\n")
            successScore += 1
            os.rename(cwd+'\\'+fileID,outputDir+'\\'+fileID)
            os.rename(cwd+'\\'+ID.upper() + '_remeshed.msh',outputDir+'\\'+ID.upper() + '_remeshed.msh')
            os.rename(cwd+'\\'+ID.upper() + '_remeshed.stl',outputDir+'\\'+ID.upper() + '_remeshed.stl')
        else :
            print("Mesh failed for")
            print(ID.upper())
            linesOut.append("NOT OK -> "+ID.upper()+"\n")
        os.remove('remeshSTL.geo')
    
    
    successRatio = successScore/len(STLList)
    linesOut.append("Above files processed with " + str(round(100*successRatio)) + "% of success \n")
    fout.write(''.join(linesOut))
    fout.close()
    print("All files processed with " + str(round(100*successRatio)) + "% of success, will close in 10 seconds or you can exit this window")
    time.sleep(10)
    quit()
    
# =============================================================================
# Function to remesh only one selected .stl file
# =============================================================================
def callback_Select():
    print "File selection method selected"
    master.destroy() 
    
#   Check if GMSH in Path and try to find it if not
    gmsh = which('gmsh.exe')
    if gmsh:
        print('GMSH was found in your path')
    else :
        matches = []
        for root, dirnames, filenames in os.walk(os.getcwd()):
            for filename in fnmatch.filter(filenames, 'gmsh.exe'):
                matches.append(os.path.join(root, filename))
                
        if matches :
            print('gmsh.exe was found in your current working directory subfolders')
            gmsh = matches[0]
        else :
            print('You need to download gmsh and put in this folder')
   
    
    size=0.5
    
    tk.Tk().withdraw()
    filename = tkfd.askopenfilename(title='Select the file (.stl) you want to remesh: ') # show an "Open" dialog box and return the path to the selected file
    ID = filename[:-4]
    f = open('remeshSTL.geo','w')
    f.write("Geometry.HideCompounds = 0;\nMesh.RemeshAlgorithm=1;\nMesh.CharacteristicLengthMin={0};"
            "\nMesh.CharacteristicLengthMax={0};\nMerge \"{1}.stl\";\nCompound Surface(200)={{1}};"
            "\nSurface Loop(300)={{200}};\nVolume(301)={{300}};\nPhysical Surface (501)={{200}};"
            "\nPhysical Volume(502)={{301}};\nMesh 2;\nSave \"{1}_remeshed.msh\";"
            "\nSave \"{1}_remeshed.stl\";\nExit;\n".format(size,ID.upper()))
    f.close()
    subprocess.call([gmsh, 'remeshSTL.geo'], shell=True)
    os.remove('remeshSTL.geo')
    print("File processed , will close in 10 seconds or you can exit this window now")
    time.sleep(10)
    quit()

# =============================================================================
# Main part of tkinter 
# =============================================================================
b = []
b.append(tk.Button(master, text="Automatic",height=15,width=49, command=callback_Auto))
b[0].pack()
b.append(tk.Button(master, text="File selection",height=15,width=49, command=callback_Select))        
b[1].pack()

tk.mainloop()

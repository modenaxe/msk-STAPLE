# txt2mtlb.py
"""Python module demonstrates passing MATLAB types to Python functions"""
def read_nodesGMSH(file_name):
    import os
    import decimal
    f = open(file_name,'r')
    N_elmts=int(f.readlines()[4])
    XYZ={'X':[],'Y':[],'Z':[]}
    f.close()
    f = open(file_name,'r')
    for line in f.readlines()[5:N_elmts+5]:
        linesplit=line.split(' ')
        XYZ['X'].append(float(linesplit[1]))
        XYZ['Y'].append(float(linesplit[2]))
        XYZ['Z'].append(float(linesplit[3]))
    f.close()
    return XYZ

def read_meshGMSH(file_name):
    import os
    import decimal
    cwd = os.getcwd()
    fname = cwd + "\\" +file_name
    f = open(fname,'r')
    N_nodes=int(f.readlines()[4])
    f.close()
    f = open(fname,'r')
    N_lines = len(f.readlines())
    XYZELMTS={'X':[],'Y':[],'Z':[],'N1':[],'N2':[],'N3':[]}
    f.close()
    f = open(fname,'r')
    for line in f.readlines()[5:N_nodes+5]:
        linesplit=line.split(' ')
        XYZELMTS['X'].append(round(float(linesplit[1]),3))
        XYZELMTS['Y'].append(round(float(linesplit[2]),3))
        XYZELMTS['Z'].append(round(float(linesplit[3]),3))
    f.close()
    f = open(fname,'r')
    for line in f.readlines()[N_nodes+8:N_lines-1]:
        linesplit=line.split(' ')
        if linesplit[1]=='2' :
            XYZELMTS['N1'].append(int(linesplit[5]))
            XYZELMTS['N2'].append(int(linesplit[6]))
            XYZELMTS['N3'].append(int(linesplit[7]))
    f.close()
    return XYZELMTS

def read_maskMIMICS(file_name):
    import os
    XYZ={'X':[],'Y':[],'Z':[]}
    f = open(file_name,'r')
    for line in f:
        linesplit=line.split(', ')
        XYZ['X'].append(float(linesplit[0]))
        XYZ['Y'].append(float(linesplit[1]))
        XYZ['Z'].append(float(linesplit[2]))
    f.close()
    return XYZ

def read_exportGVMIMICS(file_name):
    import os
    XYZI={'X':[],'Y':[],'Z':[],'I':[]}
    f = open(file_name,'r')
    for line in f:
        linesplit=line.split(', ')
        XYZI['X'].append(float(linesplit[0]))
        XYZI['Y'].append(float(linesplit[1]))
        XYZI['Z'].append(float(linesplit[2]))
        XYZI['I'].append(float(max(0,float(linesplit[3]))))
    f.close()
    return XYZI

def find_ProsthFile(directory,Pname,Ptype):
    import os
    Ptype = int(Ptype)
    os.chdir(directory)
    directory = os.getcwd()
    os.chdir(directory)
    
    files_list = []
    prosthType = 'Prosthesis'+str(Ptype)
    Pname = 'Implant' + str(Ptype) + '_'+ Pname + '.msh'
    for path, subdirs, files in os.walk(directory):
        for name in files:
            files_list.append(os.path.join(path, name))
#    A = []
#    for fdir in files_list:
#        print(fdir)
#        if prosthType in fdir and Pname in fdir :
#            print("A file found")
#            A.append(fdir)
#    ## prosthType in fdir and
    A = [fdir for fdir in files_list  if prosthType in fdir and Pname in fdir]
#    print(Pname)
#    print(prosthType)
#    print(directory)
#    print(os.getcwd())
#    ## print(files_list)
#    print(A)
    mshFile = str(A[0])
#    print(mshFile)
    return mshFile

def find_ProsthFile_read_nodesGMSH(directory,Pname,Ptype):
    
    mshFile = find_ProsthFile(directory,Pname,Ptype)
    
    XYZ = read_nodesGMSH(mshFile)
    
    return XYZ

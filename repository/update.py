import datetime
import os
import xml.etree.cElementTree as ET

# see if this filename is in the array of filenames
def checkPresent(arr, fileName, curResult):
    # don't bother testing if we've already failed
    if curResult is False:
        return False
    if fileName not in arr:
        print (fileName + " is missing")
        return False
    else:
        return True

def checkFolder():
    # do some checks on this folder
    arr = os.listdir()

    # initialise success flag
    result = True

    result = checkPresent(arr, "compositeContent.xml", result)
    result = checkPresent(arr, "compositeArtifacts.xml", result)
    result = checkPresent(arr, "p2.index", result)

    if result is True:
        zipFound = findZipFile()
        if zipFound is None:
            print("Zip-file not found in folder")
            result = False

    return result

def getDTG():
    now = datetime.datetime.now()
    return now.strftime("%Y_%m_%d__%H_%M_%S")

# see if there is a zip=file in the current folder
def findZipFile():
    arr = os.listdir()
    for file in arr:
        if(file.endswith(".zip")):
            return file

# update the children element
def updateChildren(contentFile, newFile):
    tree = ET.parse(contentFile)
    root = tree.getroot() 
    root_tag = root.tag
    print(root_tag) 

    for form in root.findall("./bar/type"):
        x=(form.attrib)
        z=list(x)
        for i in z:
            print(x[i])


# check things are ok
allOk = checkFolder()

if allOk:
    
    print( "Valid folder, doing update")

    # look for zip file
    zipFile = (findZipFile())

    if zipFile is not None:
        dtg = getDTG()
        newName = dtg + ".zip"

        # rename file
        os.rename(zipFile,  newName)  

        # parse category files

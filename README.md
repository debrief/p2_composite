This project contains a script that is used to maintain a p2 composite repository, for an Eclipse RCP application.

### Introduction
Eclipse RCP applications are able to update themselves from a repository using the Eclipse [P2](https://wiki.eclipse.org/Equinox/p2) distribution model.

Rollback to previous versions can be offered if the repository contains those previous versions.  This repository structure is termed a [Composite Repository](https://wiki.eclipse.org/Equinox/p2/Composite_Repositories_(new)).

### Issue
Software exists to support the maintenance of P2 repositories, available as Ant scripts or command-line utilities.  But, it has proven challenging to get these applications to build, since those found typically haven't been updated for 5 years.  Or, they require a running instance of Eclipse, which doesn't suit all target networks (including those that are headless or don't have a Java runtime).

### Solution
Research into Composite Repositories has indicated that they are supported by two relatively straightforward XML files, similar in structure to this one:
````
<?xml version='1.0' encoding='UTF-8'?>
<?compositeArtifactRepository version='1.0.0'?>
<repository name='&quot;Eclipse Project Test Site&quot;'
    type='org.eclipse.equinox.internal.p2.artifact.repository.CompositeArtifactRepository' version='1.0.0'>
  <properties size='1'>
    <property name='p2.timestamp' value='1243822502440'/>
  </properties>
  <children size='2'>
    <child location='childOne'/>
    <child location='childTwo'/>
  </children>
</repository>
````

The `children` element contains the URLs of a series of release versions.  Experiments have demonstrated that these can just be a series of sub-folders, one for each unpacked release.

A [python script](https://github.com/debrief/p2_composite/blob/master/repository/update.py) has been developed to automate the addition of a new release. The script performs these steps:
1. Verify that the current working folder is a valid repository (i.e. the assorted metadata files are present)
2. Verify that the current working folder contains a `.zip` file (this is presumed to be a `P2_Repository.zip` file containing a new release)
3. Generate a string with the current date-time (timestamp)
3. Rename the `.zip` file to timestamp
4. Unpack the zip file into a folder within the `updates` sub-folder named with that timestamp
5. Modify the two XML definition files to add the new sub-folder path to the `children` element, and increment the counter
6. Delete the zip file

### Setup
Place a copy of the contents of the `repository` folder of this project on the target hosting environment that is visible to the client application.  The files can be served by an HTTP-server, or a shared network drive.

Add the hosting location to the Eclipse RCP (client) application using the `Add` button from the `Available Software Sites` preference page.

![add_software_site](https://user-images.githubusercontent.com/1108513/67189303-e4036980-f3e5-11e9-94f4-c3e9814c5727.png)

### Usage
1. Navigate to the repository folder, on a system with Python3 available
2. Copy a new release into this folder
3. Execute `python3 update.py` from the command line
4. A successful update will be indicated by a `== COMPLETE ==` response.

### Future
The script could be extended to accept a variable denoting the number of releases to store.  When a release is added which results in the number of children exceeding that number, the relevant number of release version would be deleted from both the XML file and the updates sub-folder.

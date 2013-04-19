=====
Rightscale Powershell Sample - Destroy Deployments
=====

----
Script
----
destroyDeployments.ps1

----
Requirements
----
-.Net 4.5
-Powershell 3
-Powershell configured to use the lastest runtine
-RightScale.netClient.Powershell and required files - RightScale.netClient.

-----
 How To Use
-----
This script imports the module RightScale.netClient.Powershell.dll from c:\RSTools\RSPS directory,  this will need to be changed if you have that in a different location.

When executing script you will first be prompted for accountid and credentialsa and a name filter which will be used to find matching deployments.  The filter is a left to right match - ie "Model" will match Model Deployment but not Deployment Model.  A list of Deployments will be displayed and you will be prompted to continue to destroy them,  if their are Operational servers in the Deployment they will need to be destroyed before the Deployment can be destroyed and you will be prompted to confirm this action as well.


 Thanks,
 
RightScale Windows Professional Services Team
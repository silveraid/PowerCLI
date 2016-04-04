function Get-VMFolderPath
{
 <#
   .Synopsis
 
    Get vm folder path. From Datacenter to folder that keeps the vm.
 
   .Description
 
    This function returns vm folder path. As a parameter it takes the 
    current folder in which the vm resides. This function can throw
    either 'name' or 'moref' output. Moref output can be obtained
    using the -moref switch.
 
    .Example
 
    get-vm 'vm123' | get-vmfolderpath
 
    Function will take folderid parameter from pipeline
     
   .Example
 
    get-vmfolderpath (get-vm myvm123|get-view).parent
 
    Function has to take as first parameter the moref of vm parent
    folder. 
    DC\VM\folfder2\folderX\vmvm123
    Parameter will be the folderX moref
     
   .Example
 
    get-vmfolderpath (get-vm myvm123|get-view).parent -moref
 
    Instead of names in output, morefs will be given.
 
 
    .Parameter folderid
 
    This is the moref of the parent directory for vm.Our starting
    point.Can be obtained in serveral ways. One way is to get it
    by: (get-vm 'vm123'|get-view).parent  
    or: (get-view -viewtype virtualmachine -Filter @{'name'=
    'vm123'}).parent
     
   .Parameter moref
 
    Add -moref when invoking function to obtain moref values
 
   .Notes
 
    NAME:  Get-VMFolderPath
 
    AUTHOR: Grzegorz Kulikowski
 
    LASTEDIT: 09/14/2012
     
    NOT WORKING ? #powercli @ irc.freenode.net 
 
   .Link
 
    https://psvmware.wordpress.com
 
 #>
 
param(
[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
[string]$folderid,
[switch]$moref
)
 
    $folderparent = Get-View $folderid

    if ($folderparent.name -ne 'vm') {

        if ($moref) {

            $path = $folderparent.moref.toString() + '\' + $path
        }

        else {

            $path = $folderparent.name + '\' + $path
        }

        if ($folderparent.parent) {

            if ($moref) {

                Get-VMFolderPath $folderparent.parent.tostring() -moref
            }

            else {
                Get-VMFolderPath $folderparent.parent.tostring()
            }
        }
    }

    else {

        if ($moref) {

            $finalPath = (Get-View $folderparent.parent).moref.tostring() + '\' + $path
        }

        else {

            $finalPath = (Get-View $folderparent.parent).name.toString() + '\' + $path
        }

        return $finalPath.trim("\")
    }
}

$directory = ""
$hostName = ""

$outVMs = @()
$allVMs = Get-VMHost -Name $hostName | Get-VM
$allTemplates = Get-VMHost -Name $hostName | Get-Template

foreach ($thisVM in $allVMs) {

    $myVMView = $thisVM | Get-View

    $myVM = "" | select name,notes,folderPath,vmxPath,isTemplate
    $myVM.name = $thisVM.name
    $myVM.notes = $thisVM.Notes
    $myVM.folderPath = $thisVM | Get-VMFolderPath
    $myVM.vmxPath = $myVMView.Config.Files.VmPathName
    $myVM.isTemplate = $false

    $outVMs += $myVM
}

foreach ($thisTemplate in $allTemplates) {

    $myTemplateView = $thisTemplate | Get-View

    $myTemplate = "" | Select name,notes,folderPath,vmxPath,isTemplate
    $myTemplate.name = $thisTemplate.name
    $myTemplate.notes = $thisVM.Notes
    $myTemplate.folderPath = $thisTemplate | Get-VMFolderPath
    $myTemplate.vmxPath = $myTemplateView.Config.Files.VmPathName
    $myTemplate.isTemplate = $true

    $outVMs += $myTemplate
}

$outVMs | export-clixml "${directory}\${hostName}_folders.xml"


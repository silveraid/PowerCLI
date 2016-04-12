function Get-FolderByPath{
  <# .SYNOPSIS Retrieve folders by giving a path .DESCRIPTION The function will retrieve a folder by it's path. The path can contain any type of leave (folder or datacenter). .NOTES Author: Luc Dekens .PARAMETER Path The path to the folder. This is a required parameter. .PARAMETER Path The path to the folder. This is a required parameter. .PARAMETER Separator The character that is used to separate the leaves in the path. The default is '/' .EXAMPLE PS> Get-FolderByPath -Path "Folder1/Datacenter/Folder2"
.EXAMPLE
  PS> Get-FolderByPath -Path "Folder1>Folder2" -Separator '>'
#>
 
  param(
  [CmdletBinding()]
  [parameter(Mandatory = $true)]
  [System.String[]]${Path},
  [char]${Separator} = '\'
  )
 
  process{
    if((Get-PowerCLIConfiguration).DefaultVIServerMode -eq "Multiple"){
      $vcs = $defaultVIServers
    }
    else{
      $vcs = $defaultVIServers[0]
    }
 
    foreach($vc in $vcs){
      foreach($strPath in $Path){
        $root = Get-Folder -Name Datacenters -Server $vc
        $strPath.Split($Separator) | %{
          $root = Get-Inventory -Name $_ -Location $root -Server $vc -NoRecursion
          if((Get-Inventory -Location $root -NoRecursion | Select -ExpandProperty Name) -contains "vm"){
            $root = Get-Inventory -Name "vm" -Location $root -Server $vc -NoRecursion
          }
        }
        $root | where {$_ -is [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl]}|%{
          Get-Folder -Name $_.Name -Location $root.Parent -NoRecursion -Server $vc
        }
      }
    }
  }
}

function RestoreESXInfo {

  param([string]$directory, [string]$hostName, [string]$dcName)

    if ($directory -eq "" -or $hostName -eq "" -or $dcName -eq "") {

        echo "Please specify directory, dcName, and hostName!"
        return;
    }

  $allVMs = import-clixml $directory\${hostName}_folders.xml

  foreach ($thisVM in $allVMs) {

    if ($thisVM.isTemplate) {

      $ESXhost = Get-VMHost -Name $hostName
      $VMFolder = Get-Folder -Name "Discovered virtual machine"
      New-Template -TemplateFilePath $thisVM.vmxPath -VMHost $ESXHost -Location $VMFolder
      $template = Get-Template -Name $thisVM.name -Location $VMFolder
      $folder = Get-FolderByPath -Path $thisVM.folderPath

      if ($template -and $folder) {

        Move-Template -Template $template -Destination $folder
      }
    }

    else {

      $vm = Get-Folder -Name "Discovered virtual machine" | Get-VM -Name $thisVM.name
      $folder = Get-FolderByPath -Path $thisVM.folderPath
      $pool = $thisVM.rPool.Split("/")

      if ($vm -and $folder) {

        Move-VM -VM $vm -Destination $folder
      }

      $dest_cluster = Get-Cluster -Name $pool[0]
      $dest_pool = Get-ResourcePool -Location $dest_cluster -Name $pool[2]

      if ($vm -and $dest_pool) {

        Move-VM -VM $vm -Destination $dest_pool
      }
    }
  }
}

Add-PSSnapin VMware.VimAutomation.Core
If ($globale:DefaultVIServers) {
	Disconnect-VIServer -Server $global:DefaultVIServers -Force
	}

$directory = ""

$destVI = Read-Host "Please enter name or IP address of the DESTINATION Server"
$datacenter = Read-Host "DataCenter van destination vCenter"
$creds = get-credential
connect-viserver -server $destVI -Credential $creds


##IMPORT FOLDERS
Import-Csv "$($directory)\03-$($datacenter)-Folders-with-FolderPath.csv" | % {
 $startFolder = Get-Datacenter -Name 'Bartor' | Get-Folder -Name 'vm' -NoRecursion
    $path = $_.Path
 
    $location = $startFolder
    echo $location
    $path.Split('\') | Select -skip 1 | %{
        $folder=$_
        Try {
            echo "GET: $folder LOC: $location"
            $location = Get-Folder -Name $folder -Location $location -ErrorAction Stop
        }
        Catch{
            echo "NEW: $folder LOC: $location"
            $location = New-Folder -Name $folder -Location $location
        }
    } 
    echo "======="
}

Import-Csv "$($directory)\03-$($datacenter)-Network-Folders-with-FolderPath.csv" | % {
 $startFolder = Get-Datacenter -Name 'Bartor' | Get-Folder -Type Network -Name datastore -NoRecursion
    $path = $_.Path
 
    $location = $startFolder
    echo $location
    $path.Split('\') | %{
        $folder=$_
        Try {
            echo "GET: $folder LOC: $location"
            $location = Get-Folder -Name $folder -Location $location -ErrorAction Stop
        }
        Catch{
            echo "NEW: $folder LOC: $location"
            $location = New-Folder -Name $folder -Location $location
        }
    } 
    echo "======="
}

Import-Csv "$($directory)\03-$($datacenter)-Datastore-Folders-with-FolderPath.csv" | % {
    $startFolder = Get-Datacenter -Name 'Bartor' | Get-Folder -Type Datastore -Name datastore -NoRecursion
    $path = $_.Path
 
    $location = $startFolder
    echo $location
    $path.Split('\') | Select -skip 2 | % {
        $folder=$_
        Try {
            echo "GET: $folder LOC: $location"
            $location = Get-Folder -Name $folder -Location $location -ErrorAction Stop
        }
        Catch {
            echo "NEW: $folder LOC: $location"
            $location = New-Folder -Name $folder -Location $location
        }
    }
    echo "======="
}


Disconnect-VIServer "*" -confirm:$false




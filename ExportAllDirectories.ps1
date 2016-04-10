Add-PSSnapin VMware.VimAutomation.Core
If ($globale:DefaultVIServers) {
	Disconnect-VIServer -Server $global:DefaultVIServers -Force
	}

$directory = ""

$sourceVI = Read-Host "Please enter name or IP address of the source Server"
$datacenter = Read-Host "Datacenter name in source vCenter"
$creds = get-credential
connect-viserver -server $sourceVI -Credential $creds

filter Get-FolderPath {
    $_ | Get-View | % {
        $row = "" | select Name, Path
        $row.Name = $_.Name

        $current = Get-View $_.Parent
        $path = $_.Name
        do {
            $parent = $current
            if($parent.Name -ne "vm"){$path = $parent.Name + "\" + $path}
            $current = Get-View $current.Parent
        } while ($current.Parent -ne $null)
        $row.Path = $path
        $row
    }
}

## Export all folders
$report = @()
$report = get-datacenter $datacenter -Server $sourceVI| Get-folder vm | get-folder | Get-Folderpath
        ##Replace the top level with vm
        foreach ($line in $report) {
        $line.Path = ($line.Path).Replace($datacenter + "\","vm\")
        }
$report | Export-Csv "$($directory)\03-$($datacenter)-Folders-with-FolderPath.csv" -NoTypeInformation

$report = @()
$report = get-datacenter $datacenter -Server $sourceVI| Get-folder datastore | get-folder | Get-Folderpath
        ##Replace the top level with vm
        foreach ($line in $report) {
        $line.Path = ($line.Path).Replace($datacenter + "\","vm\")
        }
$report | Export-Csv "$($directory)\03-$($datacenter)-Datastore-Folders-with-FolderPath.csv" -NoTypeInformation

$report = @()
$report = get-datacenter $datacenter -Server $sourceVI| Get-folder network | get-folder | Get-Folderpath
        ##Replace the top level with vm
        foreach ($line in $report) {
        $line.Path = ($line.Path).Replace($datacenter + "\","vm\")
        }
$report | Export-Csv "$($directory)\03-$($datacenter)-Network-Folders-with-FolderPath.csv" -NoTypeInformation


Disconnect-VIServer "*" -Confirm:$False

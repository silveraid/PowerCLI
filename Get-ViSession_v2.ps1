Function Get-ViSession {

    <#
    .SYNOPSIS
    Lists vCenter Sessions.

    .DESCRIPTION
    Lists all connected vCenter Sessions.

    .EXAMPLE
    PS C:\> Get-VISession

    .EXAMPLE
    PS C:\> Get-VISession | Where { $_.IdleMinutes -gt 5 }
    #>

    $global:DefaultVIServers | ForEach {

        $VIServer = $_.Name
        $SessionMgr = Get-View -id SessionManager -Server $VIServer
        $AllSessions = @()

        $SessionMgr.SessionList | ? UserName -notlike '*vpxd-extension*' | Foreach {

            $Session = New-Object -TypeName PSObject -Property @{
                
                Server = $VIServer
                Key = $_.Key
                UserName = $_.UserName
                FullName = $_.FullName
                LoginTime = ($_.LoginTime).ToLocalTime()
                LastActiveTime = ($_.LastActiveTime).ToLocalTime()
                IPAddress = $_.IPAddress
            }

            If ($_.Key -eq $SessionMgr.CurrentSession.Key) {

                $Session | Add-Member -MemberType NoteProperty -Name Status -Value "Current Session"
            }

            Else {

                $Session | Add-Member -MemberType NoteProperty -Name Status -Value "Idle"
            }

            $Session | Add-Member -MemberType NoteProperty -Name IdleMinutes -Value ([Math]::Round(((Get-Date) - ($_.LastActiveTime).ToLocalTime()).TotalMinutes))

            $AllSessions += $Session
        }

        $AllSessions
    }
}

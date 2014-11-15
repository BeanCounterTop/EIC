Function Enable-RDP {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
    net localgroup "remote desktop users" /add "$DomainName\Domain Users"
    }

Function Disable-Sleep {
    powercfg -h off
    powercfg -X -standby-timeout-ac 0
    powercfg -X -disk-timeout-ac 0
    powercfg -X -monitor-timeout-ac 0
    }

Function Set-IntranetZones {
    New-ItemProperty -path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$DomainName" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$DomainName" -Name "*" -Value 1 -Type "DWORD"
    }

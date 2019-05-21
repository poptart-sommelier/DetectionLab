# Get hostname
$hostname = $(hostname)

If ($hostname -eq "win10") {
  # Disable Windows Defender for Win10
  Set-MpPreference -DisableRealtimeMonitoring $true
  New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force
}

If ($hostname -eq "dc") {
  # Disable Windows Defender for Server 2016
  Uninstall-WindowsFeature -Name Windows-Defender
}
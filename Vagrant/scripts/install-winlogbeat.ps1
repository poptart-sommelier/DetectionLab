# Purpose: Installs chocolatey package manager, then installs winlogbeat for ELK/HELK.

$winlogbeatPath = "C:\ProgramData\chocolatey\lib\winlogbeat\tools"
$winlogbeatconfigPath = "$winlogbeatPath\winlogbeat.yml"
# This should be set to the IP address that HELK will be running under. It will likely be 192.168.38.105, unless you changed it.
$HELK_IP = '192.168.38.105'

If (-not (Test-Path "C:\ProgramData\chocolatey")) {
  Write-Host "Installing Chocolatey"
  Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
  Write-Host "Chocolatey is already installed."
}
  
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing winlogbeat..."

# apparently HELK has problems with 7.X versions of winlogbeat, forcing 6.7.1 for now.
# see: https://github.com/Cyb3rWard0g/HELK/blob/master/winlogbeat/winlogbeat.yml
# Use commented one when the issue is resolved.
# choco install -y --limit-output --no-progress winlogbeat --version 6.7.1

# The above issue seems to be resolved, and now allows 6, 7 or 8
choco install -y --limit-output --no-progress winlogbeat


# Set TLSv1.2 to fetch config
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading HELK winlogbeat.yml, and modifying it for our config"
# (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/Cyb3rWard0g/HELK/master/winlogbeat/winlogbeat.yml', $winlogbeatconfigPath)
$winlogbeatYml = (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Cyb3rWard0g/HELK/master/winlogbeat/winlogbeat.yml')
# We only have one HELK Kafka instance, so remove the extra one
$winlogbeatYml = $winlogbeatYml -replace ',\"<HELK-IP>:9093\"',''
# Make sure we've set it to our actual IP
$winlogbeatYml = $winlogbeatYml -replace '<HELK-IP>',$HELK_IP
Set-Content -Path $winlogbeatconfigPath -value $winlogbeatYml

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Setting winlogbeat to auto and starting it"
# Minimal research shows that set-service does not work well when changing start type from delayedauto to auto, so we use sc.exe instead
sc.exe config winlogbeat start= auto
# Start the service
Set-Service winlogbeat -Status running

Write-Host "Winlogbeat installation complete!"
  
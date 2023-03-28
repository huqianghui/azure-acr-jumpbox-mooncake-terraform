 # Download the package
 function download() {$ProgressPreference="SilentlyContinue"; Invoke-WebRequest -Uri https://aka.ms/AzureConnectedMachineAgent -OutFile AzureConnectedMachineAgent.msi}
 download
 

 # Install the package
 $exitCode = (Start-Process -FilePath msiexec.exe -ArgumentList @("/i", "AzureConnectedMachineAgent.msi" ,"/l*v", "installationlog.txt", "/qn") -Wait -Passthru).ExitCode
 if($exitCode -ne 0) {
     $message=(net helpmsg $exitCode)
     throw "Installation failed: $message See installationlog.txt for additional details."
 }
 
 Write-Output "service-principal-id: $spnClientId"
 Write-Output "--tenant-id: $spnTenantId"


 # Run connect command
 & "$Env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --service-principal-id "d87459d0-2655-41a5-917b-060b04cd6a46" --service-principal-secret "lV.6vVZY6nkL_-G_7qr7Ynv3H5~zbbZzgt" --resource-group "ArcBox-mooncake-RG" --tenant-id "2f72f96c-65f9-4a6a-b166-dd61493e4b2e" --location "chinaeast2" --subscription-id "cc2fb595-1a97-4bc0-b33e-8955f43d1b05" --cloud "AzureChinaCloud" --tags "Project=jumpstart_arcbox" --correlation-id "d009f5dd-dba8-4ac7-bac9-b54ef3a6671a" # Do no change!
 
 if($LastExitCode -eq 0){Write-Host -ForegroundColor yellow "To view your onboarded server(s), navigate to https://portal.azure.cn/#view/Microsoft_Azure_HybridCompute/AzureArcCenterBlade/~/servers"}
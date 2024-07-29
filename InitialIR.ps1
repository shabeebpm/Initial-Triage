# Define the paths for output files
$eventLogPath = "DefenderEventLog.csv"
$detectionHistoryPath = "DetectionHistory.txt"
$quarantineFilesPath = "QuarantineFiles.txt"
$transcriptLogPath = "PowerShellTranscript.txt"
$consoleHistoryPath = "ConsoleHistory.txt"
$processesPath = "SystemProcesses.txt"
$networkConnectionsPath = "NetworkConnections.txt"

$nonBrowserProcesses = "nonBrowserProcesses.txt"
$browserProcesses = "browserProcesses.txt"
$connectionsToUnexplainedIPs = "connectionsToUnexplainedIPs.txt"

# Output directory
#$outputDirectory = "C:\Shabeeb\Custom"

# Create output directory if it doesn't exist
#if (-not (Test-Path -Path $outputDirectory -PathType Container)) {
#    New-Item -Path $outputDirectory -ItemType Directory
#}


# Export Microsoft Defender event log to a CSV file
Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational" | Select-Object * | Export-Csv -Path $eventLogPath -NoTypeInformation

# Export Microsoft Defender detection history to a text file
Get-MpThreatDetection | Format-List | Out-File -FilePath $detectionHistoryPath

# Export list of quarantined files to a text file
Get-MpThreatCatalog | Where-Object { $_.QuarantineStatus -eq "Quarantined" } | Format-List | Out-File -FilePath $quarantineFilesPath

# Start PowerShell transcript and execute commands
$transcriptLogPath = "PowerShellTranscript.txt"
Start-Transcript -Path $transcriptLogPath
# Add your PowerShell commands here
# Example: Get-Process
Stop-Transcript

# Export PowerShell console history to a text file
$consoleHistoryPath = "ConsoleHistory.txt"
(Get-History).CommandLine | Out-File -FilePath $consoleHistoryPath

# Export system processes to a text file
$processesPath = "SystemProcesses.txt"
Get-Process | Format-Table | Out-File -FilePath $processesPath

# Export network connections to a text file
$networkConnectionsPath = "NetworkConnections.txt"
Get-NetTCPConnection | Format-Table | Out-File -FilePath $networkConnectionsPath

#DNS logs information, but it is not workign as expected
#$log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration 'Microsoft-Windows-DNS-Client/Operational'

#$log.IsEnabled=$true

#$log.SaveChanges()

#Get-WinEvent -FilterHashtable @{LogName = 'Microsoft-Windows-DNS-Client/Operational'} |
#    Where-Object {$_.Id -eq 3008} |
#    Select-Object TimeCreated,
#               @{Name = 'QueryName'; Expression = {$_.Properties[0].Value}},
#                @{Name = 'QueryResult'; Expression = {$_.Properties[4].Value}} |
#    Export-Csv -Path 'DNS_Requests.csv' -NoTypeInformation



# Get the processes communicating over specific ports
$ports = @(80, 443, 8080)
$nonBrowserProcesses = Get-NetTCPConnection | Where-Object { $_.LocalPort -in $ports -and $_.OwningProcess -notmatch 'browser' }
$nonBrowserProcesses | Out-File -FilePath 'nonBrowserProcesses.txt'

# Get browser processes not communicating over specific ports
$browserProcesses = Get-NetTCPConnection | Where-Object { $_.LocalPort -notin $ports -and $_.OwningProcess -match 'browser' }
$browserProcesses | Out-File -FilePath 'browserProcesses.txt'

# Get connections to unexplained internal or external IP addresses
#$unexplainedIPs = @('192.168.1.1', '10.0.0.1') # replace with your unexplained IPs
#$connectionsToUnexplainedIPs = Get-NetTCPConnection | Where-Object { $_.RemoteAddress -in $unexplainedIPs }
#$connectionsToUnexplainedIPs | Out-File -FilePath 'connectionsToUnexplainedIPs.txt'



Write-Host "Extraction completed. Files saved at:"
Write-Host "Event Log: $eventLogPath"
Write-Host "Detection History: $detectionHistoryPath"
Write-Host "Quarantine Files: $quarantineFilesPath"
Write-Host "PowerShell Transcript: $transcriptLogPath"
Write-Host "Console History: $consoleHistoryPath"
Write-Host "System Processes: $processesPath"
Write-Host "Network Connections: $networkConnectionsPath"

Write-Host "Processes communicating over specific ports: $nonBrowserProcesses"
Write-Host "Browser processes not communicating over specific ports: $browserProcesses"
#Write-Host "Network Connections: $connectionsToUnexplainedIPs"



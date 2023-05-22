#####
# Author: Tanner J. Brouillard
# Github: https://github.com/Diplodongus/ADAdminTool/edit/main/Get-ComputerSerials.ps1
# Requires Powershell 7 to function. For version compatible with Powershell 5, see older revisions.
####
# Add assembly for OpenFileDialog
Add-Type -AssemblyName System.Windows.Forms

# Initialize OpenFileDialog for input file
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
$openFileDialog.Filter = "Text files (*.txt)|*.txt"
$openFileDialog.Title = "Select a text file that contains computer names"

# Show OpenFileDialog and assign the selected filename to computernames variable
if ($openFileDialog.ShowDialog() -eq 'OK') {
    $computernames = Get-Content $openFileDialog.FileName
}

# Initialize SaveFileDialog for output file
$saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
$saveFileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
$saveFileDialog.Filter = "CSV files (*.csv)|*.csv"
$saveFileDialog.Title = "Select a location to save the output CSV file"

# Show SaveFileDialog and assign the selected filename to csvfile variable
if ($saveFileDialog.ShowDialog() -eq 'OK') {
    $csvfile = $saveFileDialog.FileName
}

# Function to process each computer
function Process-Computer {
    param($computername)

    Write-Output "Processing $computername"

    # Initialize a hashtable for the current computer results
    $result = @{"ComputerName"=$computername}

    # Test connection
    if (Test-Connection -ComputerName $computername -Count 1 -Quiet) {
        # Gather system info using WMI
        $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computername
        $cs = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computername
        $bios = Get-WmiObject -Class Win32_BIOS -ComputerName $computername

        # Fill in the results hashtable
        $result["Serial"] = $bios.SerialNumber
        $result["Model"] = $cs.Model
        $result["Vendor"] = $cs.Manufacturer
        $result["LoggedUser"] = $cs.UserName
    } else {
        # Host offline
        $result["Serial"] = "Host Offline"
        $result["Model"] = "Host Offline"
        $result["Vendor"] = "Host Offline"
        $result["LoggedUser"] = "Host Offline"
    }

    # Return the results for the current computer
    return New-Object psobject -Property $result
}

# Process each computer in parallel and write each result to the CSV file as it becomes available
$computernames | ForEach-Object -Parallel {
    $result = & $using:args[0] $using:args[1]
    $result | Export-Csv $using:args[2] -NoTypeInformation -Append
} -ThrottleLimit $computernames.Count -ArgumentList $function:Process-Computer, $_, $csvfile

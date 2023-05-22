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

# Initialize the results array
$results = @()

# Iterate over each computer
foreach ($computername in $computernames) {
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

    # Add the current computer results to the results array
    $results += New-Object psobject -Property $result
}

# Export results to CSV
$results | Export-Csv $csvfile -NoTypeInformation
